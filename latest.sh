#!/bin/bash -eux

export CARGO_HOME="/cargo"
export RUSTUP_HOME="/rustup"

# shellcheck disable=SC1091
source /cargo/env

rustup toolchain install stable --profile=minimal
STABLE=$(rustup check | grep stable | grep -E "[0-9]+\.[0-9]+\.[0-9]+" -o)
DEFAULT=$(rustup show | grep -m 1 default | grep -E "[0-9]+\.[0-9]+\.[0-9]+" -o)
echo "::set-output name=stable_rust::${STABLE}"
echo "${STABLE}"
if [ "${STABLE}" == "${DEFAULT}" ]; then
  exit 0
else 
  gh issue create --title "Time to update to Rust ${STABLE}" --body "Build update for Rust ${STABLE}"
  exit 1
fi