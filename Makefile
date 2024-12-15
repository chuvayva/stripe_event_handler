# TODO: Review docker artifacts: conainers, images, volumes

setup:
	docker compose build
	make run-app rake db:prepare
	make run-app rake db:test:prepare

start:
	docker compose up

test:
	make run-app rspec $(filter-out $@, $(MAKECMDGOALS))

console: # quotes prevent recursion for 'console'
	make run-app 'rails console' 

shell:
	make run-app /bin/bash


# General

run-app:
	docker compose run --rm app $(filter-out $@, $(MAKECMDGOALS))


# Shortcuts

s: start
c: console
sh: shell
r:
	make run-app $(filter-out $@, $(MAKECMDGOALS))
t:
	make run-app rspec $(filter-out $@, $(MAKECMDGOALS))

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