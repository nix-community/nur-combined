function vcs_info() {
  test -d ".bzr" && which bzr >/dev/null 2>&1 && bzr_prompt_info
  test -d ".git" && which git >/dev/null 2>&1 && git_prompt_info
  test -d ".hg"  && which hg  >/dev/null 2>&1 && hg_prompt_info
}

function theme_precmd() {
  local SIZE_PROMPT=${#${(%):---(%n@%M)---()--}}
  local SIZE_PWD=${#${(%):-%~}}
  local SIZE_DATE=23

  PR_FILLBAR_PRE="\${(l.(${COLUMNS} - (${SIZE_PROMPT} + ${SIZE_PWD} + ${SIZE_DATE} + 1))..─.)}"
}

setprompt() {
  setopt prompt_subst

  if [[ $UID -eq 0 ]]; then
    local PR_COLOR_001=$'%{\e[0;31;40m%}'
    local PR_PROMT="#"
  else
    local PR_COLOR_001=$'%{\e[0;32;40m%}'
    local PR_PROMT="$"
  fi

  local PR_COLOR_002=$'%{\e[1;34;40m%}'
  local PR_COLOR_003=$'%{\e[1;30;40m%}'
  local PR_COLOR_004=$'%{\e[0;36;40m%}'
  local PR_COLOR_005=$'%{\e[1;37;40m%}'
  local PR_COLOR_006=$'%{\e[0;33;40m%}'
  local PR_COLOR_007=$'%{\e[0;35;40m%}'
  local PR_COLOR_008=$'%{\e[0;32;40m%}'
  local PR_COLOR_RST=$'%{\e[0m%}'

  local PR_DATE="%Y-%m-%d"
  local PR_TIME="%H:%M:%S"
  local PR_FILLBAR=$'${(e)PR_FILLBAR_PRE}'
  local PR_VCS_INFO=$'$(vcs_info)'

  PROMPT="${PR_COLOR_002}\
┌─[${PR_COLOR_RST}${PR_COLOR_001}%n${PR_COLOR_RST}${PR_COLOR_003}@${PR_COLOR_RST}${PR_COLOR_004}%M${PR_COLOR_RST}${PR_COLOR_002}]───[${PR_COLOR_RST}${PR_COLOR_005}%~${PR_COLOR_RST}${PR_COLOR_002}]${PR_FILLBAR}[\
${PR_COLOR_RST}${PR_COLOR_006}%D{"${PR_DATE}"}${PR_COLOR_RST}${PR_COLOR_002}]─[${PR_COLOR_RST}${PR_COLOR_006}%D{"${PR_TIME}"}${PR_COLOR_RST}${PR_COLOR_002}]─┐
└─[${PR_COLOR_RST}${PR_COLOR_007}%?${PR_COLOR_RST}${PR_COLOR_002}]─[${PR_COLOR_RST}${PR_COLOR_008}${PR_VCS_INFO}${PR_COLOR_RST}${PR_COLOR_002}]${PR_COLOR_RST} "
  PROMPT+="${PR_COLOR_RST}${PR_PROMT}${PR_COLOR_RST} "
  RPROMPT="${PR_COLOR_002}[${PR_COLOR_RST}${PR_COLOR_004}%l${PR_COLOR_RST}${PR_COLOR_002}]─┘${PR_COLOR_RST}"

  PROMPT2="${PR_COLOR_RST}──>${PR_COLOR_RST} "
  RPROMPT2="${PR_COLOR_RST}<──${PR_COLOR_RST}"
}

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd
setprompt
