
all: up

up:
	@mkdir -p /home/dzasenko/data/mariadb
	docker compose -f srcs/docker-compose.yml build --no-cache mariadb
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	rm -rf /home/dzasenko/data/mariadb
	docker system prune -af

re: fclean all

.PHONY: all up down clean fclean re


