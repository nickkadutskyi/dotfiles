## How to set up
`git ls-files ':(glob).*' ':!:.gitignore' | xargs -I % -L 1 ln -s "path/to/sync/dir"/% ~/`
