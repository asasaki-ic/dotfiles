
############ zplug ############

if [ ! -e ~/.zplug ]; then
  git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:"bin/fzf-tmux"
zplug "mrowa44/emojify", as:command 
zplug "arks22/zsh-gomi", as:command, use:bin/gomi
zplug "seebi/dircolors-solarized"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", nice:10

#install plugins not installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose



############ general ############

autoload -U colors

eval $(gdircolors $ZPLUG_HOME/repos/seebi/dircolors-solarized/dircolors.ansi-universal)

stty stop undef
stty start undef

#highlight dir in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
#highlight completions
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-separator '-->'

export EDITOR=vim
export LANG=en_US.UTF-8

export TERM=xterm-256color

bindkey -v 

function set_end_status() {
  if [ -n "$BUFFER" ]; then
    zle accept-line
    return 0
  fi
}

function _tmuximum() {
  tmuximum
  zle reset-prompt
}

zle -N __tmuximum _tmuximum
zle -N _set_end_status set_end_status

bindkey '^s' __tmuximum
bindkey '^m' _set_end_status


#save 10000 historys
HISTFILE=$HOME/.zsh-history
HISTSIZE=10000
SAVEHIST=10000

#set options
setopt auto_cd
setopt correct
setopt no_beep
setopt share_history
setopt mark_dirs 
setopt interactive_comments
setopt list_types
setopt print_eight_bit
setopt auto_param_keys
setopt auto_list
setopt prompt_subst

PATH=$PATH:$HOME/dotfiles/bin



############ aliases ############

if [[ $(uname -s) = "Darwin" ]]; then
  alias l="gls -X --color=auto"
  alias ls="gls -AX --color=auto"
elif [[ $(uname -s) = "Linux" ]]; then
  alias l="ls"
  alias ls="ls -a"
fi

alias vi="vim"
alias vimf="vim +VimFilerExplorer"
alias q="exit"
alias tls="tmux list-sessions"
alias tnw="tmux new-window"
alias reload="exec $SHELL -l"
alias d="gomi"
alias c="powered_cd"
alias rl="rails"
alias cl="clear"
alias vag="vagrant"
alias g="git"
alias glog="git_log_fzf"
alias gac="git add -A && git-commit-automatically"
alias gacp="git add -A && git-commit-automatically && git push origin master"
alias gdc="git reset --hard HEAD^"
alias gs="git status"
alias ch="open -a Google\ Chrome"
alias gg="google"
alias electron="reattach-to-user-namespace electron"
alias -g G="| grep"
alias -g F="| fzf-tmux"
alias -s rb="ruby"
alias -s py='python'



############ prompt ############
#excute before display prompt
function precmd() {
  if git_info=$(git status 2>/dev/null ); then
    [[ $git_info =~ "Changes not staged" ]] &&  git_unstaged="%K{blue}%F{black} ± %f%k" || git_unstaged=""
    [[ $git_info =~ "Changes to be committed" ]] && git_uncommited="%{[30;48;5;013m%}%F{black} + %k%f" || git_uncommited=""
    [ -z "${git_unstaged}${git_uncommited}" ] && git_clean="%K{green}%F{black} ✔ %f%k" || git_clean=""
    git_branch="$(echo $git_info | awk 'NR==1 {print $3}')"
    git_info="%K{black} ${git_branch} ${git_unstaged}${git_uncommited}${git_clean}"
  fi
  [ $(whoami) = "root" ] && root="%K{black}%F{yellow} ⚡ %{[38;5;010m%}│%f%k"
  dir_info=$dir
  dir="%F{cyan}%K{black} %~ %k%f"
}

dir="%F{cyan}%K{black} %~ %k%f"

PROMPT='%(?,,%F{red}%K{black} ✘%f %{[38;5;010m%}│%f%k)${root}${dir_info} '
RPROMPT='${git_info}'
PROMPT2='%F{blue}» %f'



############ cd ############

function chpwd() {
  if [[ ! $PWD = $HOME ]] ; then
    echo -n "${fg[yellow]}[list] : ${reset_color}"
    ls
  fi
  local i=0
  cat ~/.powered_cd.log | while read line; do
    (( i++ ))
    if [ i = 30 ]; then
      sed -i -e "30,30d" ~/.powered_cd.log
    elif [ "$line" = "$PWD" ]; then
      sed -i -e "${i},${i}d" ~/.powered_cd.log 
    fi
  done
  echo "$PWD" >> ~/.powered_cd.log
}

function powered_cd() {
  case $# in 
    0 ) cd $(gtac ~/.powered_cd.log | fzf-tmux) ;;
    1 ) cd $1 ;;
    * ) echo "powered_cd: too many arguments" ;;
  esac
}

_powered_cd() {
  _files -/
}

compdef _powered_cd powered_cd



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
