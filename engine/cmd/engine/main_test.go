package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	// Create a request to pass to our handler. We don't have any query parameters for now, so we'll
	// pass 'nil' as the third parameter.
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(healthHandler)

	// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
	// directly and pass in our Request and ResponseRecorder.
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check the content type
	expectedContentType := "application/json"
	if contentType := rr.Header().Get("Content-Type"); contentType != expectedContentType {
		t.Errorf("handler returned wrong content type: got %v want %v",
			contentType, expectedContentType)
	}

	// Check the response body
	var response Response
	if err := json.NewDecoder(rr.Body).Decode(&response); err != nil {
		t.Fatal(err)
	}

	if response.Status != "ok" {
		t.Errorf("handler returned unexpected status: got %v want %v",
			response.Status, "ok")
	}

	// Check that the message contains the W.E.N.I.S. branding
	expectedSubstring := "Powered by Wenis"
	if !strings.Contains(response.Message, expectedSubstring) {
		t.Errorf("handler returned unexpected message: got %v, want substring %v",
			response.Message, expectedSubstring)
	}
}

func TestRandomHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/random", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(randomHandler)

	handler.ServeHTTP(rr, req)

	// Check Status
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check Content Type
	expectedContentType := "application/json"
	if contentType := rr.Header().Get("Content-Type"); contentType != expectedContentType {
		t.Errorf("handler returned wrong content type: got %v want %v",
			contentType, expectedContentType)
	}

	// Check Body
	var response Response
	if err := json.NewDecoder(rr.Body).Decode(&response); err != nil {
		t.Fatal(err)
	}

	if response.Status != "ok" {
		t.Errorf("handler returned unexpected status: got %v want %v",
			response.Status, "ok")
	}

	expectedPrefix := "W.E.N.I.S. Random ID:"
	if !strings.HasPrefix(response.Message, expectedPrefix) {
		t.Errorf("handler returned unexpected message: got %v, want prefix %v",
			response.Message, expectedPrefix)
	}
}
