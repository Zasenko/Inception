COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

all: build up

build:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	sudo chown -R $(USER):$(USER) $(DATA_PATH)

# ---------------	
up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down
# ---------------
start:
	$(COMPOSE) start

start-db:
	$(COMPOSE) start mariadb

start-wp:
	$(COMPOSE) start wordpress

start-nginx:
	$(COMPOSE) start nginx


# ---------------
stop:
	$(COMPOSE) stop

stop-db:
	$(COMPOSE) stop mariadb

stop-wp:
	$(COMPOSE) stop wordpress

stop-nginx:
	$(COMPOSE) stop nginx

# ---------------
re:
	$(COMPOSE) build
	$(COMPOSE) up -d

restart: stop start
	
rebuild: clean
	$(COMPOSE) build
	$(COMPOSE) up -d

# ---------------
clean:
	$(COMPOSE) down -v
	docker system prune -f

fclean: clean
	sudo rm -rf $(DATA_PATH)/mariadb
	sudo rm -rf $(DATA_PATH)/wordpress
	docker system prune -a

# ---------------
logs:
	$(COMPOSE) logs

logs-db:
	$(COMPOSE) logs mariadb

logs-wp:
	$(COMPOSE) logs wordpress

logs-nginx:
	$(COMPOSE) logs nginx

# ---------------
ps:
	$(COMPOSE) ps

status:
	docker ps -a

top:
	docker top nginx
	docker top wordpress
	docker top mariadb

# ---------------

volumes:
	docker volume ls

inspect-vol-db:
	docker volume inspect mariadb_data

inspect-vol-wp:
	docker volume inspect wordpress_data

# ---------------
networks:
	docker network ls

inspect-net:
	docker network inspect inception_network


# ---------------
inspect-nginx:
	docker inspect nginx

inspect-wp:
	docker inspect wordpress

inspect-db:
	docker inspect mariadb
# ---------------

bash-nginx:
	docker exec -it nginx bash

bash-wp:
	docker exec -it wordpress bash

bash-db:
	docker exec -it mariadb bash

# ---------------
.PHONY: all build up down start start-db start-wp start-nginx stop stop-db stop-wp stop-nginx re restart rebuild clean fclean logs logs-db logs-wp logs-nginx ps status top volumes inspect-vol-db inspect-vol-wp networks inspect-net inspect-nginx inspect-wp inspect-db bash-nginx bash-wp bash-db
