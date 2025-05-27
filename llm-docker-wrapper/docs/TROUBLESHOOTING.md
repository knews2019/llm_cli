# Troubleshooting

This page lists common issues and their solutions when using the Secure LLM Docker Wrapper.

## Docker / Docker Compose Issues

### 1. `docker-compose` or `docker compose` command not found
-   **Error Message:** `Error: docker-compose (or docker compose) is required but not found.` or `make: docker-compose: Command not found.`
-   **Solution:**
    -   Ensure Docker Desktop or Docker Engine with the Compose plugin is installed correctly.
    -   For Linux, you might need to install `docker-compose-plugin` or the standalone `docker-compose`. Refer to the official Docker documentation.
    -   Verify that the command is in your system's PATH.

### 2. Permission Denied when running Docker commands
-   **Error Message:** `Got permission denied while trying to connect to the Docker daemon socket...`
-   **Solution (Linux):**
    -   Add your user to the `docker` group: `sudo usermod -aG docker $USER`.
    -   **Important:** You will need to log out and log back in for this change to take effect.
    -   Alternatively, run Docker commands with `sudo` (not generally recommended for everyday use).

### 3. Build fails due to network issues
-   **Error Message:** Errors during `apt-get update` or `pip install` like "Could not resolve host..."
-   **Solution:**
    -   Check your internet connection.
    -   If you are behind a proxy, configure Docker to use your proxy settings. See Docker's documentation on proxy configuration.
    -   Ensure your DNS server is correctly configured.

### 4. `make clean` fails to remove image
-   **Message:** `Error response from daemon: conflict: unable to remove repository reference "llm-secure-wrapper" (must force) - container ... is using its referenced image`
-   **Solution:** `make clean` first runs `docker-compose down -v` which should stop and remove containers. If an image is still in use by a stopped container that wasn't managed by this compose file, or if there are other tags pointing to it, it might not be removed.
    - You can try `docker rmi llm-secure-wrapper` after ensuring no containers use it.
    - `docker system prune -a -f` is more aggressive and will remove all unused images.

## LLM Tool & Script Issues

### 1. API Key Not Found / Authentication Error
-   **Error Message (from `llm` tool):** Typically includes "API key not provided," "Authentication error," or similar.
-   **Solution:**
    -   Ensure you have copied `.env.template` to `.env`.
    -   Verify that `OPENAI_API_KEY` and/or `ANTHROPIC_API_KEY` (or other relevant keys) are correctly set in your `.env` file.
    -   Make sure the `.env` file is in the root of the `llm-docker-wrapper` project directory. The `docker-compose.yml` is configured to pick it up from there.
    -   If you've recently updated `.env`, you might need to stop and restart the container (e.g., `make clean && make build` if changes affect the build, or just re-run the command).

### 2. `./scripts/llm-safe: Permission denied`
-   **Error Message:** `bash: ./scripts/llm-safe: Permission denied`
-   **Solution:** The script does not have execute permissions.
    -   Run `chmod +x ./scripts/llm-safe ./scripts/llm-interactive`.
    -   The initial setup should handle this, but it might be lost if files are copied without preserving permissions.

### 3. Cannot find `llm` command inside container (interactive mode)
-   **Error Message (inside container):** `bash: llm: command not found`
-   **Solution:**
    -   This usually indicates an issue with the `PATH` environment variable or the installation of `llm` in the Docker image.
    -   Check the `Dockerfile` to ensure `/home/llmuser/.local/bin` is added to `PATH`.
    -   Verify that `pip install --user -r requirements.txt` completed successfully during the `docker build` process. Check the build logs.
    -   Ensure `requirements.txt` correctly lists the `llm` package.

### 4. File not found when using `-f ./prompts/somefile.txt`
-   **Error Message (from `llm` tool):** "File not found" or similar.
-   **Solution:**
    -   Ensure the `prompts` directory exists in the root of your `llm-docker-wrapper` project on your host machine.
    -   The path provided to `llm-safe` should be relative to your project root on the host (e.g., `./prompts/myfile.txt`).
    -   The `docker-compose.yml` mounts `./prompts` on the host to `/prompts` in the container (read-only). So, inside the container, the tool will see it as `/prompts/myfile.txt`. The `llm` tool itself might need to be aware of this, or you might need to adjust paths if `llm` expects paths relative to `/workspace`.
    -   By default, `llm-safe` runs commands with `/workspace` as the working directory. If `llm` resolves file paths relative to the working directory, you might need to use `llm -f /prompts/somefile.txt ...` when inside the interactive shell, or adjust how `llm-safe` passes paths. However, the provided `llm-safe` script passes arguments as is, and the working directory is `/workspace` (host's `.`)
    -   **Test:** Create `llm-docker-wrapper/prompts/test.txt`. Run `./scripts/llm-safe -f ./prompts/test.txt "Say hi"`. If `llm` complains, it might be how it handles paths. The `llm` tool should ideally handle paths relative to the current working directory (`/workspace`) or absolute paths.

## Other

### 1. Resource Limits Too Low
-   **Symptom:** Container crashes unexpectedly, or `llm` commands are killed.
-   **Solution:** The default CPU (`0.5`) and memory (`1G`) limits in `docker-compose.yml` might be too restrictive for some models or complex tasks.
    -   Edit `docker-compose.yml` and increase these values under `deploy.resources.limits`.
    -   Then, rebuild or restart the service if necessary (usually just re-running `make run` or `llm-safe` is enough as `docker-compose run` creates a new container).

---

If you encounter other issues, please check the following:
-   Logs from the Docker build process: `make build` or `docker-compose build --no-cache`.
-   Logs from the container when a command is run (though `llm-safe` runs with `--rm`, so logs are usually just output). For services, `docker-compose logs llm`.
-   The official documentation for the `llm` CLI tool.
