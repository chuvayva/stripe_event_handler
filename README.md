# Stripe Event Handler

The Stripe Event Handler is simple rails application that receives and processes events from Stripe.

## Technologies Used

- Ruby on Rails api
- [Sidekiq](https://sidekiq.org) for background processing

## What Is Special About Me

- [Stripe Ruby Library](https://github.com/stripe/stripe-ruby) is for webhook events processing
- [AASM - Ruby state machines](https://redux-saga.js.org) for subscription state management
- Development is fully containerized with Docker
- Makefile has the most common commands to run the project

## How Does This Work?

- Stripe service publish subscription events
- Service webhook endpoint receives them and process in background
- The initial state of the subscription record is "unpaid"
- Paying the first invoice of the subscription changes the state to "paid"
- Canceling a subscription changes the state to “canceled”. Only subscriptions in the state “paid” can be canceled

## How Run Locally

### Stripe

Setup Stripe listener locally. To do you need to [install stripe cli](https://docs.stripe.com/stripe-cli) for example using brew:

```bash
brew install stripe/stripe-cli/stripe
```

Then login to stripe either through a browser

```bash
stripe login
```

or using api key

```bash
stripe config --set test_mode_api_key <test_secret_key>
```

### Docker

Stripe Event Handler is a containerized application so you can run it using Docker. Install Docker using of the ways from official site: https://docs.docker.com

### Master Key

Application uses [rails credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials) to store secrets. You need to copy master.key to the /config folder in order to make it work

### Application

Stripe Event Handler has a Makefile for easier run the most common development tasks. To start the project run:

```bash
make setup
make start
```

## How Test Locally

Run rspec tests:

```bash
make setup
make test
```

Run test webhook events (make sure you are logged in to stripe cli)

```bash
make stripe-listen
```

This will run stripe listener locally that will forward subscription events to the server. Then

```bash
make stripe-test
```

This will send 3 events which will be handled by the server
