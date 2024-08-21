SHELL := bash
MAKEFLAGS += --no-print-directory

CLEAR=\033[0;m
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
SEP="────────────────────────────────────────────────────────────────────────────────"


MINISERVE_URL = https://github.com/svenstaro/miniserve/releases/download/v0.27.1/miniserve-0.27.1-x86_64-unknown-linux-musl
NIN_PKG = ninjadev-nin@24.0.0
CONTAINER_NAME = revision-invite-2018

define heredoc_help
echo -e "\n${YELLOW}${SEP}"
cat <<'EOF'

  make [ help | all | prerequisites | build | run | serve | clean |
         docker-build | docker-run | docker-build-dev | docker-run-dev | 
         docker-stop | docker-clean | clean-all ]

EOF

echo -e "${SEP}${CLEAR}\n"
endef
export heredoc_help




.PHONY: help all prerequisites build run serve clean docker-build docker-build-dev docker-stop docker-run docker-run-dev docker-clean clean-all

help:
	@eval "$$heredoc_help"

all: clean 
	@make build
	@make docker-build
	@make docker-build-dev
	@echo -e "\n${SEP}\n\nNow:\n\n${GREEN}  make [ run | serve | docker-run | docker-run-dev ]${CLEAR}\n\n${SEP}\n"



prerequisites:
	@echo -e "\n${SEP}\n${GREEN}Set prerequisites...${CLEAR}\n${SEP}\n"
	@npm config set fund false audit false update-notifier false loglevel notice
	@if ! [[ -w $$(npm root -g) ]]; then echo -e "\n${SEP}\n${RED}ERROR${CLEAR}: no write access to global libraries folder $$(npm root -g)\n${SEP}\n"; exit 1; fi
	@npm ls -g | grep -q ${NIN_PKG} || npm_config_loglevel=silent npm install -g ${NIN_PKG}

build:
	@npm ls -g | grep -q ${NIN_PKG} || make prerequisites
	@echo -e "\n${SEP}${GREEN}\nBuild locally...${CLEAR}\n${SEP}\n"
	cd revision-invite-2018; nin compile --no-closure-compiler --no-tracking

run: 
	@[ -e revision-invite-2018/bin/no-invitation.zip ] || make build
	@echo -e "\n${SEP}\nConnect to ${GREEN}http://127.0.0.1:8080${CLEAR}\n${SEP}\n"
	cd revision-invite-2018; nin run 8080 

serve:
	@[ -e revision-invite-2018/bin/no-invitation.zip ] || make build
	@touch revision-invite-2018/bin/favicon.ico
	@[ -x ./miniserve ] || curl -sL ${MINISERVE_URL} > ./miniserve && chmod +x ./miniserve
	@./miniserve -p 8080 -v -F -t $$(pwd | awk -F/ '{print $$NF "/bin"}') revision-invite-2018/bin/



docker-build:
	@echo -e "\n${SEP}\n${GREEN}Build docker image ${CONTAINER_NAME}...${CLEAR}\n${SEP}\n"
	@docker build -t ${CONTAINER_NAME} -f Dockerfile .
	@echo ${SEP}
	@docker image ls --filter=reference=${CONTAINER_NAME}
	@echo ${SEP}

docker-build-dev:
	@echo -e "\n${SEP}\n${GREEN}Build docker image ${CONTAINER_NAME}-dev...${CLEAR}\n${SEP}\n"
	@docker build -t ${CONTAINER_NAME}-dev -f Dockerfile-dev .
	@echo ${SEP}
	@docker image ls --filter=reference=${CONTAINER_NAME}-dev
	@echo ${SEP}

docker-stop:
	@docker ps --format "{{.Names}}" | grep -qE "^${CONTAINER_NAME}$$" && docker rm -f ${CONTAINER_NAME} &>/dev/null || true
	@docker ps --format "{{.Names}}" | grep -qE "^${CONTAINER_NAME}-dev$$" && docker rm -f ${CONTAINER_NAME}-dev &>/dev/null || true

docker-run: docker-stop
	@docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${CONTAINER_NAME}:latest" || make docker-build
	@echo -e "\n${SEP}\n${GREEN}Run docker container ${CONTAINER_NAME}...${CLEAR}\n"
	@docker run --rm --detach --publish=8080:8080 --name=${CONTAINER_NAME} ${CONTAINER_NAME} &>/dev/null
	@echo -e "Connect to ${GREEN}http://127.0.0.1:8080${CLEAR}\n\nType: \`${YELLOW}make docker-stop${CLEAR}\` to stop this container.\n${SEP}\n"

docker-run-dev: docker-stop
	@docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${CONTAINER_NAME}-dev:latest" || make docker-build-dev
	@echo -e "\n${SEP}\n${GREEN}Run docker container ${CONTAINER_NAME}-dev...${CLEAR}\n"
	@docker run --rm --detach --publish=8080:8080 --volume=$$PWD/revision-invite-2018:/app --name=${CONTAINER_NAME}-dev ${CONTAINER_NAME}-dev &>/dev/null
	@echo -e "Connect to ${GREEN}http://127.0.0.1:8080${CLEAR}\n\nType: \`${YELLOW}make docker-stop${CLEAR}\` to stop this container.\n${SEP}\n"



clean:
	@rm -rf revision-invite-2018/{bin,gen} miniserve

docker-clean: docker-stop
	@docker rmi ${CONTAINER_NAME}                      &>/dev/null || true
	@docker rmi ${CONTAINER_NAME}-dev                  &>/dev/null || true
	@docker rmi $(docker images -f "dangling=true" -q) &>/dev/null || true
	@docker buildx prune -f -a                         &>/dev/null || true

clean-all:
	make clean
	@rm -rf $$(npm ls -gp | grep node_modules/ninjadev-nin$$)
	make docker-clean


.PHONY: make.gif
make.gif:
	@type -p vhs &>/dev/null && PS1="\$$ " vhs assets/make.tape
	@type -p chafa &>/dev/null && chafa -f sixel assets/make.gif

