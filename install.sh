#!/bin/bash

install() {
	folder="release"
	path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
	if [[ -L "$folder" ]]; then
		echo -e "${folder}\e[31m already exists. Did you mean to run the updater?"
		exit
	fi

	echo -e "\e[33mCloning traewelling\e[0m"
	git clone https://github.com/Traewelling/traewelling.git ${path}
	cd ${path}
	latesttag=$(git describe --tags)
	if [ ${folder} = "release" ]; then
		echo -e "\e[33mChecking out ${latesttag}\e[0m"
		git checkout ${latesttag} -q
	fi
	cp .env.example .env

	echo -e "\n\n========================================="
	echo -e "\e[32mPlease edit the \e[0m.env\e[32m file iside the directory\e[0m${path}\e[32m to fit your needs and then continue\e[0m"
	echo -e "\e[5mPress any key to continue\e[0m"	
	read -n 1 -s -r -p ""
	composer install
	npm install
	php artisan key:generate
	if [ ${folder} == "release" ]; then
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

	install
