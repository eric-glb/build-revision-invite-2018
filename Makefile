SHELL := bash
MAKEFLAGS += --no-print-directory
MINISERVE_URL = https://github.com/svenstaro/miniserve/releases/download/v0.27.1/miniserve-0.27.1-x86_64-unknown-linux-musl
NIN_PKG = ninjadev-nin@24.0.0
CONTAINER_NAME = revision-invite-2018

define heredoc_help
cat <<'EOF'

  make [ help | all | prerequisites | build | run | serve | clean |
         docker-build | docker-stop | docker-run | docker-clean | clean-all ]

EOF
endef
export heredoc_help

.PHONY: help all prerequisites build run serve clean docker-build docker-stop docker-run docker-clean clean-all



help:
	@eval "$$heredoc_help"

all: clean build run

prerequisites:
	@npm config set fund false audit false update-notifier false loglevel error
	@if ! [[ -w $$(npm root -g) ]]; then echo -e "\nERROR: no write access to global libraries folder $$(npm root -g)\n"; exit 1; fi
	@npm ls -g | grep -q ${NIN_PKG} || npm install -g ${NIN_PKG}

build:
	@npm ls -g | grep -q ${NIN_PKG} || make prerequisites
	cd revision-invite-2018; nin compile --no-closure-compiler --no-tracking

run: 
	@[ -e revision-invite-2018/bin/no-invitation.zip ] || make build
	cd revision-invite-2018; echo -e "\nConnect to http://127.0.0.1:8080\n"; nin run 8080

serve: 
	@[ -e revision-invite-2018/bin/no-invitation.zip ] || make build
	@touch revision-invite-2018/bin/favicon.ico
	@[ -x ./miniserve ] || curl -sL ${MINISERVE_URL} > ./miniserve && chmod +x ./miniserve
	@./miniserve -p 8080 -F -t $$(pwd | awk -F/ '{print $$NF "/bin"}') revision-invite-2018/bin/

clean:
	@rm -rf revision-invite-2018/{bin,gen} miniserve



docker-build:
	@docker build -t ${CONTAINER_NAME} -f Dockerfile .

docker-stop:
	@docker ps --format "{{.Names}}" | grep -qE "^${CONTAINER_NAME}$$" && docker rm -f ${CONTAINER_NAME} &>/dev/null || true

docker-run: docker-stop
	@docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${CONTAINER_NAME}:latest" || make docker-build
	docker run --rm --detach --publish=8080:8080 --name ${CONTAINER_NAME} ${CONTAINER_NAME}
	@echo -e "\nConnect to http://127.0.0.1:8080\n"

docker-clean: docker-stop
	@docker rmi ${CONTAINER_NAME} &>/dev/null || true
	@docker buildx prune -f -a    &>/dev/null || true



clean-all:
	make clean
	@rm -rf $$(npm ls -gp | grep node_modules/ninjadev-nin$$)
	make docker-clean
