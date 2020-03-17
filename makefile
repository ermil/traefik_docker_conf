
BACKUP_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/../backup
# get the current directory name (without path)
PROJECT_NAME := $(shell basename ${PWD})

# il est possible de changer cette valeur en la définissant autrement dans un fichier
# .make.env ou par un argument passé au makefile.
DOCKER_COMPOSE_FILE ?= docker-compose.yml

CIBLE = traefik

TIMESTAMP := $(shell date +%Y%m%d%H%M%S)

init:
	if [ "$$(systemctl is-active docker)" != active ]; then sudo systemctl start docker.service; else echo "docker already running"; fi
	if [ "$$(docker network ls --filter "name=^traefik_network$$" --format '{{.Name}}')" != "traefik_network" ]; then docker network create traefik_network; else echo "traefik_network already exist"; fi

up: init
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d $(CIBLE)

stop:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) stop $(CIBLE)

down:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down

backup:
	tar -cJpvf $(BACKUP_DIR)/$(PROJECT_NAME)_$(TIMESTAMP)_conf.tar.xz -C $(CURDIR) conf $(DOCKER_COMPOSE_FILE) makefile

clean:

update:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) pull $(CIBLE)
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d $(CIBLE)
