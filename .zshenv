# Configure paths before loading the shell
if [[ $SHLVL == 1 && ! -o LOGIN ]]; then
    source ~/.zpath
fi

# Sets environmental variabes

# Default editor
export EDITOR=nvim
export VISUAL="$EDITOR"
# GPG
GPG_TTY=$(tty)
export GPG_TTY
# Lang settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# Ruby
# For compilers to find Ruby
# export LDFLAGS="-L$HOMEBREW_PREFIX/opt/ruby/lib"
# export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/ruby/include"
# For pckgconfig to find Ruby
# export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/ruby/lib/pkgconfig"
