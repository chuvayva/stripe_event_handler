# TODO: Review docker artifacts: conainers, images, volumes

build:
	docker compose build
	docker compose run --rm app rake db:prepare db:test:prepare

start:
	docker compose up

console:
	docker compose run --rm app rails console

bash:
	docker compose run --rm app /bin/bash

logs:
	docker compose run --rm app tail -f log/development.log

test:
	docker compose run --rm app rspec $(filter-out $@, $(MAKECMDGOALS))

restart:
	docker compose run --rm app restart app sidekiq


# Shortcuts

s: start
b: build
c: console
ba: bash
t:
	docker compose run --rm app rspec $(filter-out $@, $(MAKECMDGOALS))

# Stripe

stripe-listen:
	stripe listen --forward-to localhost:3000/webhook --events customer.subscription.created,invoice.payment_succeeded,customer.subscription.deleted

stripe-test:
	stripe trigger customer.subscription.deleted


# Docker

up:
	docker compose up

down:
	docker compose down

down-volumes:
	docker compose down --volumes


# Prevent errors when passing arguments
%:
	@: