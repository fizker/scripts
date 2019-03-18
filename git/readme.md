git
===

This folder contains various git-scripts.

Most notably is [alias.txt](alias.txt), which is a mirror of the various git
aliases that I use.

Setting up the hooks
--------------------

Run `git install-hooks --init` to initialize the system and have new repos automatically getting the templates.

Run `git install-hooks <local repo> [more local repos, ...]` to copy the currently configured template hooks into the specified repos.
