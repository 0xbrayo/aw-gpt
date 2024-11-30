#!/bin/bash

# Parse arguments
DRY_RUN=false

# Initialize array for prompt parts
PROMPT_PARTS=()

# Parse arguments: all non-flag arguments are treated as separate prompt parts
# Example: ./run.sh "first part" "second part" -> will pass both parts as separate arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            PROMPT_PARTS+=("$1")
            ;;
    esac
    shift
done

# Create tmp directory if it doesn't exist
mkdir -p tmp

# Build context file
CONTEXT_FILE="tmp/context.md"
./scripts/context.sh > "$CONTEXT_FILE"

if [ "$DRY_RUN" = true ]; then
    # In dry-run mode, print the command with proper quoting
    echo "gptme with arguments:"
    for part in "${PROMPT_PARTS[@]}"; do
        printf "  %q\n" "$part"
    done
    echo "  $CONTEXT_FILE"
else
    # Normal mode: run gptme with user arguments and context file
    gptme "${PROMPT_PARTS[@]}" "$CONTEXT_FILE"
fi
