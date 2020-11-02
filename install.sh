#!/bin/bash

folder="release"
branch="develop"
dev=0

print_help() {
# Display Help
   echo "Installer for Träwelling"
   echo
   echo "Syntax: install.sh [-|h|d] [-b BRANCHNAME]"
   echo "options:"
   echo "  -d"
   echo -e "\tInstalls with seeding in the migration and loads"
   echo -e "\tthe most recent commit instead of the latest release"
   echo "  -h"
   echo -e "\tPrint this Help."
   echo "  -b BRANCHNAME"
   echo -e "\tChecks out the repo with the supplied branch"
   exit 
}

install() {

	echo -e "\e[33mUsing branch \e[36m${branch}\e[0m"
	echo -e "\e[33mUsing path \e[36m${folder}\e[0m"
	if [ ${dev} == 1 ]; then
		echo -e "\e[33mUsing development options"
	fi

	path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
	if [[ -L "$folder" ]]; then
		echo -e "${folder}\e[31m already exists. Did you mean to run the updater?"
		exit 1
	fi

	echo -e "\e[33mCloning traewelling\e[0m"
	git clone https://github.com/Traewelling/traewelling.git ${path}
	cd ${path}
	git checkout ${branch}
	latesttag=$(git describe --tags --abbrev=0)
	if [ ${dev} == 0 ]; then
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

#	install


# --------
# Get options
# --------

while getopts e:b:p:dh OPT
do
    case "$OPT" in
        h) print_help ;;
        b) branch=$OPTARG;;
	p) folder=$OPTARG;;
	d) dev=1;;
        ?) print_help ;;
    esac
done

install
