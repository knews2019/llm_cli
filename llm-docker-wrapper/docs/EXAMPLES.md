# Usage Examples for Secure LLM Docker Wrapper

This document provides various examples of how to use the `llm` CLI tool through the secure Docker wrapper.

## Prerequisites

-   Ensure you have completed the [Setup instructions](../README.md#setup) in the main README.
-   This includes having Docker running, `.env` file configured, and the image built (`make build`).
-   For examples using fragments from the `prompts` directory, make sure you have created `llm-docker-wrapper/prompts/` on your host.

## Basic Queries

These examples use the `./scripts/llm-safe` wrapper.

1.  **Simple question (default model):**
    ```bash
    ./scripts/llm-safe "What is the weather like in London?"
    ```

2.  **Using a specific model (e.g., OpenAI's GPT-4o Mini):**
    (Assumes `OPENAI_API_KEY` is set in `.env`)
    ```bash
    ./scripts/llm-safe -m gpt-4o-mini "Suggest three names for a new coffee shop."
    ```

3.  **Using another model (e.g., Anthropic's Claude 3 Haiku):**
    (Assumes `ANTHROPIC_API_KEY` is set in `.env`)
    ```bash
    ./scripts/llm-safe -m claude-3-haiku-20240307 "Write a short poem about the dawn."
    ```
    *(Note: Model names like `claude-3-haiku-20240307` are examples and may change. Refer to `llm models list` or the provider's documentation for current names.)*

4.  **Setting a system prompt:**
    ```bash
    ./scripts/llm-safe --system "You are a sarcastic assistant." "How is your day?"
    ```

5.  **Saving output to a file on the host:**
    ```bash
    ./scripts/llm-safe "Generate a list of 5 project ideas for a Python developer." > python_ideas.txt
    ```
    The file `python_ideas.txt` will be created in your current working directory on the host.

## Using Fragments and Files

Fragments are useful for providing context or longer pieces of text to the LLM.

1.  **Using a fragment from the `./prompts` directory:**
    -   First, create a file, e.g., `llm-docker-wrapper/prompts/code_to_review.py`:
        ```python
        # llm-docker-wrapper/prompts/code_to_review.py
        def add(a, b):
          return a + b
        ```
    -   Then, use it with `llm-safe`. The path is relative to your project root on the host.
        ```bash
        ./scripts/llm-safe -f ./prompts/code_to_review.py "Review this Python code for any issues."
        ```
    *Inside the container, `./prompts/code_to_review.py` is available at `/prompts/code_to_review.py` (read-only).*

2.  **Using a file from the current working directory (`/workspace`):**
    -   Create a file, e.g., `llm-docker-wrapper/my_text.txt`:
        ```
        This is a document I want to summarize. It contains important information.
        ```
    -   Use it with `llm-safe`.
        ```bash
        ./scripts/llm-safe -f my_text.txt "Provide a one-sentence summary of this document."
        ```
    *Here, `my_text.txt` is accessed from `/workspace/my_text.txt` inside the container.*

## Interactive Mode

For a more exploratory session or when you need to run multiple commands.

1.  **Start an interactive session:**
    ```bash
    ./scripts/llm-interactive
    ```
    This will give you a bash prompt inside the container (e.g., `llmuser@<container_id>:/workspace$`).

2.  **Run `llm` commands inside the interactive shell:**
    ```bash
    # Inside the container:
    llm --version
    llm models list # See available models based on your keys
    llm -m gpt-4o-mini "What are the key features of Python 3.11?"
    llm -f /prompts/code_to_review.py "Explain this code." # Note the path for shared prompts
    exit
    ```

## Using `Makefile`

The `Makefile` provides convenient shortcuts.

1.  **Run a simple query:**
    ```bash
    make run ARGS="'Hello LLM!'"
    ```
    *Note the extra quotes around `ARGS` if it contains spaces or special characters.*

2.  **Run with a model and system prompt:**
    ```bash
    make run ARGS="--system 'You are a historian.' -m gpt-3.5-turbo 'Tell me about the Roman Empire.'"
    ```

3.  **Start interactive mode via Makefile:**
    ```bash
    make run-interactive
    ```

## Multi-Model Examples (Conceptual)

If you have multiple API keys configured (e.g., OpenAI and Anthropic), you can switch between models.

```bash
# Query OpenAI
./scripts/llm-safe -m gpt-4o-mini "What is the specialty of OpenAI?"

# Query Anthropic
./scripts/llm-safe -m claude-3-sonnet-20240229 "What is the specialty of Anthropic?"
```

## Example Shell Scripts

Refer to the `examples/` directory in the project for executable shell scripts that demonstrate some of these use cases:
-   `examples/basic-usage.sh`
-   `examples/with-fragments.sh`
-   `examples/multi-model.sh` (conceptual, adapt with your actual model names)

To run them, make them executable (`chmod +x examples/*.sh`) and then execute, for example:
```bash
./examples/basic-usage.sh
```
Remember to have your `.env` file set up.
