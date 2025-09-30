DC=docker-compose

.PHONY: build up down logs exec migrate console dbshell
 
# setup: prepare env, build, bring stack up and prepare database
.PHONY: setup
setup:
	# copy env example if .env is missing
	@if [ ! -f backend/.env ]; then cp backend/.env.example backend/.env && echo "Copied backend/.env.example to backend/.env"; fi
	$(DC) build
	$(DC) up -d --remove-orphans
	$(DC) exec web bin/rails db:prepare

build:
	$(DC) build

up:
	$(DC) up -d --remove-orphans

down:
	$(DC) down

logs:
	$(DC) logs -f

exec:
	$(DC) exec web bash

migrate:
	$(DC) exec web bin/rails db:migrate

console:
	$(DC) exec web bin/rails console

dbshell:
	$(DC) exec db psql -U postgres -d currency_converter_development
