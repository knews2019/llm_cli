# Stage 1: Build stage
FROM python:3.11-slim as builder
WORKDIR /build
COPY requirements.txt .
# Install dependencies as user 'builderuser' to avoid running pip as root
RUN useradd -m builderuser && chown builderuser:builderuser .
USER builderuser
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime stage
FROM python:3.11-slim
# Create non-root user llmuser with UID 1000 and group llmuser with GID 1000
RUN groupadd -g 1000 llmuser &&     useradd -u 1000 -g 1000 -ms /bin/bash llmuser

# Copy installed packages from builder stage
COPY --from=builder /home/builderuser/.local /home/llmuser/.local

# Install ca-certificates and remove unnecessary packages
RUN apt-get update &&     apt-get install -y --no-install-recommends ca-certificates &&     apt-get autoremove -y &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

# Set PATH for llm tool
ENV PATH="/home/llmuser/.local/bin:${PATH}"

# Create and set permissions for workspace and config directories
RUN mkdir -p /workspace /home/llmuser/.config/llm &&     chown -R llmuser:llmuser /home/llmuser /workspace &&     chmod 750 /home/llmuser &&     chmod 750 /workspace &&     chmod 770 /home/llmuser/.config/llm # More permissive for llm to write config

# Security: Attempt to remove shell access for llmuser
# This might fail if the user is actively used by some process, so use || true
# The primary defense is not running as root and docker's isolation.
RUN usermod -s /usr/sbin/nologin llmuser || true

USER llmuser
WORKDIR /workspace

# Healthcheck to ensure llm tool is working
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3   CMD llm --version || exit 1

# Default command (optional, can be overridden by docker-compose)
# ENTRYPOINT ["llm"]
