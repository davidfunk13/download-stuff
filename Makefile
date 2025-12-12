# =============================================================================
# W.E.N.I.S. Build System
# Web Extraction & Network Interface System
# =============================================================================

# Flutter path (adjust if needed)
FLUTTER := /home/dave/development/flutter/bin/flutter

# =============================================================================
# Development Mode
# =============================================================================
# Launches Go engine in a separate terminal with hot-reload (air).
# Flutter connects via TCP socket (not subprocess).
.PHONY: dev
dev:
	gnome-terminal --title="WENIS Engine" -- bash -c "cd engine && export PATH=$(HOME)/go/bin:$(PATH) && air; exec bash"
	$(FLUTTER) run -d linux

# =============================================================================
# Build Mode (Current Platform)
# =============================================================================
# Compiles Go engine for the CURRENT platform silently into assets/bin/.
# Flutter spawns it as a subprocess (Stdin/Stdout).
.PHONY: build
build: build-engine-native
	@echo "Building Flutter app..."
	$(FLUTTER) build linux --release

# Build Go engine for current platform only
.PHONY: build-engine-native
build-engine-native:
	@echo "Building Go engine for current platform..."
	@mkdir -p assets/bin
	cd engine && go build -o ../assets/bin/wenis_engine_$(shell uname -s | tr '[:upper:]' '[:lower:]') ./cmd/engine

# =============================================================================
# Cross-Platform Engine Builds
# =============================================================================
# For when you want to pre-build all platforms before dist
.PHONY: build-engine-linux build-engine-mac build-engine-windows build-engine-all

build-engine-linux:
	@echo "Building Go engine for Linux..."
	@mkdir -p assets/bin
	cd engine && GOOS=linux GOARCH=amd64 go build -o ../assets/bin/wenis_engine_linux ./cmd/engine

build-engine-mac:
	@echo "Building Go engine for macOS..."
	@mkdir -p assets/bin
	cd engine && GOOS=darwin GOARCH=amd64 go build -o ../assets/bin/wenis_engine_macos ./cmd/engine

build-engine-windows:
	@echo "Building Go engine for Windows..."
	@mkdir -p assets/bin
	cd engine && GOOS=windows GOARCH=amd64 go build -o ../assets/bin/wenis_engine_windows.exe ./cmd/engine

build-engine-all: build-engine-linux build-engine-mac build-engine-windows
	@echo "All engine platforms built!"

# =============================================================================
# Distribution Mode (FastForge)
# =============================================================================
# Builds installers using FastForge
.PHONY: dist
dist: build-engine-all
	@echo "Creating installers with FastForge..."
	fastforge package --config distribute_options.yaml

# Single-platform dist shortcuts
.PHONY: dist-linux dist-mac dist-windows

dist-linux: build-engine-linux
	fastforge package --config distribute_options.yaml --jobs linux-deb,linux-appimage

dist-mac: build-engine-mac
	fastforge package --config distribute_options.yaml --jobs macos-dmg

dist-windows: build-engine-windows
	fastforge package --config distribute_options.yaml --jobs windows-exe

# =============================================================================
# Utilities
# =============================================================================
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf assets/bin/
	rm -rf dist/
	rm -rf build/
	@echo "Clean complete."
