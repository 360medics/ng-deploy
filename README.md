# 360medical deployment script

Deploy Angular 2 app by simply rsync (ing) files to a remote directory using project local configuration file(s).

Support multiple environments/servers.

## Installation

```
cd /somewhere/convenient
wget https://github.com/adadgio/ng-deploy/archive/1.2.zip && unzip 1.2.zip && rm 1.2.zip
chmod +x deploy.sh
sudo ln -s /somewhere/convenient/deploy.sh /usr/local/bin/deploy
```

## Prerequisites

Have the following files and directory in the local angular 2 project.

```
deploy/
    include.txt (optional)
    exclude.txt
    conf-staging.cnf
    conf-prod.cnf (optional)
```

## Commands

Deploy to a new version or override existing version.

```
deploy --env=staging --version=2.2.1
# deploy --e=staging -v=2.2.1
```

Rollback to a specific version.

```
deploy --env=staging --version=2.2.0
```

Read current remotely deployed live version vs local version.

```
deploy --env=staging --status
```
