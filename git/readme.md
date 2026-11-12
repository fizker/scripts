git
===

This folder contains various git-scripts.

It also includes my base standard git config file. Include it with
`git config --global include.path "<path to scripts checkout>/git/config"`.
If settings conflict, anything defined later overrides. So it might be useful to
manually edit `~/.git/config` and ensure that the new `[include]` is located first
in the file.


Setting up the hooks
--------------------

Run `git install-hooks --init` to initialize the system and have new repos automatically getting the templates.

Run `git install-hooks <local repo> [more local repos, ...]` to copy the currently configured template hooks into the specified repos.


Repo-specific hooks
-------------------

Hooks installed in `.git/hooks` will automatically be executed after the global scripts.

Hooks that are installed using `git config core.hooksPath` will be registered when `git install-hooks <local repo>` is executed, and also run automatically after the global hooks.


Other useful git commands
-------------------------

- `git config --local fizker.hooksPath <local-path>` - Sets up whatever hooks are in `local-path` to be evaluated as appropriate.
- `git config --local include.path ../.gitconfig` - Sets up `../.gitconfig` to be included as a complement to `.git/config`. The path is relative to `.git/config`.
