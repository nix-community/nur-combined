{ runCommand
, pastebinit
, cacert
, wget
}:
runCommand "pastebinit-test" { nativeBuildInputs = [ pastebinit cacert wget ]; } ''
  export USER="nixpkgs-pastebinit-test"
  teststring="test from pastebinit"
  for pastebin in $(pastebinit -l | sed 1d | cut -d' ' -f2); do
    echo "Trying $pastebin"
    URL=$(printf "$teststring\n$teststring\n$teststring" | pastebinit -b $pastebin)
    if [ "$pastebin" = "paste.ubuntu.com" ] ; then
      output=$(wget -O - -q "$URL" | grep "$USER")
    else
      output=$(wget -O - -q "$URL" | grep "$teststring")
    fi
    if [ -n "$output" ]; then
      echo "PASS: $pastebin ($URL)"
    else
      echo "FAIL: $pastebin ($URL)"
      exit 1
    fi
  done
  touch $out
''
