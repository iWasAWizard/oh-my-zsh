# oh-my-zsh

Personal zsh configuration for a Kali- or Ubuntu-style environment.

## What's included

- a plugin list for common CLI workflows
- completion and history tuning
- a two-line prompt with a one-line toggle on `Ctrl+P`
- aliases and helper functions for everyday shell use
- optional integrations for syntax highlighting, autosuggestions, fzf, and `thefuck`

## Prerequisites

- `zsh`
- any optional tools you want the config to pick up automatically, such as:
  - `zsh-syntax-highlighting`
  - `zsh-autosuggestions`
  - `fzf`
  - `thefuck`

The config checks for those tools before loading them, so missing optional packages are safe.

## Setup

Run the setup script from the repository root:

```sh
./setup.sh
```

The script:

1. verifies that the repository `.zshrc` exists
2. backs up your current `~/.zshrc` if needed
3. creates a symlink from `~/.zshrc` to this repository copy

After setup, start a new shell or run:

```sh
source ~/.zshrc
```

If zsh is not your default shell yet, change it with your preferred system command, for example `chsh -s "$(command -v zsh)"`.
