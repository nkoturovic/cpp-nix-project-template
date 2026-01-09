#!/usr/bin/env bash
set -e

FORCE=0
if [ "$1" == "--force" ]; then FORCE=1; fi

# NIX_CFLAGS_COMPILE is provided by the nix-shell environment
CURRENT_HASH=$(echo "$NIX_CFLAGS_COMPILE" | sha256sum | cut -d' ' -f1)
STORED_HASH=$(cat .nix-deps-hash 2>/dev/null || true)

if [ "$FORCE" -eq 1 ] || [ "$CURRENT_HASH" != "$STORED_HASH" ] || [ ! -f compile_commands.json ]; then
  echo "Generating compile commands..."
  
  # Use a temp dir to generate config cleanly
  TMP_DIR=$(mktemp -d)
  # Ensure cleanup happens even if the script fails
  trap 'rm -rf "$TMP_DIR"' EXIT

  # Run CMake configuration (fast, no compilation)
  cmake -S . -B "$TMP_DIR" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON > /dev/null 2>&1
  mv "$TMP_DIR/compile_commands.json" .

  # Inject system flags so VSCode/Clangd works without special environment vars
  # We use python or perl for safer escaping than sed, but sticking to sed for minimal deps:
  FLAGS=$(echo "$NIX_CFLAGS_COMPILE" | sed 's|/|\\/|g')
  sed -i "s|/bin/g++ |/bin/g++ $FLAGS |g" compile_commands.json
  sed -i "s|/bin/c++ |/bin/c++ $FLAGS |g" compile_commands.json
  
  echo "$CURRENT_HASH" > .nix-deps-hash
  echo "Done generating compile commands."
else
  echo "Compile commands are up to date."
fi
