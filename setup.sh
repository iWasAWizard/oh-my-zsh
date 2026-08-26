#!/usr/bin/env bash

set -euo pipefail

# --- dependency checks ---

if ! command -v zsh &>/dev/null; then
    echo "zsh is required but was not found. Install it first (e.g. 'sudo apt install zsh' or 'brew install zsh')." >&2
    exit 1
fi

if ! command -v git &>/dev/null; then
    echo "git is required but was not found. Install it first." >&2
    exit 1
fi

# --- set zsh as the default shell ---

zsh_path="$(command -v zsh)"
if [[ "${SHELL:-}" != "${zsh_path}" ]]; then
    if grep -qx "${zsh_path}" /etc/shells 2>/dev/null; then
        echo "Setting zsh as your default shell (you may be prompted for your password)..."
        chsh -s "${zsh_path}" || echo "  Warning: chsh failed — set your default shell to zsh manually." >&2
    else
        echo "Warning: ${zsh_path} isn't listed in /etc/shells, skipping chsh." >&2
        echo "  Add it manually (as root: echo ${zsh_path} >> /etc/shells) then run: chsh -s ${zsh_path}" >&2
    fi
fi

# --- install Oh My Zsh if missing ---

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH

if [[ ! -d "${ZSH}" ]]; then
    echo "Oh My Zsh not found at ${ZSH}, installing..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# --- clone or update the custom plugins that don't ship with Oh My Zsh ---
# (git, docker, docker-compose, common-aliases, colored-man-pages, colorize,
#  command-not-found, copypath, copyfile, extract, emoji all ship with OMZ itself
#  or just wrap an existing binary, so there's nothing to install for those.)

custom_plugin_names=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    zsh-autocomplete
    you-should-use
)

custom_plugin_urls=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/zdharma-continuum/fast-syntax-highlighting"
    "https://github.com/marlonrichert/zsh-autocomplete"
    "https://github.com/MichaelAquilina/zsh-you-should-use"
)

for i in "${!custom_plugin_names[@]}"; do
    name="${custom_plugin_names[$i]}"
    url="${custom_plugin_urls[$i]}"
    plugin_dir="${ZSH_CUSTOM}/plugins/${name}"

    if [[ -d "${plugin_dir}" ]]; then
        echo "Updating ${name}..."
        git -C "${plugin_dir}" pull --ff-only --quiet \
            || echo "  Warning: couldn't fast-forward ${name}, leaving it as-is"
    else
        echo "Cloning ${name}..."
        git clone --quiet --depth 1 "${url}" "${plugin_dir}"
    fi
done

# --- standalone tools that aren't Oh My Zsh plugins ---

if ! command -v fzf &>/dev/null; then
    echo "fzf not found, installing..."
    if [[ ! -d "${HOME}/.fzf" ]]; then
        git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    fi
    "${HOME}/.fzf/install" --all --no-update-rc
fi

if ! command -v thefuck &>/dev/null; then
    if command -v pip3 &>/dev/null; then
        echo "Installing thefuck via pip3..."
        pip3 install --user thefuck
    else
        echo "thefuck not found and pip3 isn't available — install it manually: https://github.com/nvbn/thefuck" >&2
    fi
fi

if ! command -v autopep8 &>/dev/null; then
    if command -v pip3 &>/dev/null; then
        echo "Installing autopep8 via pip3..."
        pip3 install --user autopep8
    fi
fi

# --- symlink .zshrc into place ---

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
