## How to set up
`git ls-files .* | xargs -I % -L 1 ln -s "path/to/sync/dir"/% ~/`
