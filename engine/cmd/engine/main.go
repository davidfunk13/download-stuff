package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

type Response struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func enableCors(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	resp := Response{
		Status:  "ok",
		Message: "Hello from Acheron Backend",
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func main() {
	port := "12345"
	if envPort := os.Getenv("PORT"); envPort != "" {
		port = envPort
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)

	handler := enableCors(mux)

	fmt.Printf("Acheron Engine listening on port %s\n", port)
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
