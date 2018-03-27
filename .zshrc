######################## zplug ########################

if [ ! -e ~/.zplug ]; then
  git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:"bin/fzf-tmux"
zplug "arks22/zsh-gomi", as:command, use:bin/gomi
zplug "arks22/auto-git-commit", as:command
zplug "arks22/fshow", as:command
zplug "arks22/tmuximum", as:command
zplug "seebi/dircolors-solarized"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2


#install plugins not installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

if [[ ! $PATH =~ "$HOME/.zplug/bin" ]]; then
  export PATH="$PATH:$HOME/.zplug/bin"
fi

zplug load --verbose


######################## general ########################

autoload -U colors
colors

eval $(gdircolors $ZPLUG_HOME/repos/seebi/dircolors-solarized/dircolors.ansi-universal)

stty stop undef
stty start undef

zstyle ':completion:*:messages' format $'\e[01;35m -- %d -- \e[00;00m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found -- \e[00;00m'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d -- \e[00;00m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d -- \e[00;00m'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _prefix _approximate _history
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-separator '-->'

export EDITOR=nvim
export LANG=en_US.UTF-8

export TERM=xterm-256color

export XDG_CONFIG_HOME=$HOME/.config

bindkey -v

#save 10000 historys
HISTFILE=$HOME/.zsh-history
HISTSIZE=10000
SAVEHIST=10000

#set options
setopt auto_cd
#setopt correct
setopt no_beep
setopt share_history
setopt mark_dirs
setopt interactive_comments
setopt list_types
setopt print_eight_bit
setopt auto_param_keys
setopt auto_list
setopt correct
setopt prompt_subst


######################## aliases ########################

if [[ $(uname -s) = "Darwin" ]]; then
  alias l="gls -X --color=auto"
  alias ls="gls -AX --color=auto"
elif [[ $(uname -s) = "Linux" ]]; then
  alias l="ls"
  alias ls="ls -a"
fi
alias vi="vim"
alias q="exit"
alias tx="tmux"
alias reload="exec $SHELL -l"
alias d="gomi"
alias t="tmuximum"
alias c="powered_cd"
alias rl="rails"
alias cl="clear"
alias vag="vagrant"
alias gs="git status"
alias electron="reattach-to-user-namespace electron"
alias -g F="| fzf-tmux"
alias -s rb="ruby"
alias -s py='python'
alias g="git"
alias glog="git-log-fzf"
alias gac="git add -A && auto-git-commit"
alias gacp="git_add_commit_push"
alias gps="git_push_current_branch"

function git_add_commit_push() {
  git add -A && auto-git-commit && git push origin $(git branch | awk '/\*/' | sed -e "s/*//")
}

function git_push_current_branch {
  git push origin $(git branch | awk '/\*/' | sed -e "s/*//")
}


######################## prompt ########################

#excute before display prompt
function precmd() {
  [ $(whoami) = "root" ] && root="%K{black}%F{yellow} ⚡ %{\e[38;5;010m%}│%f%k" || root=""
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  else
    dir="%F{cyan}%K{black} %~ %k%f"
    if git_status=$(git status 2>/dev/null ); then
      git_branch="$(echo $git_status| awk 'NR==1 {print $3}')"
      case $git_status in
        *Changes\ not\ staged* ) state=$'%{\e[30;48;5;013m%}%F{black} ± %f%k' ;;
        *Changes\ to\ be\ committed* ) state="%K{blue}%F{black} + %k%f" ;;
        * ) state="%K{green}%F{black} ✔ %f%k" ;;
      esac
      if [[ $git_branch = "master" ]]; then
        git_info="%K{black}%F{blue}⭠ ${git_branch}%f%k ${state}"
      else
        git_info="%K{black}⭠ ${git_branch}%f ${state}"
      fi
    else
      git_info=""
    fi
  fi
}


if [ -z $TMUX ]; then
  PROMPT=$'%(?,,%F{red}%K{black} ✘%f %{\e[38;5;010m%}│%f%k)${root}${dir} '
  RPROMPT=$'${git_info}'
else
  PROMPT=$'%(?,,%F{red}%K{black} ✘%f %{\e[38;5;010m%}│%f%k)${root}%F{blue}%K{black} > %f%k'
fi

SPROMPT='zsh: correct? %F{red}%R%f -> %F{green}%r%f [y/n]:'
PROMPT2='%F{blue}» %f'

function command_not_found_handler() {
  echo "zsh: command not found: ${fg[red]}$0${reset_color}"
  exit 1
}


######################## cd ########################

function chpwd() {
  if [[ ! $PWD = $HOME ]] ; then
    echo -n "${fg[yellow]}[list: ${fg[cyan]}$PWD${reset_color} ${fg[yellow]}] -> ${reset_color}"
    ls
  fi
  local i=0
  pwd_=$(echo $PWD | sed -e s@${HOME}@~@)
  cat ~/.powered_cd.log | while read line; do
    (( i++ ))
    if [ "$line" = "$pwd_" ]; then
      sed -i -e "${i},${i}d" ~/.powered_cd.log
    fi
  done
  echo "${pwd_}" >> ~/.powered_cd.log
}

function powered_cd() {
  case $# in
    0 ) 
      test -f ~/.powered_cd.log 2>/dev/null || touch ~/.powered_cd.log
      cd "$(gtac ~/.powered_cd.log | fzf-tmux -r | sed -e s@~@${HOME}@)"
    ;;
    1 ) cd "$1" ;;
    2 ) mv "$1" "$2" ;;
    * ) echo "powered_cd: too many arguments" ;;
  esac
}

_powered_cd() {
  _files -/
}

compdef _powered_cd powered_cd


######################## tmux ########################

if [ ! -z $TMUX ]; then
  i=0
  n=$(expr $(tput cols) / 4 - 1)
  while [ $i -lt $n ] ; do
    (( i++ ))
    str="${str}- "
  done
  echo "${str}${fg_bold[red]}TMUX ${reset_color}${str}"
  i=0
elif [[ ! $(whoami) = "root" ]]; then
  tmuximum
fi
