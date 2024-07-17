emulate sh
if [ -e ~/.profile ]; then
    source ~/.profile
fi
emulate zsh

if [[ $SHLVL == 1 ]]; then
    source ~/.zpath
fi
