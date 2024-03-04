## .zpath
`.zpath` requires setting
```
if [[ $SHLVL == 1 && ! -o LOGIN ]]; then
    source ~/.zpath
fi
```
in `/etc/zshenv`

(See https://www.zsh.org/mla/users/2003/msg00600.html)

## How to set up
`git ls-files .* | xargs -I % -L 1 ln -s "path/to/sync/dir"/% ~/`
