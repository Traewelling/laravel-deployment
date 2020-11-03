#!/bin/bash

folder="release"
branch="develop"
repo="https://github.com/Traewelling/traewelling.git"
dev=0
tag=0
force=0

print_help() {
# Display Help
   echo "Installer for Träwelling"
   echo
   echo "Syntax: install.sh [-|h|d|t|f] [-b BRANCHNAME] [-r REPO_URL]"
   echo "options:"
   echo "  -d"
   echo -e "\tInstalls with seeding in the migration"
   echo "  -t"
   echo -e "\tChecks out the latest tag"
   echo "  -f"
   echo -e "\tSkips confirmation of settings at begin of script"
   echo "  -r REPO_URL"
   echo -e "\tSets the url for the to be installed repo"
   echo "  -b BRANCHNAME"
   echo -e "\tChecks out the repo with the supplied branch"
   echo "  -h"
   echo -e "\tPrint this Help."

   exit 
}

install() {
	
	echo -e "\e[33mUsing branch \e[36m${branch}\e[0m"
	echo -e "\e[33mUsing path \e[36m${folder}\e[0m"
	if [ ${dev} == 1 ]; then
		echo -e "\e[33mUsing development options\e[0m"
	fi
	if [ ${tag} == 1 ]; then
		echo -e "\e[33mUsing latest tag\e[0m"
	fi
	
	if [ ${force} == 0 ]; then
		read -p "Are all settings correct? (Y/n)" -n 1 -r
		echo   
		if [[ $REPLY =~ ^[Nn]$ ]]
		then
		    exit
		fi
	fi
	
	# Creating new pathname and checking for existing symlink
	path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
	if [[ -L "$folder" ]]; then
		echo -e "${folder}\e[31m already exists. Did you mean to run the updater?"
		exit 1
	fi

	echo -e "\e[33mCloning project\e[0m"
	git clone ${repo} ${path}
	cd ${path}
	git checkout ${branch}
	
	if [ ${tag} ]; then
		latesttag=$(git describe --tags --abbrev=0)
		echo -e "\e[33mChecking out ${latesttag}\e[0m"
		git checkout ${latesttag} -q
	fi
	cp .env.example .env

	echo -e "\n\n========================================="
	echo -e "\e[32mPlease edit the \e[0m.env\e[32m file iside the directory\e[36m${path}\e[32m to fit your needs and then continue\e[0m"
	echo -e "\e[5mPress any key to continue\e[0m"	
	read -n 1 -s -r -p ""
	composer install
	npm install
	php artisan key:generate
	if [ ${dev} == 0 ]; then
		npm run prod
		php artisan migrate
	else
		npm run dev
		php artisan migrate --seed
	fi
	php artisan passport:install
	cd ..
	
	echo -e "\n\n========================================="
	echo -e "\e[33mCreating Symlink \e[0m${folder}\e[33m for \e[0m${path}"
	ln -s ${path} ${folder}
	echo -e "\e[32mDone. :)\e[0m"
}


# --------
# Get options
# --------

while getopts e:b:p:r:dhtf OPT
do
    case "$OPT" in
        h) print_help ;;
        b) branch=$OPTARG;;
	p) folder=$OPTARG;;
	r) repo=$OPTARG;;
	d) dev=1;;
	t) tag=1;;
	f) force=1;;
        ?) print_help ;;
    esac
done

install
