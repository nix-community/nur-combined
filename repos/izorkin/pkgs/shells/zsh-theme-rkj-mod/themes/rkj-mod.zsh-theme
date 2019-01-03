function vcs_info() {
  test -d ".bzr" && ( ! which which || which bzr >/dev/null 2>&1 ) && bzr_prompt_info
  test -d ".git" && ( ! which which || which git >/dev/null 2>&1 ) && git_prompt_info
  test -d ".hg"  && ( ! which which || which hg >/dev/null 2>&1 )  && hg_prompt_info
}

function retcode() {
  return $?
}

function theme_precmd() {
  local TERMWIDTH
  (( TERMWIDTH = ${COLUMNS} - 1 ))

  local promptsize=${#${(%):---(%n@%M)---()--}}
  local pwdsize=${#${(%):-%~}}
  local datesize=23

  PR_FILLBAR_PRE="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize + $datesize)))..─.)}"
}

setprompt() {
  setopt prompt_subst

  PR_COLOR1=$'%{\e[0;33m%}'
  PR_COLOR2=$'%{\e[1;34m%}'
  PR_COLOR3=$'%{\e[0;36m%}'
  PR_COLOR4=$'%{\e[1;30m%}'
  PR_COLOR5=$'%{\e[1;32m%}'
  PR_COLOR6=$'%{\e[1;35m%}'
  PR_COLOR7=$'%{\e[1;37m%}'
  PR_COLOR_RST=$'%{\e[0m%}'

  PR_DATE="%Y-%m-%d"
  PR_TIME="%H:%M:%S"
  PR_PROMT="#"
  PR_FILLBAR=$'${(e)PR_FILLBAR_PRE}'
  PR_VCS_INFO=$'$(vcs_info)'

  PROMPT="${PR_COLOR2}\
┌─[${PR_COLOR_RST}${PR_COLOR5}%n${PR_COLOR_RST}${PR_COLOR4}@${PR_COLOR_RST}${PR_COLOR3}%M${PR_COLOR_RST}${PR_COLOR2}]───[${PR_COLOR_RST}${PR_COLOR7}%~${PR_COLOR_RST}${PR_COLOR2}]${PR_FILLBAR}[\
${PR_COLOR_RST}${PR_COLOR1}%D{"${PR_DATE}"}${PR_COLOR_RST}${PR_COLOR2}]─[${PR_COLOR_RST}${PR_COLOR1}%D{"${PR_TIME}"}${PR_COLOR_RST}${PR_COLOR2}]─┐
└─[${PR_COLOR_RST}${PR_COLOR6}%?$(retcode)${PR_COLOR_RST}${PR_COLOR2}]${PR_COLOR_RST} ${PR_COLOR5}${PR_VCS_INFO}${PR_COLOR_RST}${PR_COLOR2}${PR_PROMT}${PR_COLOR_RST} "
  RPROMPT="${PR_COLOR2}[${PR_COLOR_RST}${PR_COLOR3}%l${PR_COLOR_RST}${PR_COLOR2}]─┘${PR_COLOR_RST}"

  PROMPT2="${PR_COLOR2}──>${PR_COLOR_RST} "
  RPROMPT2="${PR_COLOR2}<──${PR_COLOR_RST}"
}

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd
setprompt
