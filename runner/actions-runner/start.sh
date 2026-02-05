#!/bin/bash
# https://gist.github.com/akrasic/380bda362e0420be08709152c91ca1f9
set -euo pipefail

# exec replaces the current shell process. When the execee dies, so does the container. 
/home/GHA/actions-runner/config.sh --url "$GITHUB_URL" --token "$RUNNER_TOKEN" --unattended
exec /home/GHA/actions-runner/run.sh

# Old vibe code
##!/usr/bin/env bash
#set -euo pipefail
#
#RUNNER_HOME="${RUNNER_HOME:-/home/GHA/actions-runner}"
#RUNNER_SRC="${RUNNER_SRC:-/opt/actions-runner}"
#
#mkdir -p "$RUNNER_HOME"
#
## Populate the persistent directory with runner binaries (first boot only for each file).
#cp -an "$RUNNER_SRC/." "$RUNNER_HOME/" || true
#
#cd "$RUNNER_HOME"
#
## Configure once; persist via volume (.runner file).
#if [[ ! -f ".runner" ]]; then
#  RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
#  RUNNER_LABELS="${RUNNER_LABELS:-linux,arm64}"
#  RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"
#
#  echo "Configuring runner '$RUNNER_NAME' for $GITHUB_URL"
#  ./config.sh \
#    --unattended \
#    --replace \
#    --url "$GITHUB_URL" \
#    --token "$RUNNER_TOKEN" \
#    --name "$RUNNER_NAME" \
#    --work "$RUNNER_WORKDIR" \
#    --labels "$RUNNER_LABELS"
#else
#  echo "Runner already configured; skipping config."
#fi
#
#echo "Starting runner"
#exec ./run.sh
