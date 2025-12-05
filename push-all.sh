#!/usr/bin/env bash

# Auto Git Push Script for PCEP Repo

echo "--------------------------------------------------"
echo "        PCEP Auto-Push Script"
echo "--------------------------------------------------"

# 1. Detect remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo "[!] No Git remote detected. Let's configure it."

    echo -n "Enter your GitHub Personal Access Token (PAT): "
    read -r PAT

    # Set remote with PAT
    git remote add origin "https://ravenorb:${PAT}@github.com/ravenorb/pcep.git"
    echo "[+] Remote added: https://github.com/ravenorb/pcep.git"
else
    echo "[+] Remote detected: $REMOTE_URL"
fi

# 2. Stage changes
echo "[+] Staging all changes..."
git add .

# 3. Commit with provided message
if [ -z "$1" ]; then
    COMMIT_MSG="Auto update"
else
    COMMIT_MSG="$1"
fi

echo "[+] Committing with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 4. Push to main
echo "[+] Pushing to origin main..."
git push -u origin main

echo "--------------------------------------------------"
echo "[✓] Push complete!"
echo "--------------------------------------------------"
