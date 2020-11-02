#!/bin/bash

install() {
	folder="pfad"
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
	
	# Bringing current instance into maintenance mode
	cd ../${oldpath}
	php artisan down
	
	# Migrating new versions
	cd ../${path}
	php artisan migrate --force
	
	# Copy profile pictures if any were uploaded while compiling new version
	cp -r -n ${oldpath}/public/uploads ${path}/public/uploads
	
	# Update symlink, backup old version and delete old backup 
	cd ..
	echo -e "\n\n========================================="
	echo -e "\e[33mCreating Symlink \e[36m${folder}\e[33m for \e[36m${path}"
	ln -fsn ${path} "${folder}"
	
	if [ -L "${folder}_bak" ]; then
		bak_path=$( basename "$( readlink -f ${folder}_bak )" )
		echo -e "\e[33mDeleting old backup \e[36m${bak_path}\e[0m"
		rm -rf "${bak_path}"
	fi
	
	echo -e "\e[33mCreating symlink for backup\e[0m"
	ln -fsn ${oldpath} "${folder}_bak"
	cd ${folder}
	php artisan up
	echo -e "\e[32mDone. :)\e[0m"
}

	install
