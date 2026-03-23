#!/bin/sh -ex

cp dotfiles/default-gems ~/.default-gems
cp dotfiles/asdfrc ~/.asdfrc
cp -R dotfiles/bundle ~/.bundle
if [ -d ~/.oh-my-zsh/custom/plugins ]; then
  cp -R dotfiles/oh-my-zsh-custom/plugins/loganleger ~/.oh-my-zsh/custom/plugins/
fi
cp dotfiles/agignore ~/.agignore
cp dotfiles/ctags ~/.ctags
cp dotfiles/gemrc ~/.gemrc
cp dotfiles/gitconfig ~/.gitconfig
cp dotfiles/gitignore ~/.gitignore
cp dotfiles/hushlogin ~/.hushlogin
cp dotfiles/zshenv ~/.zshenv
cp dotfiles/psqlrc ~/.psqlrc
cp dotfiles/terraformrc ~/.terraformrc
cp dotfiles/tm_properties ~/.tm_properties
cp dotfiles/tmux.conf ~/.tmux.conf
cp dotfiles/vimrc ~/.vimrc
cp dotfiles/vimrc.bundles ~/.vimrc.bundles
cp dotfiles/vimrc.local ~/.vimrc.local
mkdir -p ~/.config ~/.local/state/psql
cp -R config/atuin ~/.config/
cp -R config/psql ~/.config/
cp -R config/zellij ~/.config/
cp -R config/zsh ~/.config/
cp -R config/zsh-patina ~/.config/
