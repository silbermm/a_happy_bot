APP_NAME ?= "ahappybot"
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`
DOCKER_REPO ?= "silbermm"


build: ## Build the Docker image
	docker image build --build-arg APP_VSN=$(APP_VSN) \
		-t $(DOCKER_REPO)/$(APP_NAME):$(APP_VSN) \
		-t $(DOCKER_REPO)/$(APP_NAME):latest .

push: ## Push to Docker
	docker push $(DOCKER_REPO)/$(APP_NAME):$(APP_VSN) && docker push $(DOCKER_REPO)/$(APP_NAME):latest

run: ## Run the app in Docker
	docker container run --env-file=.env --rm -it --name $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest
