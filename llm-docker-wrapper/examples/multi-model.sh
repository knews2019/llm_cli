#!/bin/bash
# examples/multi-model.sh
# This script demonstrates querying different models.
# Ensure corresponding API keys (OPENAI_API_KEY, ANTHROPIC_API_KEY) are in your .env file.

echo "Querying OpenAI model (e.g., gpt-4o-mini)..."
../scripts/llm-safe -m gpt-4o-mini "What was the first successful mission to Mars?"

echo ""
echo "Querying Anthropic model (e.g., claude-3-haiku)..."
../scripts/llm-safe -m claude-3-haiku-20240307 "What are some ethical considerations in AI development?"

echo ""
echo "To see a list of available models based on your keys, you can run:"
echo "  ../scripts/llm-interactive"
echo "and then inside the container type: llm models list"
