ENV_VERSION:=2.1
PROJ_NAME:=nextjs-demo
PROJ_FOLDER:=app
PROJ_OUTPUT:=extracted

help: ## View all make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init-app: ## Creating the app
	@echo "Creating the app..."
	docker build -t ${PROJ_NAME}:init --build-arg FOLDER_NAME=${PROJ_FOLDER} --target appinit .
	@echo "Please name the app '${PROJ_FOLDER}' to make the folder"
	docker run --rm -it --name '${PROJ_NAME}-init' -v ${PWD}/:/app -e FOLDER_NAME=${PROJ_FOLDER} -w /app ${PROJ_NAME}:init
	@sudo chown -R 1000 ./${PROJ_FOLDER}
#	remove node_modules as they will be generated on start-dev step
	@sudo cd ./${PROJ_FOLDER}/ && mv node_modules/ node_modules-/
#	@sudo rm -r ./${PROJ_FOLDER}/node_modules/

start-dev: ## Start the dev container stack
	@echo "Starting up dev container..."
	docker build -t ${PROJ_NAME}:dev --build-arg FOLDER_NAME=${PROJ_FOLDER} --target development .
# creating container for copying node_modules locally
	@docker container create --name tempdev ${PROJ_NAME}:dev
	@docker container cp tempdev:/app/node_modules ./${PROJ_FOLDER}/node_modules
	@docker container rm tempdev
#	now run in dev mode
	docker run --rm -it --name '${PROJ_NAME}-dev' -p 3000:3000 -v ${PWD}/${PROJ_FOLDER}:/app -e FOLDER_NAME=${PROJ_FOLDER} -w /app ${PROJ_NAME}:dev

start-prod: ## Start the prod container stack
	@echo "Starting up production container..."
	docker build -t ${PROJ_NAME}:prod --build-arg FOLDER_NAME=${PROJ_FOLDER} --target production .
	@make copy-prod

copy-prod: ## Copy from prod container
	@echo "Copying from production into extracted folder..."
	@docker container create --name temp ${PROJ_NAME}:prod
	docker container cp temp:/app/out ./${PROJ_OUTPUT}
#	docker container cp temp:/app ./${PROJ_OUTPUT}
	@docker container rm temp
