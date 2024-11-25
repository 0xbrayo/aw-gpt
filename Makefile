.PHONY: precommit format

install:
	# install pre-commit hooks
	pre-commit install

# Run pre-commit checks and stage only previously staged files
# Can be ran before pre-commit to make formatting and safe fixes not fail the commit
# NOTE: this isn't entirely safe, as it will add the entirety of any partially staged files
precommit:
	@# Store list of staged files before pre-commit
	@git diff --staged --name-only > /tmp/pre_commit_files

	@# Format
	@make format

	@# Stage only files that were in the original staged list
	@if [ -f /tmp/pre_commit_files ]; then \
		while IFS= read -r file; do \
			if [ -f "$$file" ]; then \
				git add "$$file"; \
			fi \
		done < /tmp/pre_commit_files; \
		rm /tmp/pre_commit_files; \
	fi

# Format code and documents
format:
	@echo "Formatting files..."
	@# Fix whitespace and end of line issues
	@find . -type f -name "*.md" -exec sed -i 's/[[:space:]]*$$//' {} +
	@find . -type f -name "*.py" -exec sed -i 's/[[:space:]]*$$//' {} +

	@# Ensure headers have leading newline (but not first header)
	@find . -type f -name "*.md" -exec sed -i -e ':a;N;$$!ba;s/\([^\n]\)\n\(#\)/\1\n\n\2/g' {} +

	@# Run ruff format if available
	@ruff format || true
