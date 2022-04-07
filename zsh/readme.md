zsh
===

To set up zsh:

1. Check out this repo into a local folder (in the example, I have it checkout out to `~/Development/scripts`
2. Create file `~/.zshrc`, if it does not exist
3. Add the following lines to `~/.zshrc`:
   ```
   FZK_SCRIPT_FOLDER=~/Development/scripts
   source $FZK_SCRIPT_FOLDER/zsh/zshrc
   ```

Note that a bunch of the scripts require node.js, so a recent version of this needs to be installed.

Any future changes to defaults will automatically be picked up now.
