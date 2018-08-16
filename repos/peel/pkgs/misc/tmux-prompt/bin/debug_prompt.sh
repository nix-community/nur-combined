# The segments shown here are for debug purposes
# Enable DEBUG_MODE and DEBUG_VCS accordingly to test the looks and
# functionality

# $(tmux display-message ${TMUX_PANE_WIDTH}) # show the pane_width
double_segment "♫" brightgreen blue "debug/song" blue brightgreen 10
double_segment "js" brightgreen yellow "debug/version" yellow brightgreen 113
double_segment "rb" brightgreen red "debug/version" red brightgreen 113
if [[ $DEBUG_VCS -eq 1 ]]; then
  double_segment "" brightgreen brightred "debug/branch" brightred brightgreen
  segment "debug/compare" black black
  double_segment "⊕" brightgreen green "debug/int" green brightgreen
  double_segment "+" brightgreen yellow "debug/int" yellow brightgreen
  double_segment "○" brightgreen white "debug/int" white brightgreen
fi
