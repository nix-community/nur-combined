function notification {
  notification_id="$RANDOM"
  # echo $notification_id
  title="Notification"
  message="Notification message"
  progress=""

  while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
        cat <<EOF
notification: cria notificação usando notify-send ou termux

  -t, --title: Título da notificação
  -m, --message: Mensagem da notificação
  -i, --id: ID para atualização de notificação, só reusar para substituir
  -p, --progress: Porcentagem de barra de progresso
EOF
      ;;
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
      -p|--progress)
        shift
        progress="$1"
    ;;
    esac
    shift
  done

  if has_binary termux-notification; then
    if [ ! -z $progress ]; then
      title="$title ($progress%)"
    fi
    termux-notification -i "$notification_id" -t "$title" -c "$message"
  else
    extra_args=()
    if [ ! -z $progress ]; then
      extra_args+=(-h int:value:$progress)
    fi
    notify-send -r "$notification_id" "$title" "$message" ${extra_args[@]}
  fi
}
