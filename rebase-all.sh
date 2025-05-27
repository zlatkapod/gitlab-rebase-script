#!/bin/bash

# GitLab Merge Request Rebase Tool
# Automatically rebases all open merge requests assigned to a user

# --- Default Configuration (can be overridden with environment variables) ---
DEFAULT_GITLAB_API="https://gitlab.com/api/v4"
DEFAULT_USERNAME=""

# --- Parse command line arguments ---
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -t, --token TOKEN     GitLab Personal Access Token (required)"
  echo "  -u, --username USER   GitLab username (required)"
  echo "  -g, --gitlab URL      GitLab API URL (default: $DEFAULT_GITLAB_API)"
  echo "  -h, --help            Display this help message and exit"
  exit 0
}

# Process arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -t|--token) ACCESS_TOKEN="$2"; shift ;;
    -u|--username) USERNAME="$2"; shift ;;
    -g|--gitlab) GITLAB_API="$2"; shift ;;
    -h|--help) show_help ;;
    *) echo "Unknown parameter: $1"; show_help ;;
  esac
  shift
done

# Use environment variables if set, otherwise use arguments or defaults
GITLAB_API=${GITLAB_API:-${GITLAB_API_URL:-$DEFAULT_GITLAB_API}}
USERNAME=${USERNAME:-${GITLAB_USERNAME:-$DEFAULT_USERNAME}}
ACCESS_TOKEN=${ACCESS_TOKEN:-${GITLAB_TOKEN}}

# Validate required parameters
if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Error: GitLab access token is required"
  echo "Set it with -t/--token parameter or GITLAB_TOKEN environment variable"
  exit 1
fi

if [ -z "$USERNAME" ]; then
  echo "❌ Error: GitLab username is required"
  echo "Set it with -u/--username parameter or GITLAB_USERNAME environment variable"
  exit 1
fi

# Header for API calls
HEADER="PRIVATE-TOKEN: $ACCESS_TOKEN"

echo "ℹ️  Starting GitLab rebase script for user: $USERNAME"
echo "🔍 Fetching user ID..."

# Get user ID
USER_JSON=$(curl -s --header "$HEADER" "$GITLAB_API/users?username=$USERNAME")
USER_ID=$(echo "$USER_JSON" | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)

if [ -z "$USER_ID" ]; then
  echo "❌ Error: Failed to fetch user ID. Check token or username."
  exit 1
fi

echo "✅ User ID found: $USER_ID"
echo "📥 Fetching merge requests..."

# Get merge requests
MR_LIST=$(curl -s --header "$HEADER" "$GITLAB_API/merge_requests?state=opened&assignee_id=$USER_ID&scope=all&per_page=100")

MR_COUNT=$(echo "$MR_LIST" | grep -o '"iid":[0-9]*' | wc -l)
echo "📦 Number of open MRs: $MR_COUNT"
echo "🔁 Processing individual merge requests..."

# Split output into blocks for each MR
echo "$MR_LIST" | tr '}' '\n' | while read -r MR_BLOCK; do
  PROJECT_ID=$(echo "$MR_BLOCK" | grep -o '"project_id":[0-9]*' | cut -d':' -f2)
  IID=$(echo "$MR_BLOCK" | grep -o '"iid":[0-9]*' | cut -d':' -f2)

  if [[ -n "$PROJECT_ID" && -n "$IID" ]]; then
    echo "----------------------------------------"
    echo "📄 Checking MR #$IID in project $PROJECT_ID..."

    # MR details
    MR_DETAIL=$(curl -s --header "$HEADER" "$GITLAB_API/projects/$PROJECT_ID/merge_requests/$IID")
    MERGE_STATUS=$(echo "$MR_DETAIL" | grep -o '"detailed_merge_status":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    TITLE=$(echo "$MR_DETAIL" | grep -o '"title":"[^"]*"' | head -n1 | cut -d':' -f2- | tr -d '"')

    echo "📌 MR: $TITLE"
    echo "🔍 Status: merge_status=$MERGE_STATUS"

    echo "✅ Initiating rebase..."
    RESPONSE=$(curl -s -X PUT --header "$HEADER" "$GITLAB_API/projects/$PROJECT_ID/merge_requests/$IID/rebase")
    
    if [[ $? -eq 0 ]]; then
      echo "🔄 Rebase started for MR #$IID: $TITLE"
    else
      echo "❌ Error during rebase of MR #$IID"
    fi
  fi
done

echo "✅ Done. All merge requests have been processed."

read -p "Press enter to continue"
