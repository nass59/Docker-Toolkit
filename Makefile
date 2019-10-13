.DEFAULT_GOAL := help
.PHONY: help

help:
		@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-25s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##---------------------------------------------------------------------------
## Setup
##---------------------------------------------------------------------------

create-project: ## Create Project
create-project: create-dockerfile create-nginx create-certs create-env create-makefile create-scripts create-network create-ssh-volume create-host move-build

create-dockerfile: ## Create Docker Compose file
	./scripts/config.sh

create-env: ## Create .env files
	./scripts/env.sh

create-makefile: ## Create Makefile files
	./scripts/makefile.sh

create-nginx: ## Create Nginx config file
	./scripts/nginx.sh

create-scripts: ## Create Scripts file
	./scripts/scripts.sh

##---------------------------------------------------------------------------
## HTTPS Certificates
##---------------------------------------------------------------------------

create-certs: ## Create HTTPS Certificates
	./scripts/certs.sh

##---------------------------------------------------------------------------
## Network
##---------------------------------------------------------------------------

create-network: ## Create external network
	./scripts/network.sh create

remove-network: ## Remove external network
	./scripts/network.sh remove

##---------------------------------------------------------------------------
## Host
##---------------------------------------------------------------------------

create-host: ## Create host
	sudo ./scripts/host.sh add

remove-host: ## Remove host
	sudo ./scripts/host.sh add

##---------------------------------------------------------------------------
## SSH Volume
##---------------------------------------------------------------------------

create-ssh-volume: ## Create external volume (ssh)
	./scripts/ssh.sh	

##---------------------------------------------------------------------------
## Move Build
##---------------------------------------------------------------------------

move-build: ## Move created project to your Websites folder
	./scripts/move-build.sh

##---------------------------------------------------------------------------
## Images
##---------------------------------------------------------------------------

images-build: ## Build images
	./scripts/images.sh

##---------------------------------------------------------------------------
## Containers
##---------------------------------------------------------------------------

prune: ## Remove unused containers
	docker prune
