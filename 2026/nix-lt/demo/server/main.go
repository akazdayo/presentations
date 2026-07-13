package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from NixOS! (Version 1)\n")
		fmt.Fprintf(w, "Hello from matsuriba!")
	})
	http.ListenAndServe(":3000", nil)
}
