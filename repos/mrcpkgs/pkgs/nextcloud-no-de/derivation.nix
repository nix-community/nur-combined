{ stdenv, lib
  , writeShellScriptBin
  , nextcloud-client
  , libsecret
  , keepassxc
}:

let 

  name = "nectcloud";

in writeShellScriptBin "${name}" ''
  if ! $(${libsecret}/bin/secret-tool lookup Title "Nextcloud" &> /dev/null)
  then
    echo "Waiting for keepassxc secret service integration..."
    ${keepassxc}/bin/keepassxc &
  fi
  while ! $(${libsecret}/bin/secret-tool lookup Title "Nextcloud" &> /dev/null); do
    sleep 1s
  done
  ${nextcloud-client}/bin/nextcloud "$@" &
  ''
