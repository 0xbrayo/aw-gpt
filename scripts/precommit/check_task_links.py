#!/usr/bin/env python3
"""Pre-commit hook to verify task file symlinks.

Features:
- Validates that each task file in tasks/all/ has exactly one symlink in a state directory
- Verifies symlink integrity
- Handles special case of no-active-task.md
- Self-contained with built-in tests (run with pytest)

Usage:
    Directly:
        python3 scripts/check_task_links.py

    With pytest:
        pytest scripts/check_task_links.py

    As pre-commit hook (.pre-commit-config.yaml):
        - repo: local
          hooks:
          - id: check-task-links
            name: Check task symlinks
            entry: python3 scripts/check_task_links.py
            language: system
            pass_filenames: false
            always_run: true

State Directories:
    - tasks/new/: New tasks
    - tasks/active/: Active tasks
    - tasks/paused/: Paused tasks
    - tasks/done/: Completed tasks
    - tasks/cancelled/: Cancelled tasks

Special Cases:
    - no-active-task.md: Should not have any symlinks
    - CURRENT_TASK.md: Should be a valid symlink to a task file or no-active-task.md

Error Reporting:
    Reports issues in format:
    - Missing link: task_file.md not linked in any state directory
    - Multiple links: task_file.md linked in multiple states: new, active
    - Invalid link: broken symlink in tasks/active/task_file.md
"""

import sys
from pathlib import Path
from collections.abc import Sequence


def find_repo_root(start_path: Path) -> Path:
    """Find the repository root by looking for .git directory."""
    current = start_path.resolve()
    while current != current.parent:
        if (current / ".git").exists():
            return current
        current = current.parent
    return start_path.resolve()


def get_state_dirs(repo_root: Path) -> list[Path]:
    """Get all task state directories."""
    return [
        repo_root / "tasks" / state
        for state in ["new", "active", "paused", "done", "cancelled"]
    ]


def find_task_links(task_file: Path, state_dirs: list[Path]) -> list[Path]:
    """Find all symlinks pointing to a task file."""
    links = []
    for state_dir in state_dirs:
        for link in state_dir.glob("*.md"):
            if link.is_symlink() and link.resolve() == task_file.resolve():
                links.append(link)
    return links


def verify_current_task(repo_root: Path) -> list[str]:
    """Verify CURRENT_TASK.md symlink."""
    errors = []
    current_task = repo_root / "CURRENT_TASK.md"

    if not current_task.exists():
        errors.append("CURRENT_TASK.md does not exist")
        return errors

    if not current_task.is_symlink():
        errors.append("CURRENT_TASK.md is not a symlink")
        return errors

    try:
        target = current_task.resolve()
        if not target.exists():
            errors.append(f"CURRENT_TASK.md points to non-existent file: {target}")
        elif not str(target).startswith(str(repo_root / "tasks/all/")):
            errors.append(f"CURRENT_TASK.md points outside tasks/all/: {target}")
    except Exception as e:
        errors.append(f"Error resolving CURRENT_TASK.md: {e}")

    return errors


def verify_task_links(repo_root: Path | None = None) -> list[str]:
    """Verify all task files have exactly one valid symlink in a state directory."""
    if repo_root is None:
        repo_root = find_repo_root(Path.cwd())

    errors = []

    # Get all state directories
    state_dirs = get_state_dirs(repo_root)
    tasks_dir = repo_root / "tasks/all"

    # Verify CURRENT_TASK.md
    errors.extend(verify_current_task(repo_root))

    # Check each task file
    for task_file in tasks_dir.glob("*.md"):
        # Skip no-active-task.md
        if task_file.name == "no-active-task.md":
            continue

        links = find_task_links(task_file, state_dirs)

        if not links:
            errors.append(
                f"Missing link: {task_file.name} not linked in any state directory"
            )
        elif len(links) > 1:
            states = [link.parent.name for link in links]
            errors.append(
                f"Multiple links: {task_file.name} linked in multiple states: {', '.join(states)}"
            )

    # Check for broken symlinks in state directories
    for state_dir in state_dirs:
        for link in state_dir.glob("*.md"):
            if not link.is_symlink():
                errors.append(f"Not a symlink: {link.relative_to(repo_root)}")
                continue

            try:
                target = link.resolve()
                if not target.exists():
                    errors.append(
                        f"Broken link: {link.relative_to(repo_root)} -> {target}"
                    )
                elif not str(target).startswith(str(tasks_dir)):
                    errors.append(
                        f"Invalid link: {link.relative_to(repo_root)} points outside tasks/all/"
                    )
            except Exception as e:
                errors.append(f"Error resolving {link.relative_to(repo_root)}: {e}")

    return errors


def main(argv: Sequence[str] = sys.argv) -> int:
    """Main function."""
    errors = verify_task_links()

    if errors:
        print("\n".join(errors))
        return 1
    return 0


def test_verify_task_links():
    """Test the task link verification."""
    import tempfile
    import os

    with tempfile.TemporaryDirectory() as tmpdir:
        root = Path(tmpdir)

        # Create test directory structure
        tasks_dir = root / "tasks"
        for d in ["all", "new", "active", "paused", "done", "cancelled"]:
            (tasks_dir / d).mkdir(parents=True)

        # Create test files
        (tasks_dir / "all/task1.md").write_text("task1")
        (tasks_dir / "all/task2.md").write_text("task2")
        (tasks_dir / "all/no-active-task.md").write_text("no active task")

        # Create valid symlinks
        (tasks_dir / "active/task1.md").symlink_to("../all/task1.md")
        (tasks_dir / "done/task2.md").symlink_to("../all/task2.md")
        (root / "CURRENT_TASK.md").symlink_to("tasks/all/task1.md")

        # Save current directory and change to test directory
        old_cwd = os.getcwd()
        os.chdir(str(root))

        try:
            # Test valid configuration
            errors = verify_task_links(root)
            assert len(errors) == 0

            # Test missing link
            (tasks_dir / "all/task3.md").write_text("task3")
            errors = verify_task_links(root)
            assert len(errors) == 1
            assert "Missing link: task3.md" in errors[0]

            # Test multiple links
            (tasks_dir / "new/task1.md").symlink_to("../all/task1.md")
            errors = verify_task_links(root)
            assert len(errors) == 1
            assert "Multiple links" in errors[0]

            # Test broken link
            (tasks_dir / "active/broken.md").symlink_to("../all/nonexistent.md")
            errors = verify_task_links(root)
            assert len(errors) == 2  # Previous error + new broken link
            assert any("Broken link" in e for e in errors)

        finally:
            os.chdir(old_cwd)


if __name__ == "__main__":
    sys.exit(main())
