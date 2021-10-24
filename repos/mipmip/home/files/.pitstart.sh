#!/bin/sh

## The latest version of this file should be copied to pimsnel.com
echo "PIT START ..."
cd ~
git clone --bare git@github.com:mipmip/dotfiles-pim.git .dotfiles-pim
alias pit='git --git-dir=$HOME/.dotfiles-pim/ --work-tree=$HOME'
pit checkout
chsh -s /bin/zsh pim
