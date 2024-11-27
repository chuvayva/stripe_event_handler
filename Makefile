DOCKER_COMPOSE = docker-compose -f ./development/docker-compose.yml

build:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) run web rake db:create db:migrate
	$(DOCKER_COMPOSE) run test rake db:create db:migrate

build\:no_cache:
	$(DOCKER_COMPOSE) build --no-cache

start:
	$(DOCKER_COMPOSE) up web sidekiq db redis

console:
	$(DOCKER_COMPOSE) run web rails console

bash:
	$(DOCKER_COMPOSE) run web /bin/bash

logs:
	$(DOCKER_COMPOSE) run web tail -f log/development.log

test:
	$(DOCKER_COMPOSE) run test rspec

restart:
	$(DOCKER_COMPOSE) restart web sidekiq

stripe_listen:
	stripe listen --forward-to localhost:3000/webhook --events customer.subscription.created,invoice.payment_succeeded,customer.subscription.deleted

stripe_test:
	stripe trigger customer.subscription.deleted