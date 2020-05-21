CURRENT=$(cd $(dirname $0) && pwd)
albert &
glava -d &
$CURRENT/lemonbar.sh | lemonbar -b &
