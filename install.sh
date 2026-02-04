#!/bin/bash
set -euo pipefail

echo "Building wt in release mode..."
swift build -c release

echo "Installing to /usr/local/bin/wt..."
sudo cp .build/release/wt /usr/local/bin/wt

echo "wt installed successfully to /usr/local/bin/wt"
echo "Run 'wt --help' to get started."
