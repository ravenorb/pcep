#!/usr/bin/env bash

# PCEP Auto Git Push Script
# - Ensures origin remote exists (with PAT if needed)
# - Stages changes
# - Commits with a message (arg or default)
# - Ensures branch 'main' exists
# - Pushes to origin main

set -e

echo "--------------------------------------------------"
echo "        PCEP Auto-Push Script"
echo "--------------------------------------------------"

# Ensure we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[!] This is not a git repository. Run this inside your pcep repo."
  exit 1
fi

# 1. Ensure remote is configured (with PAT if needed)
REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)

if [ -z "$REMOTE_URL" ]; then
  echo "[!] No 'origin' remote detected. Let's configure it."
  printf "Enter your GitHub Personal Access Token (PAT): "
  read -r PAT

  if [ -z "$PAT" ]; then
    echo "[!] PAT cannot be empty."
    exit 1
  fi

  git remote add origin "https://ravenorb:${PAT}@github.com/ravenorb/pcep.git"
  echo "[+] Remote added: https://github.com/ravenorb/pcep.git (with PAT embedded)"
else
  echo "[+] Remote detected: $REMOTE_URL"
fi

# 2. Stage changes
echo "[+] Staging all changes..."
git add .

# 3. Commit
if [ -z "$1" ]; then
  COMMIT_MSG="Auto update"
else
  COMMIT_MSG="$1"
fi

echo "[+] Committing with message: $COMMIT_MSG"

# Allow "nothing to commit" without killing the script
if ! git commit -m "$COMMIT_MSG"; then
  echo "[i] Nothing to commit (working tree clean or no changes)."
fi

# 4. Ensure branch 'main' exists and is current

# If there is at least one commit, HEAD will resolve
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  # If main does not exist or is not current, rename current branch to main
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
  if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "[+] Renaming branch '$CURRENT_BRANCH' to 'main'..."
    git branch -M main
  else
    echo "[+] Already on 'main' branch."
  fi
else
  echo "[!] No commits yet. You must successfully commit at least once before pushing."
  echo "    Try adding some files and re-run this script."
  exit 1
fi

# 5. Push to origin main
echo "[+] Pushing to origin main..."
git push -u origin main

echo "--------------------------------------------------"
echo "[✓] Push complete!"
echo "--------------------------------------------------"
