#!/usr/bin/env bash
set -euo pipefail

RUNNER_HOME="${RUNNER_HOME:-/home/GHA/actions-runner}"
RUNNER_SRC="${RUNNER_SRC:-/opt/actions-runner}"
RUNNER_USER="${RUNNER_USER:-GHA}"

mkdir -p "$RUNNER_HOME"

# The runner-data volume is root-owned on first use; fix ownership so the runner
# can write its config and work files.
if [[ "$(id -u)" == "0" ]]; then
  chown -R "$RUNNER_USER":"$RUNNER_USER" "$RUNNER_HOME" || true
fi

run_as_runner() {
  if [[ "$(id -u)" == "0" ]]; then
    exec gosu "$RUNNER_USER" "$@"
  else
    exec "$@"
  fi
}

# If the runner directory is a fresh volume, populate it with the runner binaries.
if [[ ! -f "$RUNNER_HOME/run.sh" || ! -f "$RUNNER_HOME/config.sh" ]]; then
  echo "Initializing runner directory at $RUNNER_HOME"
  cp -a "$RUNNER_SRC/." "$RUNNER_HOME/"
  if [[ "$(id -u)" == "0" ]]; then
    chown -R "$RUNNER_USER":"$RUNNER_USER" "$RUNNER_HOME" || true
  fi
fi

cd "$RUNNER_HOME"

# Configure once; persist via volume (.runner file).
if [[ ! -f ".runner" ]]; then
  if [[ -z "${GITHUB_URL:-}" || -z "${RUNNER_TOKEN:-}" ]]; then
    echo "ERROR: First-time config requires GITHUB_URL and RUNNER_TOKEN" >&2
    exit 1
  fi

  RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
  RUNNER_LABELS="${RUNNER_LABELS:-linux,arm64}"
  RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"

  echo "Configuring runner '$RUNNER_NAME' for $GITHUB_URL"
  if [[ "$(id -u)" == "0" ]]; then
    gosu "$RUNNER_USER" ./config.sh \
      --unattended \
      --replace \
      --url "$GITHUB_URL" \
      --token "$RUNNER_TOKEN" \
      --name "$RUNNER_NAME" \
      --work "$RUNNER_WORKDIR" \
      --labels "$RUNNER_LABELS"
  else
    ./config.sh \
    --unattended \
    --replace \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --labels "$RUNNER_LABELS"
  fi
else
  echo "Runner already configured; skipping config."
fi

cleanup() {
  # Optional: remove runner registration on stop if you provide a removal token.
  if [[ "${RUNNER_REMOVE_ON_STOP:-false}" == "true" && -n "${RUNNER_REMOVE_TOKEN:-}" ]]; then
    echo "Removing runner registration..."
    ./config.sh remove --unattended --token "$RUNNER_REMOVE_TOKEN" || true
  fi
}
trap cleanup SIGINT SIGTERM

echo "Starting runner"
run_as_runner ./run.sh
