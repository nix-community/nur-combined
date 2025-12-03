{
  deepLinkIntoOwnPackage,
  modemmanager,
}:
(deepLinkIntoOwnPackage modemmanager {}).overrideAttrs (base: {
  outputs = [ "out" "daemon" "mmcli" ];
  postFixup = ''
    moveToOutput "" "$daemon"
    for f in bin/mmcli man/man1/mmcli.1.gz share/bash-completion/completions/mmcli; do
      moveToOutput "$f" "$mmcli"
    done
    # ensure non-empty default output so the build doesn't fail
    mkdir "$out"
  '';
  meta = base.meta // {
    outputsToInstall = [ ];
  };
})
