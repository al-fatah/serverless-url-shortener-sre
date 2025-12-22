#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/package_lambda.sh create
#   ./scripts/package_lambda.sh retrieve

NAME="${1:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="$ROOT/terraform/env/dev/artifacts"

mkdir -p "$OUTDIR"

case "$NAME" in
  create)
    SRCDIR="$ROOT/src/create-url-lambda"
    ZIP="$OUTDIR/create-url-lambda.zip"
    ;;
  retrieve)
    SRCDIR="$ROOT/src/retrieve-url-lambda"
    ZIP="$OUTDIR/retrieve-url-lambda.zip"
    ;;
  *)
    echo "Invalid target. Use: create | retrieve"
    exit 1
    ;;
esac

rm -f "$ZIP"
cd "$SRCDIR"

# For now: zip code only (boto3 exists in Lambda runtime)
zip -r "$ZIP" . -x "tests/*" ".venv/*" "__pycache__/*" "*.pyc"

echo "Created: $ZIP"
