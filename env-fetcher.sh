#!/bin/bash

# Set error handling
set -e

# Functions to check installed tools
check_tools() {
    for tool in gh yq jq aws; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool is not installed. Please install $tool to run this script."
            exit 1
        fi
    done
}

# Validate script arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <github_url> <output_env_file>"
    exit 1
fi

gh_source="$1"
output_file="$2"

# Function to fetch content from GitHub
fetch_from_github() {
    if ! content=$(gh api "$gh_source" --jq '.content | @base64d'); then
        echo "Error: Failed to fetch content using GitHub CLI. Please check the URL and your permissions."
        exit 1
    fi
    echo "$content"
}

# Function to fetch secret from AWS Secrets Manager
fetch_secret() {
    local secret_name="$1"
    local secret_key="$2"
    if ! secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query "SecretString" --output text | jq -r ".$secret_key"); then
        echo "Error: Failed to fetch secret $secret_key from $secret_name"
        exit 1
    fi
    echo "$secret_value"
}

# Main execution block
check_tools
source_content=$(fetch_from_github)

# Clear or create the output file
> "$output_file"

# Process static environment variables
echo "$source_content" | yq e '.envsToCM | to_entries | .[] | .key + "=" + .value' - >> "$output_file"

# Process dynamic secrets
echo "$source_content" | yq e -o=json '.env[] | select(.valueFrom.secretKeyRef)' - | jq -c . | while IFS= read -r env_entry; do
    name=$(echo "$env_entry" | jq -r '.name')
    secret_name=$(echo "$env_entry" | jq -r '.valueFrom.secretKeyRef.name')
    secret_key=$(echo "$env_entry" | jq -r '.valueFrom.secretKeyRef.key')
    
    echo "Fetching secret $secret_key from $secret_name for $name"
    secret_value=$(fetch_secret "$secret_name" "$secret_key")
    echo "$name=$secret_value" >> "$output_file"
done

echo "Environment file has been generated at $output_file"
echo "Secrets have been fetched from AWS Secrets Manager and included in the .env file."
