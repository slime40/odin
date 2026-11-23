#!/usr/bin/env bash
set -euo pipefail

version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
  python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))')"

case "$(uname -m)" in
  x86_64 | amd64) arch="x86_64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

archive="lazygit_${version}_Linux_${arch}.tar.gz"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${version}/${archive}" \
  -o "${tmp_dir}/${archive}"
tar -xzf "${tmp_dir}/${archive}" -C "$tmp_dir" lazygit

if [[ -w /usr/local/bin ]]; then
  install -m 0755 "${tmp_dir}/lazygit" /usr/local/bin/lazygit
elif command -v sudo >/dev/null 2>&1; then
  sudo install -m 0755 "${tmp_dir}/lazygit" /usr/local/bin/lazygit
else
  mkdir -p "${HOME}/.local/bin"
  install -m 0755 "${tmp_dir}/lazygit" "${HOME}/.local/bin/lazygit"
fi

lazygit --version
