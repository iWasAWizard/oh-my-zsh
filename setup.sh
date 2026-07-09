#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_zshrc="${script_dir}/.zshrc"
target_zshrc="${HOME}/.zshrc"

if [[ ! -f "${source_zshrc}" ]]; then
    echo "Repository .zshrc not found at ${source_zshrc}" >&2
    exit 1
fi

if [[ -L "${target_zshrc}" ]] && [[ "$(readlink "${target_zshrc}")" == "${source_zshrc}" ]]; then
    echo "${target_zshrc} already points to ${source_zshrc}"
    exit 0
fi

if [[ -e "${target_zshrc}" || -L "${target_zshrc}" ]]; then
    backup_path="${target_zshrc}.backup.$(date +%Y%m%d%H%M%S)"
    mv -- "${target_zshrc}" "${backup_path}"
    echo "Backed up existing ${target_zshrc} to ${backup_path}"
fi

ln -s -- "${source_zshrc}" "${target_zshrc}"

echo "Linked ${target_zshrc} -> ${source_zshrc}"
echo "Open a new shell or run 'source ~/.zshrc' to load the configuration."
