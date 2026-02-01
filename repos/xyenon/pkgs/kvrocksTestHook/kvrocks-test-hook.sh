# shellcheck shell=bash

preCheckHooks+=('kvrocksStart')
postCheckHooks+=('kvrocksStop')

kvrocksStart() {
	if [[ ${kvrocksTestPort:-} == "" ]]; then
		kvrocksTestPort=6666
	fi

	mkdir -p "$NIX_BUILD_TOP/run/kvrocks"

	KVROCKS_CONF="$NIX_BUILD_TOP/run/kvrocks.conf"
	export KVROCKS_CONF

	cat <<EOF >"$KVROCKS_CONF"
bind 127.0.0.1
port ${kvrocksTestPort}
dir $NIX_BUILD_TOP/run/kvrocks
daemonize no
EOF

	echo 'starting kvrocks'

	@server@ -c "$KVROCKS_CONF" >/dev/null 2>&1 &
	KVROCKS_PID=$!

	echo 'waiting for kvrocks to be ready'
	while ! @cli@ -h 127.0.0.1 -p "$kvrocksTestPort" PING | grep -q PONG; do
		sleep 1
	done
}

kvrocksStop() {
	echo 'stopping kvrocks'
	kill "$KVROCKS_PID"
}
