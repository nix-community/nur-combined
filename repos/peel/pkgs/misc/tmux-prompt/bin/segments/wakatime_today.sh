# Today: 14 mins (Total)
#
#  JavaScript: 11 mins
#  Bash: 3 mins
#
#  LearningSpaces: 11 mins
#  tmux-powerline: 3 mins


run_segment() {
  read -r _ amount type _ <<< $(wakatime -t)
  echo "⏰ " ${amount:5:3}$type
}
