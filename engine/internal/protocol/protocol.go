package protocol

// Command represents a message sent from Flutter to Go.
type Command struct {
	// ID is the unique request identifier for correlating async responses
	ID string `json:"id,omitempty"`
	// Cmd determines what logic to execute (e.g., "health", "download", "extract")
	Cmd string `json:"cmd"`
	// URL is the target for extraction (optional, depends on cmd)
	URL string `json:"url,omitempty"`
	// Quality is the preferred video quality (optional)
	Quality string `json:"quality,omitempty"`
}

// Response represents a message sent from Go to Flutter.
type Response struct {
	// ID is the unique request identifier, echoed back from the command
	ID string `json:"id,omitempty"`
	// Status indicates success or failure ("ok", "error", "progress")
	Status string `json:"status"`
	// Data contains the actual result (e.g., metadata, file path)
	Data interface{} `json:"data,omitempty"`
	// Log is for debug messages to show in the terminal UI
	Log string `json:"log,omitempty"`
	// Progress is for download percentage (optional)
	Progress float64 `json:"progress,omitempty"`
}
