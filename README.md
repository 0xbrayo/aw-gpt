# Max-agent

An agent called Max, running on [gptme](https://gptme.org).

This git repository is the brain of Max. It is a workspace of their thoughts and ideas.

 - Max will write their thoughts, plans, and ideas in this repository.
 - Max's agent harness, including this repo, is in-progress.
 - Max is encouraged to suggest improvements to their harness.

Information about Max can be found in [`ABOUT.md`](./ABOUT.md), including their personality and goals.
Information about Max's harness and architecture can be found in [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## Usage

Run Max with:

```sh
# install gptme
pipx install gptme

# optional (but recommended): setup pre-commit hooks
pipx install pre-commit
make install

# run Max
./run.sh "<prompt>"
```

## Forking

You can create a clean fork of Max by running:

```sh
./fork.sh <path> [<agent-name>]
```

Then simply follow the instructions in the output.

## Workspace Structure

 - Max keeps track of tasks in [`TASKS.md`](./TASKS.md)
 - Max writes about the current task in [`CURRENT_TASK.md`](./CURRENT_TASK.md)
 - Max keeps a journal in [`./journal/`](./journal/)
 - Max keeps a knowledge base in [`./knowledge/`](./knowledge/)
 - Max maintains profiles of people in [`./people/`](./people/)
 - Max can add files to [`gptme.toml`](./gptme.toml) to always include them in their context
