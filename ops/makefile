#pre-install git, docker
#index
list:
	@echo workspace-init
	@echo workspace-up

	@echo server-init
	@echo server-up
	@echo server-logs

	@echo all-down
	@echo project-create

# variables
DOMAIN_NAME = app.test
PROJECT_NAME = app
DATABASE_NAME = appDb
DATABASE_PASSWORD = 123456
CURRENT_PATH = $(shell pwd)
LARADOCK_PATH = ./laradock

# command
workspace-init:
	git clone https://github.com/laradock/laradock.git
	cd $(LARADOCK_PATH) && rm -f .env && cp env-example .env
	sed -i -e 's/APP_CODE_PATH_HOST=\.\.\//APP_CODE_PATH_HOST=\.\.\/\.\.\//g' $(LARADOCK_PATH)/.env
	sed -i -e 's/MYSQL_DATABASE=default/MYSQL_DATABASE=$(DATABASE_NAME)/g' $(LARADOCK_PATH)/.env
	sed -i -e 's/MYSQL_ROOT_PASSWORD=root/MYSQL_ROOT_PASSWORD=$(DATABASE_PASSWORD)/g' $(LARADOCK_PATH)/.env
	sed -i -e 's/WORKSPACE_INSTALL_PYTHON=false/WORKSPACE_INSTALL_PYTHON=true/g' $(LARADOCK_PATH)/.env
	sed -i -e 's/MYSQL_VERSION=latest/MYSQL_VERSION=5.7/g' $(LARADOCK_PATH)/.env	
workspace-up:
	cd $(LARADOCK_PATH) && docker-compose up -d workspace && docker-compose exec --user laradock workspace bash

server-init:
	echo '127.0.0.1             $(DOMAIN_NAME)' >> /etc/hosts
	cd $(LARADOCK_PATH) && docker-compose run --rm --user laradock workspace bash -c "cd ./$(PROJECT_NAME) && composer install && . ~/.nvm/nvm.sh npm --version && npm i && npm run dev"
server-up:
	cd $(LARADOCK_PATH)/nginx/sites && cp -f laravel.conf.example $(PROJECT_NAME).conf
	cd $(LARADOCK_PATH)/nginx/sites && sed -i -e 's/root \/var\/www\/laravel\/public;/root \/var\/www\/$(PROJECT_NAME)\/public;/g' ./$(PROJECT_NAME).conf
	cd $(LARADOCK_PATH)/nginx/sites && sed -i -e 's/server_name laravel\.test;/server_name $(DOMAIN_NAME);/g' ./$(PROJECT_NAME).conf
	cd $(LARADOCK_PATH) && docker-compose up -d nginx redis mysql
server-logs:
	cd $(LARADOCK_PATH) && docker-compose logs -f

all-down:
	cd $(LARADOCK_PATH) && docker-compose down

project-create:
	cd $(LARADOCK_PATH) && docker-compose run --rm --user laradock workspace composer create-project laravel/laravel $(PROJECT_NAME)

test:
	@echo $(CURRENT_PATH)