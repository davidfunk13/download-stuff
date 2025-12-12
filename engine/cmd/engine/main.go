package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net"
	"os"
	"strings"
	"time"

	"download_stuff_engine/internal/middleware"
	"download_stuff_engine/internal/protocol"
)

var devMode bool

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
`
}

// Connection abstracts the communication channel (Stdio or Socket)
type Connection interface {
	io.Reader
	io.Writer
}

// StdioConnection wraps Stdin/Stdout
type StdioConnection struct{}

func (s StdioConnection) Read(p []byte) (n int, err error) {
	return os.Stdin.Read(p)
}

func (s StdioConnection) Write(p []byte) (n int, err error) {
	return os.Stdout.Write(p)
}

func main() {
	port := flag.Int("port", 0, "Port to listen on (0 for Stdin behavior)")
	flag.BoolVar(&devMode, "dev", false, "Enable development mode with request logging")
	flag.Parse()

	// 1. Print Banner to Stderr so it doesn't mess up the JSON stdout stream
	fmt.Fprintln(os.Stderr, getBanner())

	if *port > 0 {
		startSocketServer(*port)
	} else {
		startStdioServer()
	}
}

func startStdioServer() {
	fmt.Fprintln(os.Stderr, "[W.E.N.I.S.] Engine Started. Mode: PIPE (Stdin/Stdout)")
	conn := StdioConnection{}
	handleConnection(conn)
}

func startSocketServer(port int) {
	addr := fmt.Sprintf("localhost:%d", port)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error listening on %s: %v\n", addr, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "[W.E.N.I.S.] Engine Started. Mode: SOCKET (%s)\n", addr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error accepting connection: %v\n", err)
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn io.ReadWriter) {
	// Create the dev logger middleware (wraps handleCommand)
	loggedHandler := middleware.DevLogger(handleCommand)

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}

		if devMode {
			loggedHandler(line, conn)
		} else {
			processRequest(line, conn)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading connection: %v\n", err)
	}
}

// processRequest handles a single request line (used in non-dev mode)
func processRequest(line string, writer io.Writer) {
	var cmd protocol.Command
	if err := json.Unmarshal([]byte(line), &cmd); err != nil {
		sendError(writer, "", "Invalid JSON format")
		return
	}
	handleCommand(cmd, writer)
}

func handleCommand(cmd protocol.Command, writer io.Writer) {
	// Traffic Control Dispatcher
	switch cmd.Cmd {
	case "health":
		sendResponse(writer, protocol.Response{
			ID:     cmd.ID,
			Status: "ok",
			Data:   "W.E.N.I.S. is healthy and running",
			Log:    "Health check received",
		})
	case "random":
		sendResponse(writer, protocol.Response{
			ID:     cmd.ID,
			Status: "ok",
			Data:   fmt.Sprintf("W.E.N.I.S. Random ID: %d", time.Now().UnixNano()),
			Log:    "Random ID generated",
		})
	case "shutdown":
		sendResponse(writer, protocol.Response{
			ID:     cmd.ID,
			Status: "ok",
			Log:    "Shutting down gracefully",
		})
		fmt.Fprintln(os.Stderr, "[W.E.N.I.S.] Shutdown requested. Goodbye!")
		os.Exit(0)
	default:
		sendError(writer, cmd.ID, fmt.Sprintf("Unknown command: %s", cmd.Cmd))
	}
}

func sendResponse(w io.Writer, resp protocol.Response) {
	bytes, err := json.Marshal(resp)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshalling response: %v\n", err)
		return
	}
	// Append newline as delimiter
	w.Write(append(bytes, '\n'))
}

func sendError(w io.Writer, id string, msg string) {
	sendResponse(w, protocol.Response{
		ID:     id,
		Status: "error",
		Log:    msg,
	})
}
