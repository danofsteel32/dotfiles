# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi

unset rc

source /usr/share/fzf/shell/key-bindings.bash

# Explicit PATH lookup order
local_bin="${HOME}/.local/bin"
usr_local_bin="/usr/local/bin:/usr/local/sbin"
usr_bin="/usr/bin:/usr/sbin"
go_bin="${HOME}/go/bin:/usr/local/go/bin"
PATH="${local_bin}:${usr_local_bin}:${usr_bin}:${go_bin}"

# I support XDG
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

export COLORTERM=truecolor
export BAT_THEME="gruvbox-dark"
export EDITOR='nvim'
export MANPAGER='nvim +Man!'
export MOZ_ENABLE_WAYLAND=1
export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"

# for aravis gstreamer plugin
export GI_TYPELIB_PATH=/usr/local/lib64/girepository-1.0
export GST_PLUGIN_PATH=/usr/local/lib64/gstreamer-1.0

shopt -s histappend
export HISTTIMEFORMAT='%F %T '
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups:erasedups:ignorespace

alias vim='nvim'
alias ls='eza --hyperlink'
alias la='eza -a --hyperlink'
alias ll='eza -alg --sort new --group-directories-first --hyperlink'
alias diskusage='du -S | sort -nr | $PAGER'
alias osrs='GDK_SCALE=2 java -jar ./Downloads/RuneLite.jar'
alias gittree='git ls-tree -r main --name-only'
alias code='code --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto'
alias docker='podman'
alias g='git status'
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias cheat='cat ~/Documents/cheatsheet.md'

f() {
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
      fzf --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
          --bind 'enter:become(vim {1} +{2})'
}

#    : | rg_prefix='rg --column --line-number --no-heading --color=always --smart-case' \
#        fzf --bind 'start:reload:$rg_prefix ""' \
#            --bind 'change:reload:$rg_prefix {q} || true' \
#            --bind 'enter:become(vim {1} +{2})' \
#            --ansi --disabled \
#            --height=50% --layout=reverse $1

# https://codeberg.org/dnkl/foot/issues/628
# bind '"\e[27;2;13~":"\n"'
# bind '"\e[27;5;13~":"\n"'

