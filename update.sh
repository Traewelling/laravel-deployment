#!/bin/bash

folder="release"
branch="develop"
dev=0
tag=0
force=0

print_help() {
# Display Help
   echo "Updater for Laravel projects"
   echo
   echo "Syntax: update.sh [-|h|d|t|f] [-b BRANCHNAME] [-n PATH_NAME]"
   echo "options:"
   echo "  -d"
   echo -e "\tUpdates with npm run dev"
   echo "  -t"
   echo -e "\tChecks out the latest tag"
   echo "  -f"
   echo -e "\tSkips confirmation of settings at begin of script"
   echo "  -b BRANCHNAME"
   echo -e "\tChecks out the repo with the supplied branch"
   echo -e "\tDefaults to ${branch}"
   echo "  -n PATH_NAME"
   echo -e "\tSets the symlink name for the repo to be installed to"
   echo -e "\tDefaults to ${folder}"
   echo "  -h"
   echo -e "\tPrint this Help."
   
   exit
}


install() {
# Print out settings    
        echo -e "\e[33mUsing branch \e[36m${branch}\e[0m"
        echo -e "\e[33mUsing path \e[36m${folder}\e[0m"
        if [ ${dev} == 1 ]; then
                echo -e "\e[33mUsing development options\e[0m"
        fi  
        if [ ${tag} == 1 ]; then
                echo -e "\e[33mUsing latest tag\e[0m"
        fi  
    
        # Ask for confirmation, if force tag is not set
        if [ ${force} == 0 ]; then
                read -p "Are all settings correct? (Y/n)" -n 1 -r
                echo   
                if [[ $REPLY =~ ^[Nn]$ ]]
                then
                    exit
                fi  
        fi

        # Get name for current folder and generate new name
        # Copy current version into working directory
        oldpath=$( basename "$( readlink -f ${folder} )" )
        path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

        echo -e "\e[33mCopying old install from \e[36m${oldpath}\e[33m to \e[36m${path}\e[0m"
        cp -r "${oldpath}" "${path}"

        # updating branch
        pushd "${path}" > /dev/null || exit 1
        git checkout ${branch}
        git pull

        # Checking out latest tag if -t is set
        if [ ${tag} ]; then
                latesttag=$(git describe --tags --abbrev=0)
                echo -e "\e[33mChecking out \e[36m${latesttag}\e[0m"
                git checkout "${latesttag}" -q
        fi

        # Installing new packages in composer and npm
        # running npm compilation depending on dev option
        if [ ${dev} == 0 ]; then
        	composer install --no-interaction --prefer-dist --no-dev
        	#composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
	        npm ci --only=prod
	        npm run prod
        else
		composer install --no-interaction --prefer-dist --optimize-autoloader
		npm ci
                npm run dev
        fi

        # Bringing current instance into maintenance mode
	popd > /dev/null || exit 1
        pushd "${oldpath}" > /dev/null || exit 1
        php artisan down || exit 1

        # Migrating new versions
	popd > /dev/null || exit 1
        pushd "${path}" > /dev/null || exit 1
        php artisan migrate --force
	
	# Erase cache
	php artisan cache:clear
	# Clear and cache routes
	php artisan route:clear
	php artisan route:cache
	# Clear and cache config
	php artisan config:clear
	php artisan config:cache
	# Clear expired password reset tokens
	php artisan auth:clear-resets
	
        # Copy profile pictures if any were uploaded while compiling new version
	popd > /dev/null || exit 1
        cp -r -n "${oldpath}"/public/uploads "${path}"/public/uploads	

        # Update symlink to newest compiled version
        echo -e "\n\n========================================="
        echo -e "\e[33mCreating Symlink \e[36m${folder}\e[33m for \e[36m${path}"
        ln -fsn "${path}" "${folder}"

        # Delete old backup if symlink to it exists
        if [ -L "${folder}_bak" ]; then
                bak_path=$( basename "$( readlink -f ${folder}_bak )" )
                echo -e "\e[33mDeleting old backup \e[36m${bak_path}\e[0m"
                rm -rf "${bak_path}"
        fi

        # Update backup-symlink to last version
        echo -e "\e[33mCreating symlink for backup\e[0m"
        ln -fsn "${oldpath}" "${folder}_bak"

        # removing maintenance mode (should not be necessary)
        pushd ${folder} > /dev/null || exit
        php artisan up
        echo -e "\e[32mDone. :)\e[0m"
}


# --------
# Get options
# --------

while getopts e:b:n:dhtf OPT
do
    case "$OPT" in
        h) print_help ;;
        b) branch=$OPTARG;;
        n) folder=$OPTARG;;
        d) dev=1;;
        t) tag=1;;
        f) force=1;;
        ?) print_help ;;
    esac
done
        install
