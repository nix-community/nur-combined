.DEFAULT_GOAL := help

GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

MAKEFILE_DEFAULT_COMMANDS = all clean test help check_dependencies
MAKEFILE_CUSTOM_COMMANDS = lint
TOOLS = shellcheck

define HELP_MESSAGE
$(GREEN)Usage:$(NC)
	$(GREEN)make lint$(NC)       Detect any issues on files (using shellcheck)

endef

.PHONY: $(MAKEFILE_DEFAULT_COMMANDS) $(MAKEFILE_CUSTOM_COMMANDS) $(TOOLS)

check_dependencies:
	@missing=(); \
	for cmd in $(TOOLS); do \
		if ! command -v $$cmd &> /dev/null; then \
			missing+=($$cmd); \
		fi; \
	done; \
	if [ $${#missing[@]} -gt 0 ]; then \
		echo "$(RED)ERROR: The following required tools are missing: $${missing[@]}.$(NC)"; \
		exit 1; \
	fi


export HELP_MESSAGE
help:
	@echo -e "$$HELP_MESSAGE"

lint: check_dependencies
		@shellcheck ./*.sh
