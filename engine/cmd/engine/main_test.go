package main

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"

	"download_stuff_engine/internal/protocol"
)

func TestHealthCommand(t *testing.T) {
	// Create a health command JSON
	cmdJSON := `{"cmd": "health"}`

	// Create a buffer to capture output
	var buf bytes.Buffer

	// Call handleCommand with the buffer
	processRequest(cmdJSON, &buf)

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal(buf.Bytes(), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, buf.String())
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

	// Create a buffer to capture output
	var buf bytes.Buffer

	// Call processRequest with the buffer
	processRequest(cmdJSON, &buf)

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal(buf.Bytes(), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, buf.String())
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

	// Create a buffer to capture output
	var buf bytes.Buffer

	// Call processRequest with the buffer
	processRequest(cmdJSON, &buf)

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal(buf.Bytes(), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, buf.String())
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

	// Create a buffer to capture output
	var buf bytes.Buffer

	// Call processRequest with the buffer
	processRequest(cmdJSON, &buf)

	// Parse the response
	var resp protocol.Response
	if err := json.Unmarshal(buf.Bytes(), &resp); err != nil {
		t.Fatalf("Failed to parse response: %v, output was: %s", err, buf.String())
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
