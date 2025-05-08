#! /bin/bash

echo "This is not meant to be run in development. Please run it in production."
echo "Do you want to continue? (y/n)"
read -r -p "Answer: " response

if [ "$response" != "y" ]; then
    echo "Exiting..."
    exit 0
fi

echo "Updating..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found. Please run this script from the root of the project."
    exit 2
fi

# Extract GitHub URL from package.json
GITHUB_URL=$(jq -r '.repository' package.json)

echo "Found repository URL: $GITHUB_URL"

TEMP_DIR="update-$(date +%s)"

# Create a temporary directory for cloning
mkdir -p "$TEMP_DIR"
echo "Created temporary directory: $TEMP_DIR"

# Clone the repository to the temporary directory
echo "Cloning repository..."
git clone "$GITHUB_URL" "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository."
    rm -rf "$TEMP_DIR"
    exit 3
fi

# Copy files from temporary directory to current directory (excluding .git)
echo "Updating files..."
rsync -av --exclude='.git' "$TEMP_DIR"/ ./

# Clean up temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"
rm .git
rm .gitignore
rm .prettierrc
rm README.md

# Install dependencies if bun is available
if command -v bun &> /dev/null && [ -f "package.json" ]; then
	echo "Installing dependencies..."
	bun install
	echo "Building..."
	bun run build
	echo "Removing not needed files..."
	rm -rf node_modules
	echo "Starting..."
	bun start
fi

