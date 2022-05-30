case `uname` in
  Darwin)
    alias vim='/usr/local/bin/vim'
    alias mtvim='mvim --remote-tab-silent'
    ;;
  Linux)
    alias open='linux-open'
    ;;
esac

#RAILS DEV
alias rake='noglob rake'
alias bex='bundle exec'
alias cap='noglob cap'

#DOCKER COMPOSE
alias dex='docker-compose exec'

alias t='TERM=xterm-256color tmux a'
alias tmux='TERM=xterm-256color tmux'

# Pim's commands
DEFAULT_COMMIT_MSG="changes from $(uname -n) on $(date)"
alias pit='git --git-dir=$HOME/.dotfiles-pim/ --work-tree=$HOME'
alias pitadd='cat ~/.pit-add-files | xargs -I % git --git-dir=$HOME/.dotfiles-pim/ --work-tree=$HOME add %'
alias pitpush='pit commit -a -m "$DEFAULT_COMMIT_MSG" && pit push'

alias pake='noglob rake -f ~/Rakefile'

function linux-open () {
    # xdg-open "$*"
    #nohup xdg-open "$*" &
    nohup xdg-open "$*" > /dev/null 2>&1 &
}

