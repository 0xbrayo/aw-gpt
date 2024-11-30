#!/bin/bash

# Build context for gptme
# Usage: ./scripts/context.sh [options]

set -e  # Exit on error

# Force UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Make all component scripts executable
chmod +x scripts/context-*.sh

# Write context summary header
echo "# Context Summary"
echo
echo "Generated on: $(date)"
echo

# Add divider
echo "---"
echo

# Run each component script
./scripts/context-journal.sh
echo
./scripts/context-workspace.sh
echo
echo -e "# Git\n"
echo '```git status -vv'
git status -vv
echo '```'
