# Acheron "Hello World" Boilerplate Makefile

.PHONY: setup dev build dist installer test-ui test-go test-ui-file test-go-file test-go-run help

# --- Setup & Helpers ---

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies (Flutter, Go)
	flutter pub get
	cd engine && go mod tidy

# --- Development ---

dev: ## Run App in Dev Mode (Go Backend + Flutter Debug)
	@echo "Starting Go Backend (Dev)..."
	@# In a real scenario, use something like 'air' for hot reload. For now, background it.
	@# We wait a sec to let it start before flutter.
	@(trap 'kill 0' SIGINT; \
	 go run engine/cmd/engine/main.go & \
	 flutter run -d linux & \
	 wait)

# --- Build & Distribution ---

build: ## Build Standalone Executable for current OS
	@echo "Building Go Backend..."
	cd engine && go build -o ../assets/bin/engine cmd/engine/main.go
	@echo "Building Flutter App..."
	flutter build linux --release

installer: dist ## Alias for dist

dist: ## Build Installers using Fastforge (Linux/Mac/Win)
	@echo "Packaging for distribution..."
	# Ensure the Go binary is built and in assets/bin first
	cd engine && go build -o ../assets/bin/engine cmd/engine/main.go
	# Run flutter_distributor (Fastforge)
	# NOTE: You must have it installed: dart pub global activate flutter_distributor
	flutter_distributor release --name dev --jobs linux-deb

# --- Testing ---

test-ui: ## Run all Flutter tests
	flutter test

test-go: ## Run all Go tests
	cd engine && go test ./...

test-ui-file: ## Run specific Flutter test file (make test-ui-file f=test/widget_test.dart)
	flutter test $(f)

test-go-file: ## Run specific Go test file (make test-go-file f=./cmd/engine/...)
	cd engine && go test $(f)

test-go-run: ## Run specific Go test by name (make test-go-run n=TestName)
	cd engine && go test -run $(n) ./...
