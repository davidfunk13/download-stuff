package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"

	"download_stuff_engine/internal/protocol"
)

func getBanner() string {
	return `
__        __   _   _   ___   ____  
\ \      / /__| \ | | |_ _| / ___| 
 \ \ /\ / / _ \  \| |  | |  \___ \ 
  \ V  V /  __/ |\  |  | |   ___) |
   \_/\_/ \___|_| \_| |___| |____/ 
   
   Web Extraction & Network Interface System v1.0.0
   ------------------------------------------------
   [+] Initializing W.E.N.I.S...
   [+] Connection established.
`
}

func main() {
	// 1. Print Banner to Stderr so it doesn't mess up the JSON stdout stream
	fmt.Fprintln(os.Stderr, getBanner())
	fmt.Fprintln(os.Stderr, "[W.E.N.I.S.] Engine Started. Listening on Stdin...")

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}

		handleCommand(line)
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading stdin: %v\n", err)
	}
}

func handleCommand(line string) {
	var cmd protocol.Command
	if err := json.Unmarshal([]byte(line), &cmd); err != nil {
		sendError("Invalid JSON format")
		return
	}

	// Traffic Control Dispatcher
	switch cmd.Cmd {
	case "health":
		sendResponse(protocol.Response{
			Status: "ok",
			Data:   "W.E.N.I.S. is healthy and running",
			Log:    "Health check received",
		})
	case "random":
		sendResponse(protocol.Response{
			Status: "ok",
			Data:   fmt.Sprintf("W.E.N.I.S. Random ID: %d", time.Now().UnixNano()),
			Log:    "Random ID generated",
		})
	default:
		sendError(fmt.Sprintf("Unknown command: %s", cmd.Cmd))
	}
}

func sendResponse(resp protocol.Response) {
	bytes, err := json.Marshal(resp)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshalling response: %v\n", err)
		return
	}
	fmt.Println(string(bytes))
}

func sendError(msg string) {
	sendResponse(protocol.Response{
		Status: "error",
		Log:    msg,
	})
}
