{ deepLinkIntoOwnPackage
, networkmanager
}:
(deepLinkIntoOwnPackage networkmanager).overrideAttrs (base: {
  outputs = [ "out" "daemon" "nmcli" ];
  postFixup = ''
    moveToOutput "" "$daemon"
    for f in bin/{nmcli,nmtui,nmtui-connect,nmtui-edit,nmtui-hostname} share/bash-completion/completions/nmcli; do
      moveToOutput "$f" "$nmcli"
    done
    # ensure non-empty default output so the build doesn't fail
    mkdir "$out"
  '';
  meta = base.meta // {
    outputsToInstall = [ ];
  };
  passthru = {
    inherit networkmanager;
  };
})
