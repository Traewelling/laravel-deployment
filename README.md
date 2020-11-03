# Laravel Deployment

This is a shell based installation and update tool for Laravel applications.

In principle it creates a randomly named folder, clones the project with a given branch, handles all relevant install-commands and creates a symlink with a given name.

The update script works similarly: It copies the current install into a new folder, pulls from git, handles all relevant update-commands, updates the symlink and creates a "backup" of the last working install.

## Basic usage

Clone this repo and run

```bash
./install.sh -b develop -n prod
```

to install the `develop` branch of [Träwelling](https://github.com/Traewelling/traewelling) inside of a folder named `prod`.

To update it, simply run

```bash
./update.sh -b develop -p prod
```


### Help for install.sh
```
Installer for Laravel projects

Syntax: install.sh [-|h|d|t|f] [-b BRANCHNAME] [-r REPO_URL] [-n PATH_NAME]
options:
  -d
        Installs with seeding in the migration and npm run dev
  -t
        Checks out the latest tag
  -f
        Skips confirmation of settings at begin of script
  -r REPO_URL
        Sets the url for the to be installed repo
        Defaults to https://github.com/Traewelling/traewelling.git
  -b BRANCHNAME
        Checks out the repo with the supplied branch
        Defaults to develop
  -n PATH_NAME
        Sets the symlink name for the repo to be installed to
        Defaults to release
  -h
        Print this Help.
``` 

### Help for update.sh
```
Updater for Laravel projects

Syntax: update.sh [-|h|d|t|f] [-b BRANCHNAME] [-n PATH_NAME]
options:
  -d
        Updates with npm run dev
  -t
        Checks out the latest tag
  -f
        Skips confirmation of settings at begin of script
  -b BRANCHNAME
        Checks out the repo with the supplied branch
        Defaults to develop
  -n PATH_NAME
        Sets the symlink name for the repo to be installed to
        Defaults to release
  -h
        Print this Help.
```
