build:
	docker-compose -f ./development/docker-compose.yml build
	docker-compose -f ./development/docker-compose.yml run web bundle
	docker-compose -f ./development/docker-compose.yml run web rake db:create db:migrate
	docker-compose -f ./development/docker-compose.yml run test rake db:create db:migrate

start:
	docker-compose -f ./development/docker-compose.yml up web sidekiq db redis

console:
	docker-compose -f ./development/docker-compose.yml run web rails console

logs:
	docker-compose -f ./development/docker-compose.yml run web tail -f log/development.log

test:
	docker-compose -f ./development/docker-compose.yml run test rspec

restart:
	docker-compose -f ./development/docker-compose.yml restart web sidekiq

stripe_listen:
	stripe listen --forward-to localhost:3000/webhook --events customer.subscription.created,invoice.payment_succeeded,customer.subscription.deleted

stripe_test:
	stripe trigger customer.subscription.deleted