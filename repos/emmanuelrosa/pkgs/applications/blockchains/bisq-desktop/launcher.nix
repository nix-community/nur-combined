{ writeScript, coreutils, bash, tor, psmisc }:

writeScript "bisq-launcher" ''
  #! ${bash}/bin/bash

  # Setup a temporary Tor instance
  TMPDIR=$(${coreutils}/bin/mktemp -d)
  CONTROLPORT=$(${coreutils}/bin/shuf -i 9100-9499 -n 1)
  SOCKSPORT=$(${coreutils}/bin/shuf -i 9500-9999 -n 1)
  ${coreutils}/bin/head -c 1024 < /dev/urandom > $TMPDIR/cookie

  ${tor}/bin/tor --SocksPort $SOCKSPORT --ControlPort $CONTROLPORT --ControlPortWriteToFile $TMPDIR/port --CookieAuthFile $TMPDIR/cookie --CookieAuthentication 1 >$TMPDIR/tor.log --RunAsDaemon 1
  
  torpid=$(${psmisc}/bin/fuser $CONTROLPORT/tcp)

  echo Temp directory: $TMPDIR
  echo Tor PID: $torpid
  echo Tor control port: $CONTROLPORT
  echo Tor log: $TMPDIR/tor.log
  echo Bisq log file: $TMPDIR/bisq.log
  
  bisq-desktop-wrapped --torControlCookieFile=$TMPDIR/cookie --torControlUseSafeCookieAuth --torControlPort $CONTROLPORT "$@" > $TMPDIR/bisq.log 

  echo Bisq exited. Killing Tor...
  kill $torpid
''
