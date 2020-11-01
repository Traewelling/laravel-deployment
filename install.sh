#!/bin/bash

install() {
	folder="release"
	path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
	

	echo -e "\e[33mCloning traewelling\e[0m"
	git clone https://github.com/Traewelling/traewelling.git ${path}
	cd ${path}
	latesttag=$(git describe --tags)
	if [ ${folder} = "release" ]; then
		echo -e "\e[33mChecking out ${latesttag}\e[0m"
		git checkout ${latesttag} -q
	fi
	composer install
	cp .env.example .env
	php artisan key:generate
	cp .env ../${folder}_env
	echo -e "\n\n========================================="
	echo -e "\e[32mPlease edit the \e[0m${folder}_env\e[32m file iside your base directory to fit your needs and then continue\e[0m"
	read -n 1 -s -r -p "Press any key to continue"	
	cp ../${folder}_env .env
	npm install
	if [ ${folder} == "release" ]; then
		npm run prod
		php artisan migrate
	else
		npm run dev
		php artisan migrate --seed
	fi
	php artisan passport:install
	cd ..
	ln -s ${path} ${folder}
}

	install
