#!/bin/bash
# examples/with-fragments.sh

# Create a temporary prompts directory if it doesn't exist for this example
PROMPT_DIR="../prompts" # Relative to this script's location (examples/)
mkdir -p "$PROMPT_DIR"

# Create a dummy fragment file in the project's prompts directory
echo "This is a sample text fragment. It contains some details about a fictional product called 'InnovateSphere', which is a new AI-powered collaboration tool." > "${PROMPT_DIR}/context_fragment.txt"

echo "Running LLM query with a fragment from ${PROMPT_DIR}/context_fragment.txt..."
# The path to the fragment for llm-safe should be relative to the project root
# So, if this script is in examples/ and prompts/ is at ../prompts,
# for llm-safe (which runs from project root context set by the script itself) it's ./prompts/
../scripts/llm-safe -f ./prompts/context_fragment.txt "Based on the fragment, what is InnovateSphere?"

# Clean up the dummy fragment (optional)
# rm "${PROMPT_DIR}/context_fragment.txt"
# Consider leaving it for users to inspect.
echo ""
echo "Note: A sample fragment was created at ${PROMPT_DIR}/context_fragment.txt"
