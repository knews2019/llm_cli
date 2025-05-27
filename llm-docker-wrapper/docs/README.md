# Secure LLM Docker Wrapper

This project provides a secure Docker wrapper for running the `llm` CLI tool. It aims to provide a safe, isolated environment for interacting with Large Language Models (LLMs), especially when dealing with potentially untrusted prompts, fragments, or experimental features.

## Features

- **Security Isolation**: Runs `llm` in a container with minimal privileges.
- **Non-Root User**: Container operates as a non-root user (`llmuser`).
- **Network Controls**: Designed to allow API calls to providers like OpenAI/Anthropic while limiting other unintended network access (though default bridge network still allows general outbound).
- **File System Protection**:
    - Read-only access to shared prompt files (optional).
    - Isolated configuration directory (`~/.config/llm`) persistent via a Docker volume.
    - Current working directory mounted for reading prompts and writing outputs.
- **Tool Safety**: Configuration to disable custom tools/functions by default (`LLM_DISABLE_CUSTOM_TOOLS=true` in `.env`).
- **Resource Limits**: Basic CPU and memory limits to prevent abuse.
- **Ease of Use**: Includes wrapper scripts (`llm-safe`, `llm-interactive`) and a `Makefile`.

## Prerequisites

- Docker Engine (with Docker Compose v2 or standalone `docker-compose` v1).
- Git (for cloning, optional).
- A `.env` file with your API keys (see Setup).

## Setup

1.  **Clone the repository (or download the files):**
    ```bash
    # git clone <repository_url>
    # cd llm-docker-wrapper
    ```

2.  **Create and configure your environment file:**
    Copy the template to `.env`:
    ```bash
    cp .env.template .env
    ```
    Edit `.env` and add your API keys (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`).
    ```ini
    # .env
    OPENAI_API_KEY=your_actual_openai_key_here
    ANTHROPIC_API_KEY=your_actual_anthropic_key_here
    LLM_DEFAULT_MODEL=gpt-4o-mini # Optional: set a default model
    LLM_DISABLE_CUSTOM_TOOLS=true # Recommended for security
    ```
    **IMPORTANT**: Do not commit your `.env` file with actual keys to version control. Add `.env` to your `.gitignore` file if it's not already there.

3.  **Build the Docker image:**
    This needs to be done once initially and whenever you change the `Dockerfile` or `requirements.txt`.
    ```bash
    make build
    ```
    Alternatively:
    ```bash
    docker-compose build
    ```

## Usage

There are several ways to use the wrapper:

### 1. Using `llm-safe` script (Recommended for daily use)

This script handles running `llm` commands within the Docker container.

-   **Basic query:**
    ```bash
    ./scripts/llm-safe "What is the capital of France?"
    ```

-   **Using a specific model:**
    ```bash
    ./scripts/llm-safe -m gpt-4o-mini "Translate 'hello' to Spanish"
    ```

-   **With prompts/fragments (from the `prompts` directory):**
    First, ensure you have a `prompts` directory in your project root (`llm-docker-wrapper/prompts`).
    Create a prompt file, e.g., `llm-docker-wrapper/prompts/my_context.txt`:
    ```
    This is some context for the LLM.
    ```
    Then use it:
    ```bash
    ./scripts/llm-safe -f ./prompts/my_context.txt "Summarize the provided context."
    ```
    *Note: The path `./prompts/my_context.txt` is relative to your host machine's project root. Inside the container, this maps to `/prompts/my_context.txt`.*

-   **Saving output:**
    ```bash
    ./scripts/llm-safe "Generate a short story about a robot" > story.txt
    ```
    The `story.txt` file will appear in your current working directory on the host.

### 2. Using `llm-interactive` script

For an interactive bash shell within the container (e.g., for complex setups or debugging):
```bash
./scripts/llm-interactive
```
Inside this shell, you can run `llm` commands directly:
```bash
# Inside the container shell
llm "List available models"
llm -m claude-3-haiku "What's new in AI?"
exit
```

### 3. Using `Makefile`

The `Makefile` provides convenience targets:

-   **Run a command:**
    ```bash
    make run ARGS="What is quantum computing?"
    make run ARGS="--system 'You are a helpful assistant' 'Explain black holes'"
    ```

-   **Interactive session:**
    ```bash
    make run-interactive
    ```

-   **Build image:**
    ```bash
    make build
    ```

-   **Clean up:**
    Removes containers, networks, and the `llm-config` volume.
    ```bash
    make clean
    ```

### 4. Using `docker-compose` directly

You can also invoke `docker-compose` (or `docker compose`) commands directly:
```bash
docker-compose run --rm llm "Tell me a joke"
docker-compose run --rm -it llm bash
```

## Project Structure

-   `Dockerfile`: Defines the Docker image.
-   `docker-compose.yml`: Configures the Docker service.
-   `.env.template`: Template for environment variables (API keys, etc.).
-   `requirements.txt`: Python dependencies for the `llm` tool.
-   `Makefile`: For easy management (build, run, clean).
-   `scripts/`: Contains `llm-safe` and `llm-interactive` wrapper scripts.
-   `docs/`: Documentation files.
-   `examples/`: Example usage scripts.
-   `prompts/` (user-created): Recommended directory for read-only prompt files.

## Security

Please refer to `docs/SECURITY.md` for detailed security considerations and how this wrapper addresses them.

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for common issues and solutions.
