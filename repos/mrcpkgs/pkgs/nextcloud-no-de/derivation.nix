{ stdenv, lib
  , writeShellScriptBin
  , nextcloud-client
  , libsecret
  , keepassxc
  , symlinkJoin
}:

let 

  name = "nextcloud-nd";

  nextcloud-wrapper = writeShellScriptBin "nextcloud-wrapper" ''
  if ! $(${libsecret}/bin/secret-tool lookup Title "Nextcloud" &> /dev/null)
  then
    echo "Waiting for keepassxc secret service integration..."
    ${keepassxc}/bin/keepassxc &
  fi
  while ! $(${libsecret}/bin/secret-tool lookup Title "Nextcloud" &> /dev/null); do
    sleep 1s
  done
  ${nextcloud-client}/bin/nextcloud "$@" &
  '';

in symlinkJoin {
  inherit name;
  paths = [ nextcloud-client nextcloud-wrapper ];
}
