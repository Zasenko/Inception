all: build up

build:
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress
	sudo chown -R $(USER):$(USER) /home/$(USER)/data
	
up:
	docker compose -f srcs/docker-compose.yml build --no-cache mariadb wordpress nginx
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo rm -rf /home/$(USER)/data/mariadb
	sudo rm -rf /home/$(USER)/data/wordpress
	docker system prune -f

re: fclean all

.PHONY: all build up down clean fclean re

