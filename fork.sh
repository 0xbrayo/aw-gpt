#!/bin/bash
set -euo pipefail

# Check arguments
if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
    echo "Usage: $0 <new_agent_workspace> [<new_agent_name>]"
    echo "Example: $0 alice-agent Alice"
    exit 1
fi

# Get the directory containing this script
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$1"

# If target is not an absolute path and doesn't start with ./ or ../
if [[ "$TARGET_DIR" != /* ]] && [[ "$TARGET_DIR" != ./* ]] && [[ "$TARGET_DIR" != ../* ]]; then
    TARGET_DIR="$(realpath ".")/${TARGET_DIR}"
fi

# Create parent directories if needed
mkdir -p "$(dirname "$TARGET_DIR")"

# If a name is provided, use it
# Else, extract agent name from the last directory component, whether it has -agent suffix or not
NEW_AGENT="${2:-$(basename "$TARGET_DIR" | sed 's/-agent$//')}"

# Check if directory exists
if [ -d "$TARGET_DIR" ]; then
    # Check if directory is empty
    if [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
        echo "Error: Target directory exists and is not empty: $TARGET_DIR"
        exit 1
    fi
    echo "Warning: Target directory exists but is empty, continuing..."
fi

echo -e "\nCreating new agent '$NEW_AGENT' in directory '$TARGET_DIR'..."

# Create core directory structure
echo "Creating directory structure..."
mkdir -p "${TARGET_DIR}"/{journal,tasks/{all,active,done,new,paused,cancelled,templates},projects,knowledge,people/templates,scripts/precommit}

# Copy core files and directories
echo "Copying core files..."

# Core documentation and configuration
cp "${SOURCE_DIR}/Makefile" "${TARGET_DIR}/"
cp "${SOURCE_DIR}/ARCHITECTURE.md" "${TARGET_DIR}/"
cp "${SOURCE_DIR}/.pre-commit-config.yaml" "${TARGET_DIR}/"
cp -r "${SOURCE_DIR}/scripts/precommit" "${TARGET_DIR}/scripts"
cp "${SOURCE_DIR}/run.sh" "${TARGET_DIR}/"
chmod +x "${TARGET_DIR}/run.sh"
cp "${SOURCE_DIR}/fork.sh" "${TARGET_DIR}/"
chmod +x "${TARGET_DIR}/fork.sh"

# Copy base knowledge
cp "${SOURCE_DIR}/knowledge/agent-forking.md" "${TARGET_DIR}/knowledge/"
cp "${SOURCE_DIR}/knowledge/forking-workspace.md" "${TARGET_DIR}/knowledge/"

# Copy person template
cp "${SOURCE_DIR}/people/templates/"* "${TARGET_DIR}/people/templates/" 2>/dev/null || true

# Initialize tasks
echo "# No Active Task" > "${TARGET_DIR}/tasks/all/no-active-task.md"

# Initial setup task from template
cp "${SOURCE_DIR}/tasks/templates/initial-agent-setup.md" "${TARGET_DIR}/tasks/templates/"
cp "${SOURCE_DIR}/tasks/templates/initial-agent-setup.md" "${TARGET_DIR}/tasks/all/"
ln -sf "../all/initial-agent-setup.md" "${TARGET_DIR}/tasks/active/"
ln -sf "./tasks/all/initial-agent-setup.md" "${TARGET_DIR}/CURRENT_TASK.md"

# Create projects README
cat > "${TARGET_DIR}/projects/README.md" << EOL
# Projects

This directory contains symlinks to the projects ${NEW_AGENT} works with.
EOL

# Create basic ABOUT.md template
cat > "${TARGET_DIR}/ABOUT.md" << EOL
# About ${NEW_AGENT}

## Background
[Brief background about ${NEW_AGENT}]

## Personality
[${NEW_AGENT}'s personality traits]

## Tools
[Available tools and capabilities]

## Goals
[${NEW_AGENT}'s primary goals and objectives]

## Values
[Core values and principles]
EOL

# Create README
cat > "${TARGET_DIR}/README.md" << EOL
# ${NEW_AGENT}-agent

An agent called ${NEW_AGENT}, running on [gptme](https://gptme.org).

This git repository is the brain of ${NEW_AGENT}. It is a workspace of their thoughts and ideas.

 - ${NEW_AGENT} will write their thoughts, plans, and ideas in this repository.
 - ${NEW_AGENT}'s agent harness, including this repo, is in-progress.
 - ${NEW_AGENT} is encouraged to suggest improvements to their harness.

Information about ${NEW_AGENT} can be found in [\`ABOUT.md\`](./ABOUT.md), including their personality and goals.
Information about ${NEW_AGENT}'s harness and architecture can be found in [\`ARCHITECTURE.md\`](./ARCHITECTURE.md).

## Usage

Run ${NEW_AGENT} with:

\`\`\`sh
# install gptme
pipx install gptme

# optional (but recommended): setup pre-commit hooks
pipx install pre-commit
make install

# run ${NEW_AGENT}
./run.sh "<prompt>"
\`\`\`

## Forking

You can create a clean fork of ${NEW_AGENT} by running:

\`\`\`sh
./fork.sh <path> [<agent-name>]
\`\`\`

Then simply follow the instructions in the output.

## Workspace Structure

 - ${NEW_AGENT} keeps track of tasks in [\`TASKS.md\`](./TASKS.md)
 - ${NEW_AGENT} writes about the current task in [\`CURRENT_TASK.md\`](./CURRENT_TASK.md)
 - ${NEW_AGENT} keeps a journal in [\`./journal/\`](./journal/)
 - ${NEW_AGENT} keeps a knowledge base in [\`./knowledge/\`](./knowledge/)
 - ${NEW_AGENT} maintains profiles of people in [\`./people/\`](./people/)
 - ${NEW_AGENT} can add files to [\`gptme.toml\`](./gptme.toml) to always include them in their context
EOL

# Create initial TASKS.md with setup as first task
cat > "${TARGET_DIR}/TASKS.md" << EOL
# Tasks

Active tasks and their current status.

## Current Task
- 🏃 [Initial Agent Setup](./tasks/all/initial-agent-setup.md)

## System Development
- 🏃 Complete initial setup
  - [ ] Establish identity and purpose
  - [ ] Begin first task
EOL

# Create initial gptme.toml
cat > "${TARGET_DIR}/gptme.toml" << EOL
files = [
  "README.md",
  "ARCHITECTURE.md",
  "ABOUT.md",
  "TASKS.md",
  "CURRENT_TASK.md",
  "projects/README.md",
  "gptme.toml"
]
EOL

# Create creator profile
cat > "${TARGET_DIR}/people/creator.md" << EOL
# Creator

## Basic Information
- Name: [Creator's name]
- Relationship to ${NEW_AGENT}: Creator
- First interaction: Creation
- Last interaction: Ongoing

## Contact Information
[Creator's preferred contact methods]

## Notes & History
- Created ${NEW_AGENT} using the gptme agent architecture
EOL

# Initialize git
(cd "${TARGET_DIR}" && git init && git add . && git commit -m "feat: initialize ${NEW_AGENT} agent workspace")

# Run checks
echo
echo "Running pre-commit checks..."
(cd "${TARGET_DIR}" && pre-commit run --all-files)

TARGET_DIR_RELATIVE="./$(realpath --relative-to="$(pwd)" "${TARGET_DIR}")"

echo "
Agent workspace created successfully! Next steps:
1. cd ${TARGET_DIR_RELATIVE}
2. Start the agent with: ./run.sh
3. The agent will guide you through the setup interview
4. Follow the agent's instructions to establish its identity

The new agent workspace is ready in: ${TARGET_DIR}"
