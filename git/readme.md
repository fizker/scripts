git
===

This folder contains various git-scripts.

Most notably is [alias.txt](alias.txt), which is a mirror of the various git
aliases that I use.


Setting up the hooks
--------------------

Run `git install-hooks --init` to initialize the system and have new repos automatically getting the templates.

Run `git install-hooks <local repo> [more local repos, ...]` to copy the currently configured template hooks into the specified repos.


Repo-specific hooks
-------------------

Hooks installed in `.git/hooks` will automatically be executed after the global scripts.

Hooks that are installed using `git config core.hooksPath` will be registered when `git install-hooks <local repo>` is executed, and also run automatically after the global hooks.
