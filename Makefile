NAME = inception
COMPOSEFILE = srcs/docker-compose.yml

#####################

all: build up

build: create_volumes
	docker compose -f $(COMPOSEFILE) build

up:
	docker compose -f $(COMPOSEFILE) up -d

create_volumes:
	mkdir -p srcs/volumes/mariadb_data srcs/volumes/wordpress_data

down:
	docker compose -f $(COMPOSEFILE) down
	
clean: 
	docker compose -f $(COMPOSEFILE) down -v

# requires sudo
fclean: clean
	rm -rf srcs/volumes/mariadb_data srcs/volumes/wordpress_data
	docker system prune -af --volumes

re : fclean all

.PHONY: all build up down clean fclean re

### add a small echo that shows users and password ready to use
