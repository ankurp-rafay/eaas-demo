#!/bin/bash

# Color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m" # Reset to default color

# Validate arguments
if [ "$#" -lt 5 ]; then
  echo -e "${RED}Usage: $0 <BASE_URL> <API_KEY> <PROJECT_NAME> <CLUSTER_NAME> <COMMAND> [TIMEOUT]${RESET}"
  exit 1
fi

BASE_URL="$1"
API_KEY="$2"
PROJECT_NAME="$3"
CLUSTER_NAME="$4"
COMMAND="$5"
TIMEOUT="${6:-120}" 

# Function to handle success output
success() {
  echo -e "${GREEN}$1${RESET}"
}

# Function to handle error output
error() {
  echo -e "${RED}$1${RESET}"
  exit 1
}

# Fetch Project ID
PROJECT_ID=$(curl -s -X GET "https://${BASE_URL}/auth/v1/projects/?limit=48&offset=0&order=ASC&orderby=name&q=" \
  -H 'User-Agent: Mozilla/5.0' \
  -H "Referer: https://${BASE_URL}/" \
  -H "X-RAFAY-API-KEYID: ${API_KEY}" \
  | jq -r --arg name "${PROJECT_NAME}" '.results[] | select(.name == $name) | .id')

if [ -z "$PROJECT_ID" ]; then
  error "Project ID not found for project name $PROJECT_NAME"
fi
success "Project ID fetched successfully: $PROJECT_ID"

# Fetch Cluster ID
CLUSTER_ID=$(curl -s -X GET "https://${BASE_URL}/edge/v1/projects/$PROJECT_ID/edges/?limit=25&offset=0&q=" \
  -H 'accept: application/json, text/plain, */*' \
  -H "X-RAFAY-API-KEYID: ${API_KEY}" \
  -H "User-Agent: Mozilla/5.0" \
  -H "Referer: https://${BASE_URL}/" \
  | jq -r --arg name "${CLUSTER_NAME}" '.results[] | select(.name == $name) | .id')

if [ -z "$CLUSTER_ID" ]; then
  error "Cluster ID not found for cluster name $CLUSTER_NAME"
fi
success "Cluster ID fetched successfully: $CLUSTER_ID"

# Execute Command
POST_RESPONSE=$(curl -s -X POST \
  "https://${BASE_URL}/cmdexec/v1/projects/$PROJECT_ID/edges/$CLUSTER_ID/execute/" \
  -H "accept: application/json" \
  -H "X-RAFAY-API-KEYID: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"target_type\": \"cluster\", \"command\": \"$COMMAND\", \"timeout\": $TIMEOUT}")

EXEC_ID=$(echo "$POST_RESPONSE" | jq -r '.Id')

if [ -z "$EXEC_ID" ] || [ "$EXEC_ID" == "null" ]; then
  error "Failed to retrieve execution ID. Response: $POST_RESPONSE"
fi
success "Execution ID retrieved successfully: $EXEC_ID"

# Fetch Execution Result
GET_RESPONSE=$(curl -s -X GET \
  "https://${BASE_URL}/cmdexec/v1/projects/$PROJECT_ID/edges/$CLUSTER_ID/execution/$EXEC_ID/" \
  -H "accept: application/json" \
  -H "X-RAFAY-API-KEYID: ${API_KEY}")

RETURN_FIELD=$(echo "$GET_RESPONSE" | jq -r '.NodeResponses[0].Resp.Return')

if [ -z "$RETURN_FIELD" ] || [ "$RETURN_FIELD" == "null" ]; then
  error "Failed to retrieve the Return field. Response: $GET_RESPONSE"
fi

# Write the command output to the specified file
success "Command Output:\n$RETURN_FIELD"
