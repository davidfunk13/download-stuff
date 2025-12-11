package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
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
		Message: getBanner(),
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func randomHandler(w http.ResponseWriter, r *http.Request) {
	resp := Response{
		Status:  "ok",
		Message: fmt.Sprintf("W.E.N.I.S. Random ID: %d", time.Now().UnixNano()),
	}
	// Log the message for visibility
	fmt.Printf("[W.E.N.I.S.] Sending random message: %s\n", resp.Message)

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

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

   Hello from Wenis! This API/Application is Powered by Wenis™
`
}

func main() {
	fmt.Println(getBanner())
	port := "3001"
	if envPort := os.Getenv("PORT"); envPort != "" {
		port = envPort
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/random", randomHandler)

	handler := enableCors(mux)

	fmt.Printf("Wenis Engine 1.0 listening on port %s\n", port)
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
