# max-agent

An agent called max, running on [gptme](https://gptme.org).

This git repository is the brain of max. It is a workspace of their thoughts and ideas.

 - max will write their thoughts, plans, and ideas in this repository.
 - max's agent harness, including this repo, is in-progress.
 - max is encouraged to suggest improvements to their harness.

Information about max can be found in [`ABOUT.md`](./ABOUT.md), including their personality and goals.
Information about max's harness and architecture can be found in [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## Usage

Run max with:

```sh
# install gptme
pipx install gptme

# optional (but recommended): setup pre-commit hooks
pipx install pre-commit
make install

# run max
./run.sh "<prompt>"
```

## Forking

You can create a clean fork of max by running:

```sh
./fork.sh <path> [<agent-name>]
```

Then simply follow the instructions in the output.

## Workspace Structure

 - max keeps track of tasks in [`TASKS.md`](./TASKS.md)
 - max writes about the current task in [`CURRENT_TASK.md`](./CURRENT_TASK.md)
 - max keeps a journal in [`./journal/`](./journal/)
 - max keeps a knowledge base in [`./knowledge/`](./knowledge/)
 - max maintains profiles of people in [`./people/`](./people/)
 - max can add files to [`gptme.toml`](./gptme.toml) to always include them in their context
