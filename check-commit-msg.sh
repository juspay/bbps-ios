#!/bin/bash
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
if [[ ! $COMMIT_MSG =~ ^(fix|feat|break|chore|docs|style|refactor|test|ci):.*$ ]]; then
  echo "❌ Commit message must follow conventional format:"
  echo "   fix: for bug fixes (patch version bump)"
  echo "   feat: for new features (minor version bump)"
  echo "   break: for breaking changes (major version bump)"
  echo "   chore: for maintenance tasks (no version bump)"
  echo "   docs|style|refactor|test|ci: for other changes"
  echo ""
  echo "Current message: $COMMIT_MSG"
  exit 1
fi
echo "✅ Commit message format is valid"