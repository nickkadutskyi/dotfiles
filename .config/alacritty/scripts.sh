#!/bin/zsh

b=$(tput bold)
n=$(tput sgr0)

# If there are any windows with alacritty group and not attached to a client
# then create a new alacritty window and prompt user to select a tmux window
function init-select-window() {
    tmux_format="#{window_id}:#W:#{pane_current_command}:#{?window_active_clients,a,n}:#{session_group}"
    # Gets only windows with alacritty group and not attached to a client
    windows=$(tmux list-windows -F "$tmux_format" | grep ':n:alacritty$')
    if [ ! -z "$windows" ]; then
        alacritty msg create-window --hold -e /bin/zsh \
            -c "~/.config/alacritty/scripts.sh select-window '$windows'"
    fi
}

# Create a new alacritty window and attach to a tmux session selected by user
function select-window() {
    printf '\e]0;%s\e\\' "Select a tmux window"
    if [ -z "$1" ]; then
        echo "No windows provided"
        exit 1
    fi
    sel_win=$(echo $1 | awk -F: '{printf "%-4s (%s) %s\n", $1, $3, $2}' | fzf --height 40% --sort --reverse)
    sel_win_id=$(echo $sel_win | cut -w -f1)
    ses_name=$sel_win_id
    if [ ! -z "$sel_win_id" ]; then
        tmux attach -d -t "$ses_name" \; select-window -t "$sel_win_id"
    else
        echo "No window selected"
        echo $PATH
    fi
}

function usage() {
    echo "${b}Usage:${n} $1 [command [args]]"
    echo "${b}Commands:${n}"
    echo "  ${b}init-select-window${n}               Init tmux widow selector in a new alacritty window."
    echo "  ${b}select-window${n} [list of windows]  Prompt user to select a tmux window to attach to."
}

case "$1" in
"init-select-window")
    init-select-window
    ;;
"select-window")
    select-window $2
    ;;
*)
    usage $0
    exit 1
    ;;
esac
