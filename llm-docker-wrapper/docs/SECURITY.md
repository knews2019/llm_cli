# Security Considerations for LLM Docker Wrapper

This document outlines the security measures implemented in this LLM Docker wrapper and provides guidance for secure usage.

## Implemented Security Measures

1.  **Container runs as Non-Root User:**
    -   The `Dockerfile` creates a dedicated non-root user `llmuser` (UID/GID 1000).
    -   The `llm` process and any shell access (if `llm-interactive` is used) run under this user.
    -   This significantly reduces the impact of a potential container escape or process compromise.

2.  **Minimal Base Image:**
    -   Uses `python:3.11-slim` as the base, which is smaller and has fewer packages than full OS images, reducing the attack surface.
    -   Unnecessary packages are removed after installation (`apt-get autoremove -y && apt-get clean`).

3.  **Package Pinning & Integrity (Implicit):**
    -   While not explicitly using hash pinning in `requirements.txt` for this example, in a production scenario, pinning versions (`llm==X.Y.Z`) and using hash-checking options with `pip install` would be recommended for supply chain security.

4.  **Network Controls:**
    -   The `docker-compose.yml` defines a bridge network (`llm-network`). This allows outbound connections (e.g., to OpenAI/Anthropic APIs).
    -   **Limitation**: A default bridge network does *not* inherently restrict *which* external IPs can be contacted. For stricter egress filtering, a more advanced setup (e.g., a proxy container or specific firewall rules on the host/network) would be needed.
    -   `cap_drop: - ALL`: All Linux capabilities are dropped by default. `NET_BIND_SERVICE` is *not* added by default, as the CLI tool is not expected to host services. If it were, only necessary capabilities should be added.

5.  **File System Permissions & Isolation:**
    -   **Workspace (`/workspace`):** Mounted read-write (`rw`) from the host's current directory. This is necessary for the tool to read prompts from the current directory and write outputs. Users should be aware that the containerized process can write to this directory.
    -   **Prompts Directory (`/prompts`):** An *optional* shared prompts directory can be mounted read-only (`ro`) from `./prompts` on the host. This is the recommended way to provide a library of trusted prompts.
    -   **Config Directory (`/home/llmuser/.config/llm`):** Mounted as a named volume (`llm-config`). This isolates LLM configuration (like history, keys if stored by `llm` itself) from the host and other containers, while allowing it to persist. Permissions within the container are set for `llmuser`.
    -   Container user `llmuser` has restricted permissions on its own home directory and the workspace.

6.  **No Shell Access (Hardening Attempt):**
    -   The `Dockerfile` includes `RUN usermod -s /usr/sbin/nologin llmuser || true`. This attempts to prevent `llmuser` from having a login shell.
    -   **Note**: If `llm-interactive` is used, it explicitly starts `bash`, bypassing this for that interactive session. The primary defense remains that the user is non-root.

7.  **Resource Limits:**
    -   `docker-compose.yml` sets memory and CPU limits (`memory: 1G`, `cpus: "0.5"`) to prevent the container from consuming excessive host resources (DoS protection). These can be adjusted as needed.

8.  **Secrets Management:**
    -   API keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`) are passed as environment variables from a `.env` file on the host.
    -   The `.env` file is explicitly *not* to be committed to version control. `.env.template` is provided as a safe template.
    -   This method is common, but for higher security environments, consider solutions like Docker secrets or HashiCorp Vault, especially in orchestrated environments.

9.  **Tool Execution Restrictions (`LLM_DISABLE_CUSTOM_TOOLS`):**
    -   The `llm` tool might support custom plugins or tools that can execute arbitrary code.
    -   The `.env.template` sets `LLM_DISABLE_CUSTOM_TOOLS=true` by default. It's assumed the `llm` tool respects this environment variable.
    -   **Users should only disable this if they fully trust the tools they are enabling.** This is a critical security consideration.

10. **Multi-Stage Docker Build:**
    -   The `Dockerfile` uses a multi-stage build. The first stage (`builder`) installs dependencies. The final stage copies only the necessary artifacts (installed packages) and does not include build tools or caches, resulting in a smaller, more secure image.

11. **Healthcheck:**
    -   A `HEALTHCHECK` instruction in the `Dockerfile` (and corresponding `healthcheck` in `docker-compose.yml`) verifies that the `llm` command is runnable. This helps detect broken container images or runtime issues.

## User Responsibilities & Best Practices

-   **Keep `.env` Secure:** Never commit your `.env` file with API keys. Ensure it has restrictive file permissions on your host.
-   **Understand Mounted Volumes:** Be aware of what directories are mounted and their permissions (e.g., `/workspace` is read-write). Don't run prompts from untrusted sources if they might try to exploit file system access within this writable directory.
-   **Custom Tools/Plugins:** Exercise extreme caution if you disable `LLM_DISABLE_CUSTOM_TOOLS`. Only use tools from trusted sources.
-   **Prompt Injection:** Be aware of prompt injection risks, where parts of a prompt might be interpreted as commands or instructions by the LLM, potentially leading to unintended behavior. This wrapper helps isolate the system *if* the LLM is compromised to execute code, but it doesn't prevent prompt injection itself.
-   **Regular Updates:**
    -   Keep the `llm` tool updated by rebuilding the image (`make build`) after updating `requirements.txt`.
    -   Keep Docker and your host system updated.
-   **Review `docker-compose.yml` and `Dockerfile`:** Understand the configurations before running.
-   **Network Policies:** For production or sensitive environments, implement stricter network policies (e.g., host firewall rules, proxy for API calls) to limit outbound connections from the container.

This wrapper provides a strong baseline for security, but ultimate security also depends on user awareness and safe practices.
