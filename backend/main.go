package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"
)

var dataFile string

func main() {
	port := flag.String("p", "8080", "Port to serve on")
	static := flag.String("s", ".", "Directory to serve")
	pathToData := flag.String("d", "data.json", "Server state location")
	flag.Parse()
	dataFile = *pathToData

	http.Handle("/", http.FileServer(http.Dir(*static)))
	http.HandleFunc("/get-state", getState)
	http.HandleFunc("POST /set-state", setState)

	log.Printf("Running server on HTTP port: %s, static dir: %s\n", *port, *static)
	log.Fatal(http.ListenAndServe(":"+*port, nil))
}

type State struct {
	Clock int `json:"clock"`
	State map[string]any `json:"state"`
}

func getState(w http.ResponseWriter, r *http.Request) {
	fileMutex.Lock()
	defer fileMutex.Unlock()
	state, err := readStateFile()
	if err != nil {
		log.Printf("Error: Failed to read state file: %s", err)
		w.WriteHeader(http.StatusInternalServerError);
		return
	}

	err = json.NewEncoder(w).Encode(state);
	if err != nil {
		log.Printf("Error: Failed to json-encode state: %s", err)
		w.WriteHeader(http.StatusInternalServerError);
		return
	}
}

func setState(w http.ResponseWriter, r *http.Request) {
	fileMutex.Lock()
	defer fileMutex.Unlock()
	state, err := readStateFile()
	if err != nil {
		log.Printf("Error: Failed to read state file: %s", err)
		w.WriteHeader(http.StatusInternalServerError);
		return
	}

	clock, err := strconv.Atoi(r.URL.Query().Get("clock"))
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Malformed clock parameter: %s", err)
		return
	}

	if clock != state.Clock {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Incorrect clock parameter, current clock is %d, got %d", state.Clock, clock)
		return
	}

	err = json.NewDecoder(r.Body).Decode(&state.State)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Couldn't parse state json %s", err)
		return
	}

	state.Clock += 1
	err = writeStateFile(&state)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		log.Printf("Error: Couldn't write state to disk: %s", err)
		return
	}

	err = json.NewEncoder(w).Encode(state.Clock);
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		log.Printf("Error: Couldn't write new clock to response: %s", err)
		return
	}
}

// NOTE(vipa, 2025-06-01): These should be run while holding the file mutex

var fileMutex sync.Mutex

func readStateFile() (state State, err error) {
  file, err := os.Open(dataFile)
	defer func() {
		err := file.Close()
		if err != nil {
			log.Printf("Error: failed to close file: %s", err)
		}
	}()
	if err != nil {
		return
	}

	err = json.NewDecoder(file).Decode(&state)

	return
}

func writeStateFile(state *State) (err error) {
	file, err := os.Create(dataFile)
	if err != nil {
		return
	}
	defer func() {
		err := file.Close()
		if err != nil {
			log.Printf("Error: failed to close file: %s", err)
		}
	}()

	err = json.NewEncoder(file).Encode(state)
	return
}
