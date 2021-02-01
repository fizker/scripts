zsh
===

To set up zsh:

1. Create file `~/.zshrc`, if it does not exist
2. Add the following lines to the top:
   ```
   FZK_SCRIPT_FOLDER=~/Development/own/scripts/zsh
   source $FZK_SCRIPT_FOLDER/zshrc
   ```

Any future changes to defaults will automatically be picked up now.
