#!make

######  init  ################
init: full-clear \
	full-build \
	full-init \
	full-ready
#####/  init  ################

#------  full-clear  ---------
full-clear: docker-down-clear \
	api-clear \
	frontend-clear \
	cucumber-clear
#-----/  full-clear  ---------

#------  full-build  ---------
full-build: docker-pull docker-build docker-up
#-----/  full-build  ---------

#------  full-init -----------
full-init: api-init \
	frontend-init \
	cucumber-init
#-----/  full-init  ----------

#-----  full-ready  ----------
full-ready: frontend-ready
#----/  full-ready  ----------

######  common  ##############
up: docker-up
down: docker-down
restart: down up

#-----  commands  ------------
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build
#----/  commands  ------------
#####/  common  ##############

######  api  #################
api-clear:
	docker run --rm -v ${PWD}/api:/app --workdir=/app alpine rm -f .ready

api-init: api-permissions \
	api-composer-install \
	api-wait-db \
	api-ready \
	api-migrations \
	api-fixtures

api-permissions:
	docker run --rm -v ${PWD}/api:/app -w /app alpine chmod 777 var/cache var/log var/test

api-composer-install:
	#docker-compose run --rm api-php-cli composer install

api-composer-update:
	docker-compose run --rm api-php-cli composer update

api-wait-db:
	#until docker-compose exec -T api-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

api-ready:
	#docker run --rm -v ${PWD}/api:/app --workdir=/app alpine touch .ready

api-migrations:
#	docker compose run --rm api-php-cli composer app migrations:migrate -- --no-interaction

api-fixtures:
#	docker compose run --rm api-php-cli composer app fixtures:load######  frontend  #################
#####/  api  #################

######  frontend  #################
frontend-clear:
	docker run --rm -v ${PWD}/frontend:/app -w /app alpine sh -c 'rm -rf .ready build'

frontend-init:
	#frontend-yarn-install

frontend-yarn-install:
#	docker-compose run --rm frontend-node-cli yarn install

frontend-yarn-upgrade:
#	docker-compose run --rm frontend-node-cli yarn upgrade

frontend-ready:
#	docker run --rm -v ${PWD}/frontend:/app -w /app alpine touch .ready

frontend-check:
#    frontend-lint
#	 frontend-test

frontend-lint:
#	docker-compose run --rm frontend-node-cli yarn eslint
#	docker-compose run --rm frontend-node-cli yarn stylelint

frontend-eslint-fix:
	#docker-compose run --rm frontend-node-cli yarn eslint-fix

frontend-pretty:
	#docker-compose run --rm frontend-node-cli yarn prettier

frontend-test:
	#docker-compose run --rm frontend-node-cli yarn test --watchAll=false
######/  frontend  #################

######  cucumber  ##########
cucumber-clear:
	docker run --rm -v ${PWD}/cucumber:/app -w /app alpine sh -c 'rm -rf var/*'

cucumber-init:
	#cucumber-yarn-install

cucumber-yarn-install:
	docker-compose run -rm cucumber-node-cli yarn install

cucumber-yarn-upgrade:
	docker-compose run -rm cucumber-node-cli yarn upgrade
######/  cucumber  ##########
