#!/bin/bash

install() {
	folder="release"
	oldpath=$( basename "$( readlink -f ${folder} )" )
	path=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

	echo -e "\e[33mCopying old install from \e[0m${oldpath}\e[33m to \e[0m${path}"
	cp -r ${oldpath} ${path}
	cd ${path}
	git checkout develop
	git pull
	latesttag=$(git describe --tags --abbrev=0)
	if [ ${folder} = "release" ]; then
		echo -e "\e[33mChecking out ${latesttag}\e[0m"
		git checkout ${latesttag} -q
	fi
	composer install
	npm install
	if [ ${folder} == "release" ]; then
		npm run prod
	else
		npm run dev
	fi

	cd ../${oldpath}
	php artisan down
	cd ../${path}
	php artisan migrate --force

	cd ..
		
	echo -e "\n\n========================================="
	rm -rf ${folder}
	echo -e "\e[33mCreating Symlink \e[0m${folder}\e[33m for \e[0m${path}"
	ln -s ${path} ${folder}
	rm -rf ${oldpath}
	cd ${folder}
	php artisan up
	echo -e "\e[32mDone. :)\e[0m"
}

	install
