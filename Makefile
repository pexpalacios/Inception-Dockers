NAME = inception
COMPOSEFILE = srcs/docker-compose.yml

######

all: build

build:
	docker compose -f $(DOCKERFILE) build

up:
	docker compose -f $(DOCKERFILE) up -d

down:
	docker compose -f $(DOCKERFILE) down
	
clean: 
	docker compose -f $(DOCKERFILE) down -v

fclean: clean
	docker system prune -af --volumes

re : fclean all

.PHONY: all build up down clean fclean re


### may add stuff like see the db with a command or some
