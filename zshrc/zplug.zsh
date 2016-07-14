#zplug

if [ ! -e ~/.zplug ]; then
  git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

autoload -Uz compinit
compinit

zplug "arks22/tmuximum", as:command

zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf

zplug "junegunn/fzf", as:command, use:bin/fzf-tmux

zplug "mrowa44/emojify", as:command 

zplug "b4b4r07/zsh-gomi", if:"which fzf"

zplug "mollifier/anyframe"

zplug "b4b4r07/enhancd", use:init.sh

zplug "b4b4r07/emoji-cli", \
  if:'(( $+commands[jq] ))', \
  on:"junegunn/fzf-bin"

zplug "zsh-users/zsh-history-substring-search"

zplug "zsh-users/zsh-completions"

zplug "zsh-users/zsh-syntax-highlighting"


#未インストールの項目をインストール
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose
