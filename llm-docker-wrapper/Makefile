.PHONY: build run run-interactive clean logs help

# Determine Docker Compose command
COMPOSE_CMD := docker-compose
ifeq (, $(shell command -v docker-compose 2> /dev/null))
    ifeq (, $(shell command -v docker compose 2> /dev/null))
        $(error "Neither 'docker-compose' nor 'docker compose' (v2) found. Please install Docker Compose.")
    else
        COMPOSE_CMD := docker compose
    endif
endif

# Default LLM command arguments if ARGS is not set
ARGS ?= --help

build:
	@echo "Building the LLM Docker image..."
	$(COMPOSE_CMD) build

run:
	@echo "Running LLM command in Docker with ARGS: $(ARGS)"
	$(COMPOSE_CMD) run --rm llm $(ARGS)

run-interactive:
	@echo "Starting interactive LLM session in Docker..."
	$(COMPOSE_CMD) run --rm -it llm bash

clean:
	@echo "Cleaning up Docker containers, volumes, and networks..."
	$(COMPOSE_CMD) down -v --remove-orphans
	@echo "Pruning unused Docker images (use with caution if you have other unused images)..."
	# docker system prune -f # Be cautious with this; it removes all unused images.
	# A more targeted approach might be to remove the specific image if tagged:
	# docker rmi llm-secure-wrapper || true # Remove if image exists
	@echo "Clean-up complete. Consider running 'docker system prune -af' if you want to free up more space."


logs:
	@echo "Fetching logs for the LLM service (if running detached)..."
	$(COMPOSE_CMD) logs -f llm

help:
	@echo "Available commands:"
	@echo "  make build             - Build the Docker image for the LLM environment."
	@echo "  make run ARGS='...'    - Run an LLM command in Docker (e.g., ARGS='"Hello world" --model gpt-4'). Defaults to ARGS='--help'."
	@echo "  make run-interactive   - Start an interactive bash shell within the LLM container."
	@echo "  make clean             - Remove containers, networks, and volumes created by docker-compose. Also suggests image cleanup."
	@echo "  make logs              - Follow logs from the LLM service (useful if running in detached mode)."
	@echo ""
	@echo "Wrapper scripts in ./scripts directory:"
	@echo "  ./scripts/llm-safe ARGS...        - Wrapper to run LLM commands (e.g., ./scripts/llm-safe 'How does AI work?')."
	@echo "  ./scripts/llm-interactive       - Wrapper to start an interactive bash session in the container."
	@echo ""
	@echo "Before first use:"
	@echo "  1. Copy '.env.template' to '.env' (i.e., 'cp .env.template .env')."
	@echo "  2. Edit '.env' to add your API keys (e.g., OPENAI_API_KEY)."
