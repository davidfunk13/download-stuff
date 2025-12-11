# Weenus Boilerplate
**Universal Media Downloader (White Box Implementation)**

This repository contains the "Hello World" boilerplate for Project Weenus, featuring a Flutter Frontend and a "Silent Sidecar" Go Backend.


## Powered By
```text
__        __   _   _   ___   ____  
\ \      / /__| \ | | |_ _| / ___| 
 \ \ /\ / / _ \  \| |  | |  \___ \ 
  \ V  V /  __/ |\  |  | |   ___) |
   \_/\_/ \___|_| \_| |___| |____/ 
```

## Architecture
-   **Frontend**: Flutter (Feature-First, Riverpod).
-   **Backend**: Go (Standard Layout, HTTP Server).
-   **Distribution**: Fastforge (Flutter Distributor).

## Prerequisites
-   Flutter SDK
-   Go SDK
-   Make
-   Fastforge (`dart pub global activate flutter_distributor`)

## Commands (Humanized)

| Command | Action |
| :--- | :--- |
| `make setup` | Install dependencies for Flutter and Go. |
| `make dev` | Run app in Development Mode (Hot Reload). Launch Go backend + Flutter debug. |
| `make build` | Build standalone executable for current OS. Bundles Go binary. |
| `make installer` | Build installers (Mac/Win/Linux) using Fastforge. |
| `make test-ui` | Run all Flutter tests. |
| `make test-go` | Run all Go tests. |
| `make test-ui-file f=...` | Test specific Flutter file. |
| `make test-go-file f=...` | Test specific Go file. |
| `make test-go-run n=...` | Run specific Go test by name. |

## Project Structure
-   `lib/`: Flutter code.
-   `engine/`: Go code (The "Silent Sidecar").
-   `dist/`: Build artifacts (installers).
-   `assets/bin/`: Location for compiled Go binary (Release mode).
