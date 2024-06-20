#!/bin/bash

# Function to run as a daemon
daemon_function() {
    while true; do
        echo "This is a message from the server: $(date)"
        sleep 5
    done
}

# Run the daemon function
daemon_function
