{ stdenv, lib
  , writeShellScriptBin
  , yubikey-manager
  , ripgrep
  , libsecret
  , keepassxc
  , symlinkJoin
}:

let 

  name = "yubikee-smartvpn";

  yubikee-smartvpn = writeShellScriptBin "${name}" ''
  VPN=$1
  echo "Stopping openvpn-$VPN service."
  sudo systemctl stop openvpn-$VPN
  if ! $(${libsecret}/bin/secret-tool lookup Title "$VPN-user" &> /dev/null)
  then
    echo "Waiting for keepassxc secret service integration..."
    ${keepassxc}/bin/keepassxc &
  fi
  while ! $(${libsecret}/bin/secret-tool lookup Title "$VPN-user" &> /dev/null); do
    sleep 1s
  done
  ${yubikey-manager}/bin/ykman info
  YUBIKEY_OUT=$( ${yubikey-manager}/bin/ykman oath accounts code smartvpn | tee /dev/tty | ${ripgrep}/bin/rg smartvpn | sed 's/^.* //') 
  if test -z "$YUBIKEY_OUT"
  then
    echo "smartvpn 2FA failed." > /dev/stderr
    exit -1
  fi
  USER=$(${libsecret}/bin/secret-tool lookup Title "$VPN-user")
  if test -z "$USER"
  then
    echo "$VPN-user not found in secrets." > /dev/stderr
    exit -1
  fi
  PASS=$(${libsecret}/bin/secret-tool lookup Title "$VPN-pass")
  if test -z "$PASS"
  then
    echo "$VPN-pass not found in secrets." > /dev/stderr
    exit -1
  fi
  echo "$USER" > /tmp/ovpn.txt
  echo "$PASS$YUBIKEY_OUT" >> /tmp/ovpn.txt
  echo "Starting openvpn-$VPN service."
  sudo systemctl start openvpn-$VPN
  rm /tmp/ovpn.txt
  '';

in symlinkJoin {
  name = "yubikee-smartvpn";
  paths = [ 
    yubikee-smartvpn
    libsecret 
    yubikey-manager 
    ripgrep
    keepassxc
  ];
}
