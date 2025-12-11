package main

import (
	"bytes"
	"encoding/json"
	"io"
	"os"
	"strings"
	"testing"

	"download_stuff_engine/internal/protocol"
)

// captureOutput captures stdout during a function execution
func captureOutput(f func()) string {
	old := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	f()

	w.Close()
	os.Stdout = old

	var buf bytes.Buffer
	io.Copy(&buf, r)
	return buf.String()
}

func TestHealthCommand(t *testing.T) {
	// Create a health command JSON
	cmdJSON := `{"cmd": "health"}`

	// Capture the output of handleCommand
	output := captureOutput(func() {
		handleCommand(cmdJSON)
	})

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal([]byte(strings.TrimSpace(output)), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, output)
	}

	// Verify status
	if resp.Status != "ok" {
		t.Errorf("Expected status 'ok', got '%s'", resp.Status)
	}

	// Verify data contains health message
	dataStr, ok := resp.Data.(string)
	if !ok {
		t.Errorf("Expected Data to be a string, got %T", resp.Data)
	}
	if !strings.Contains(dataStr, "healthy") {
		t.Errorf("Expected data to contain 'healthy', got '%s'", dataStr)
	}
}

func TestRandomCommand(t *testing.T) {
	// Create a random command JSON
	cmdJSON := `{"cmd": "random"}`

	// Capture the output of handleCommand
	output := captureOutput(func() {
		handleCommand(cmdJSON)
	})

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal([]byte(strings.TrimSpace(output)), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, output)
	}

	// Verify status
	if resp.Status != "ok" {
		t.Errorf("Expected status 'ok', got '%s'", resp.Status)
	}

	// Verify data contains random ID
	dataStr, ok := resp.Data.(string)
	if !ok {
		t.Errorf("Expected Data to be a string, got %T", resp.Data)
	}
	if !strings.HasPrefix(dataStr, "W.E.N.I.S. Random ID:") {
		t.Errorf("Expected data to start with 'W.E.N.I.S. Random ID:', got '%s'", dataStr)
	}
}

func TestUnknownCommand(t *testing.T) {
	// Create an unknown command JSON
	cmdJSON := `{"cmd": "foobar"}`

	// Capture the output of handleCommand
	output := captureOutput(func() {
		handleCommand(cmdJSON)
	})

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal([]byte(strings.TrimSpace(output)), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, output)
	}

	// Verify status is error
	if resp.Status != "error" {
		t.Errorf("Expected status 'error', got '%s'", resp.Status)
	}

	// Verify log contains unknown command message
	if !strings.Contains(resp.Log, "Unknown command") {
		t.Errorf("Expected log to contain 'Unknown command', got '%s'", resp.Log)
	}
}

func TestInvalidJSON(t *testing.T) {
	// Create invalid JSON
	cmdJSON := `{not valid json}`

	// Capture the output of handleCommand
	output := captureOutput(func() {
		handleCommand(cmdJSON)
	})

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal([]byte(strings.TrimSpace(output)), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, output)
	}

	// Verify status is error
	if resp.Status != "error" {
		t.Errorf("Expected status 'error', got '%s'", resp.Status)
	}

	// Verify log contains invalid json message
	if !strings.Contains(resp.Log, "Invalid JSON") {
		t.Errorf("Expected log to contain 'Invalid JSON', got '%s'", resp.Log)
	}
}
