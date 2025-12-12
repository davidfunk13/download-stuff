package middleware

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"time"

	"download_stuff_engine/internal/protocol"
)

// RequestHandler processes a parsed command and writes the response
type RequestHandler func(cmd protocol.Command, writer io.Writer)

// DevLogger wraps a RequestHandler with request/response logging
func DevLogger(handler RequestHandler) func(line string, writer io.Writer) {
	return func(line string, writer io.Writer) {
		start := time.Now()

		// Log the raw incoming request
		fmt.Fprintf(os.Stderr, "\n────────────────────────────────────────\n")
		fmt.Fprintf(os.Stderr, "📥 REQUEST\n")
		fmt.Fprintf(os.Stderr, "────────────────────────────────────────\n")

		// Pretty print the request JSON
		var prettyReq bytes.Buffer
		if err := json.Indent(&prettyReq, []byte(line), "   ", "  "); err != nil {
			fmt.Fprintf(os.Stderr, "   (invalid JSON) %s\n", line)
		} else {
			fmt.Fprintf(os.Stderr, "   %s\n", prettyReq.String())
		}

		var cmd protocol.Command
		if err := json.Unmarshal([]byte(line), &cmd); err != nil {
			sendErrorResponse(writer, "", "Invalid JSON format")
			fmt.Fprintf(os.Stderr, "\n📤 RESPONSE (parse error)\n")
			fmt.Fprintf(os.Stderr, "   {\"status\": \"error\", \"log\": \"Invalid JSON format\"}\n")
			fmt.Fprintf(os.Stderr, "────────────────────────────────────────\n")
			return
		}

		// Capture the response
		var respBuf bytes.Buffer
		handler(cmd, &respBuf)

		// Write to actual output
		writer.Write(respBuf.Bytes())

		// Log the response
		elapsed := time.Since(start)
		fmt.Fprintf(os.Stderr, "\n📤 RESPONSE (%v)\n", elapsed)
		fmt.Fprintf(os.Stderr, "────────────────────────────────────────\n")

		var prettyResp bytes.Buffer
		if err := json.Indent(&prettyResp, respBuf.Bytes(), "   ", "  "); err != nil {
			fmt.Fprintf(os.Stderr, "   %s", respBuf.String())
		} else {
			fmt.Fprintf(os.Stderr, "   %s\n", prettyResp.String())
		}
		fmt.Fprintf(os.Stderr, "────────────────────────────────────────\n")
	}
}

// sendErrorResponse writes a JSON error response
func sendErrorResponse(w io.Writer, id string, msg string) {
	resp := protocol.Response{
		ID:     id,
		Status: "error",
		Log:    msg,
	}
	bytes, _ := json.Marshal(resp)
	w.Write(append(bytes, '\n'))
}
