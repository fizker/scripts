scripts
========

This is a collection of scripts of various sorts, that I find helpful/essential
in my daily stint as a developer.


## Various things needed for complete a setup


### SSH

Generate new key: `ssh-keygen -t ed25519 -C "your_email@example.com"`

Tying that key to a site in `~/.ssh/config`:

```
Host <host>
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/<private key>
```


### Git

- Add the bundled config: `git config --global include.path <path to scripts>/git/config`
- Set name and email: `git config --global user.name ...`, `git config --global user.email`
- Folder-specific shared git configs for having a different email for a set of projects:

```
[includeIf "gitdir:~/Development/foo/"]
	path = ~/Development/foo/gitconfig
```

### VS Code

~/Library/Application Support/Code/User contains various user-stuff that is
interesting, like settings.json, keybindings.json and potentially snippets.
