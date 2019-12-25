curl -sLo ~/.background-image https://source.unsplash.com/random/1920x1080?architecture,night
~/.fehbg
CURRENT=$(cd $(dirname $0) && pwd)
albert &
glava -d &
$CURRENT/lemonbar.sh | lemonbar -b &
