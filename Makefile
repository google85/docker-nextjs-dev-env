help: ## View all make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init-app: ## Creating the app
	@echo "Creating the app..."
	docker build -t nextjs-init:2.0 --target appinit .
	echo "Please name the app 'app' to make the folder"
	docker run --rm -it --name 'nextjs-init2' -v ${PWD}/:/app -w /app nextjs-init:2.0

start-dev: ## Start the dev container stack
	@echo "Starting up dev container..."
	docker build -t nextjs-dev:2.0 --target development .
	docker run --rm -it --name 'nextjs-dev2' -p 3000:3000 -v ${PWD}/app:/app -w /app nextjs-dev:2.0

start-prod: ## Start the prod container stack
	@echo "Starting up production container..."
	docker build -t nextjs-prod:2.0 --target production .

copy-prod: ## Copy from prod container
	@echo "Copying from production into extracted folder..."
	docker container create --name temp nextjs-prod:2.0
	docker container cp temp:/app ./extracted/prod
	docker container rm temp
