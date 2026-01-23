#!/usr/bin/env bash

set -euo pipefail

BOLD='\033[[0;1m'
RESET='\033[[0m'

printf "$${BOLD}Starting Webgit setup$${RESET}\n\n"

# Wait for node and npm to be available if requested
if [ "${WAIT_FOR_NODE}" = "true" ]; then
  printf "$${BOLD}Waiting for node and npm to be available...$${RESET}\n"

  WAIT_TIME=0
  TIMEOUT=${NODE_WAIT_TIMEOUT}

  while ! command -v node &> /dev/null || ! command -v npm &> /dev/null; do
    if [ $WAIT_TIME -ge $TIMEOUT ]; then
      printf "❌ Timeout waiting for node and npm after $${TIMEOUT}s\n"
      printf "Please ensure node and npm are installed or set wait_for_node=false\n"
      exit 1
    fi

    if [ $((WAIT_TIME % 10)) -eq 0 ]; then
      printf "Waiting for node and npm... ($${WAIT_TIME}s/$${TIMEOUT}s)\n"
    fi

    sleep 2
    WAIT_TIME=$((WAIT_TIME + 2))
  done

  printf "✅ node $(node --version) and npm $(npm --version) are available\n\n"
fi

# Verify node and npm are available
if ! command -v node &> /dev/null; then
  printf "❌ node is not installed. Please install node first or enable wait_for_node if using another module to install it.\n"
  exit 1
fi

if ! command -v npm &> /dev/null; then
  printf "❌ npm is not installed. Please install npm first or enable wait_for_node if using another module to install it.\n"
  exit 1
fi

printf "$${BOLD}Installing/running webgit$${RESET}\n\n"

# Expand directory path (handle ~)
REPO_DIR=${DIRECTORY}
REPO_DIR=$${REPO_DIR/\~/$HOME}

# Ensure the directory exists
if [ ! -d "$REPO_DIR" ]; then
  printf "⚠️  Directory $REPO_DIR does not exist, creating it...\n"
  mkdir -p "$REPO_DIR"
fi

printf "🛠️  Configuration:\n"
printf "   Repository: $REPO_DIR\n"
printf "   Port: ${PORT}\n"
printf "   Logs: ${LOG_PATH}\n\n"

printf "$${BOLD}Starting webgit in background...$${RESET}\n\n"

# Run webgit in the background
# Note: webgit doesn't support base path, so subdomain is recommended
cd "$REPO_DIR"
npx -y @rodriguezst_/webgit --port ${PORT} --dir "$REPO_DIR" >> ${LOG_PATH} 2>&1 &

printf "🚀 Webgit is starting at http://localhost:${PORT}\n\n"
printf "📝 Logs at ${LOG_PATH}\n\n"
printf "🎉 Setup complete!\n\n"
