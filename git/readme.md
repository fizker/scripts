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

The hooks automatically execute a neighbor script with `.local` appended. This can be used to keeping repo-specific scripts around that the system will not override.

As an example, `pre-commit` executes `pre-commit.local` after running the global scripts.
