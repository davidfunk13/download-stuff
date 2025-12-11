# Makefile for W.E.N.I.S. Project

# Development Mode (Hot Reload)
# Run this in a separate terminal.
.PHONY: dev
dev:
	gnome-terminal --title="WENIS Engine" -- bash -c "cd engine && export PATH=$(HOME)/go/bin:$(PATH) && air; exec bash"
	/home/dave/development/flutter/bin/flutter run -d linux

# Production Build (Silent Backend)
# Compiles the Go engine and places it where Flutter expects it.
.PHONY: build
build:
	@echo "Building W.E.N.I.S. Engine..."
	cd engine && go build -o ../assets/bin/wenis_engine_linux ./cmd/engine
	@echo "Build complete: assets/bin/wenis_engine_linux"

# Distribution (Installer)
# Placeholder for FastForge or other packaging logic.
.PHONY: dist
dist: build
	@echo "Creating installer..."
	# TODO: Add fastforge command here
	@echo "Installer created."
