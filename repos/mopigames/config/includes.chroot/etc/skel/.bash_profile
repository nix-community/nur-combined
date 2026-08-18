# Moonlight OS: the console login on tty1 *is* the appliance.
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec moonlight-session
fi
