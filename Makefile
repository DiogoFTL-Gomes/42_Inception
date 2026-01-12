
NAME		= inception
COMPOSE		= docker compose
COMPOSE_FILE	= srcs/docker-compose.yml
ENV_FILE	= srcs/.env

# Commands

all: up

up:
	$(COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE) up -d --build

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

stop:
	$(COMPOSE) -f $(COMPOSE_FILE) stop

start:
	$(COMPOSE) -f $(COMPOSE_FILE) start

restart:
	$(COMPOSE) -f $(COMPOSE_FILE) restart

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

ps:
	$(COMPOSE) -f $(COMPOSE_FILE) ps

# Cleaning

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v

fclean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v
	docker system prune -af

re: fclean all

.PHONY: all up down stop start restart logs ps clean fclean re
