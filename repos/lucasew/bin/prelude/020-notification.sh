function notification {
  notification_id="$RANDOM"
  echo $notification_id
  title="Notification"
  message="Notification message"

  while [ $# -gt 0 ]; do
    case "$1" in
      -t|--title)
        shift
        title="$1"
      ;;
      -m|--message)
        shift
        message="$1"
      ;;
      -i|--id)
        shift
        notification_id="$1"
      ;;
    esac
    shift
  done
  if has_binary termux-notification; then
    termux-notification -i "$notification_id" -t "$title" -c "$message"
  else
    notify-send -r "$notification_id" "$title" "$message"
  fi
}
