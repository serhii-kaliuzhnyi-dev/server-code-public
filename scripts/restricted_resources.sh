#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "SCRIPT_DIR is set to $SCRIPT_DIR"

# Configuration file path
CONFIG_FILE="$SCRIPT_DIR/restricted_paths.json"
echo "CONFIG_FILE is set to $CONFIG_FILE"

# Function to apply restrictions
apply_restrictions() {
    local path=$1
    local permissions=$2

    echo "Applying restrictions: Path=$path, Permissions=$permissions"
    if [ -e "$path" ]; then
        echo "Changing owner and permissions for $path"
        chown $USERNAME:$USERNAME "$path"
        if [ -d "$path" ]; then
            chmod 100 "$path"
            # Make all files executable
            find "$path" -type f -exec chmod 111 {} \;
        else
            chmod "$permissions" "$path"
        fi
    else
        echo "Warning: Path '$path' does not exist."
    fi
}

# Check if jq is installed (for parsing JSON)
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    apt-get update && apt-get install -y jq
fi

# Read the configuration file and apply restrictions
if [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration file $CONFIG_FILE"
    restricted_resources=$(jq -c '.restricted_resources[]' "$CONFIG_FILE")
    for resource in $restricted_resources; do
        echo "Processing resource: $resource"
        relative_path=$(echo "$resource" | jq -r '.path')
        permissions=$(echo "$resource" | jq -r '.permissions')
        absolute_path="$SCRIPT_DIR/../$relative_path"
        echo "Resolved absolute path: $absolute_path"
        apply_restrictions "$absolute_path" "$permissions"
    done
else
    echo "Configuration file '$CONFIG_FILE' not found."
fi
