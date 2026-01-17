#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
NIX_DIR="${DOTFILES_DIR}/nix"
NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
FLAKE_FILE="${NIX_DIR}/flake.nix"

if [ ! -x "${NIX_BIN}" ]; then
  echo "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

if [ "${CODESPACES:-}" = "true" ]; then
  if [ -e /nix/var/nix/profiles/default/bin/nix-daemon ] && ! pgrep -x nix-daemon > /dev/null; then
    echo "Starting nix-daemon..."
    sudo /nix/var/nix/profiles/default/bin/nix-daemon > /dev/null 2>&1 &
    echo "Waiting for nix-daemon socket..."
    for i in $(seq 1 30); do
      if [ -S /nix/var/nix/daemon-socket/socket ]; then
        echo "nix-daemon is ready."
        break
      fi
      sleep 1
    done
    if [ ! -S /nix/var/nix/daemon-socket/socket ]; then
      echo "Error: nix-daemon socket not available after 30 seconds."
      exit 1
    fi
  fi
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

if ! command -v nix &>/dev/null; then
  echo "Error: Nix installation failed."
  exit 1
fi

mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >>~/.config/nix/nix.conf
fi

CURRENT_SYSTEM="$(nix eval --raw --impure --expr 'builtins.currentSystem')"

cd "${NIX_DIR}"

cp "${FLAKE_FILE}" "${FLAKE_FILE}.bak"
sed -e "s/@USERNAME@/${USER}/g" -e "s/@SYSTEM@/${CURRENT_SYSTEM}/g" "${FLAKE_FILE}.bak" >"${FLAKE_FILE}"

cleanup() {
  mv "${FLAKE_FILE}.bak" "${FLAKE_FILE}"
}
trap cleanup EXIT

echo "Applying Home Manager configuration for ${USER}@${CURRENT_SYSTEM}..."
nix run home-manager -- switch -b backup --flake .#default
