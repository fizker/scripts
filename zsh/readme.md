zsh
===

## Shell setup

Paste the following into `~/.zshrc`:

```
# Change tab size from 8 to 4
tabs -4

# Make the various word-movements respect / as a word separator (zsh is useless in the default behaviour)
WORDCHARS=`echo $WORDCHARS | sed s-/--g | sed s/-//g`

# Disable the windows-like behaviour where tabbing multiple times start cycling all available completions
setopt noautomenu

# Change prompt to the default from bash: '<machine name>:<current folder> <user>$ '
PROMPT='%m:%1~ %n$ '
```

## Completions

Execute this as part of `.zshrc` file:

```
# Update completions to include the custom git commands
zstyle ':completion:*:*:git:*' user-commands \
	clean-local-branches:'removes local branches that are merged with HEAD' \
	rebase-continue-no-verify:'--no-verify for rebase --continue'

# Generate and include Swift completions
swift package completion-tool generate-zsh-script > ~/.completions/_swift
source ~/.completions/_swift
```
