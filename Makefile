# Makefile:
all: up

up:
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress
	sudo chown -R $(USER):$(USER) /home/$(USER)/data
	docker compose -f srcs/docker-compose.yml build --no-cache mariadb wordpress
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

rebuild_mariadb:
	# Останавливаем и удаляем контейнеры и тома
	docker compose -f srcs/docker-compose.yml down -v
	# Удаляем образы, связанные с mariadb
	docker compose -f srcs/docker-compose.yml build --no-cache mariadb
	# Запускаем контейнеры заново
	docker compose -f srcs/docker-compose.yml up -d

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo chown -R $(USER):$(USER) /home/$(USER)/data
	sudo rm -rf /home/$(USER)/data
	docker system prune -af

re: fclean all

.PHONY: all up down clean fclean re

