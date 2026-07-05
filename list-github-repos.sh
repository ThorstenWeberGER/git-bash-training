#!/usr/bin/env bash
set -euo pipefail

# This script lists all GitHub repositories for the authenticated user, including those they own, collaborate on, or are a member of through an organization. It uses the GitHub API and requires a personal access token for authentication.

# The personal access token should be stored in a file named `.secrets/github.env` in the same directory as this script, with the following format
SECRETS_FILE="$(dirname "$0")/.secrets/github.env"
if [ -f "$SECRETS_FILE" ]; then
  # Load the GITHUB_TOKEN from the .secrets/github.env file
  source "$SECRETS_FILE"
  echo "Found .secrets/github.env file and loaded GITHUB_TOKEN."
fi

# Check if the GITHUB_TOKEN environment variable is set, either from the .secrets/github.env file or exported in the shell
TOKEN="${token:?Set 'token' in .secrets/github.env or export GITHUB_TOKEN}"

# List all repositories for the authenticated user. The API returns paginated responses, so we collect all pages into an array.
PAGE=1
ALL_RESPONSES=()

# Fetch all pages and collect responses into array
while :; do
  RESPONSE=$(
    curl -s \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/user/repos?per_page=100&page=$PAGE&affiliation=owner,collaborator,organization_member"
  )

  # Check if the response is empty (no more pages)
  COUNT=$(echo "$RESPONSE" | jq 'length')
  [ "$COUNT" -eq 0 ] && break

  # Append this page's response to the array increase page number for the next iteration
  ALL_RESPONSES+=("$RESPONSE")
  PAGE=$((PAGE + 1))
done

# Inspect all collected responses
echo ""
echo "=== Total pages collected: ${#ALL_RESPONSES[@]} ==="
echo ""

# Show first page details
# echo "=== Page 1 - Full response (pretty-printed) ==="
# echo "${ALL_RESPONSES[0]}" | jq .

echo ""
echo "=== All available keys ==="
echo "${ALL_RESPONSES[0]}" | jq '.[0] | keys'

echo ""
echo "=== All repo names with URLs (from all pages) ==="
for response in "${ALL_RESPONSES[@]}"; do
  echo "${response}" | jq -r '.[] | "\(.name) - \(.html_url)"'
done

# Save repo names and URLs to CSV file
CSV_FILE="repo_names.csv"
# create header
echo "name,url" > "$CSV_FILE"
# add repo names and URLs to CSV file
for response in "${ALL_RESPONSES[@]}"; do
  echo "$response" | jq -r '.[] | "\(.name),\(.html_url)"' >> "$CSV_FILE"
done

# Display the first few lines of the CSV file and the total number of lines
echo ""
echo "=== Saved to $CSV_FILE ==="
cat "$CSV_FILE" | head -5
echo "... (and $(wc -l < "$CSV_FILE" | tr -d ' ')  total lines including header)"