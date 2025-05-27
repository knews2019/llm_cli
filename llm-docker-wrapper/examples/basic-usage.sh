#!/bin/bash
# examples/basic-usage.sh

echo "Running basic LLM query..."
# Uses the llm-safe script from the parent directory's scripts folder
../scripts/llm-safe "What is the main benefit of using Docker containers?"

echo ""
echo "Querying with a specific model (ensure OPENAI_API_KEY is in .env)..."
../scripts/llm-safe -m gpt-4o-mini "Suggest a tagline for a new AI startup."
