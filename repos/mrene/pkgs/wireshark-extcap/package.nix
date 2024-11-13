{ lib
, stdenv
, wireshark
, symlinkJoin
, makeWrapper
, onlyBin
, extCapPackages ? []

# Whether to include the extcap binaries provided by this repository
, includeExtCaps ? true
, ieee-802-15-4-sniffer ? null
, ice9-bluetooth-sniffer ? null
, pyspinel ? null
 }:

let
  extCapDir = onlyBin (symlinkJoin {
    name = "wireshark-extcap-dir";
    paths = lib.optionals includeExtCaps [ ieee-802-15-4-sniffer ice9-bluetooth-sniffer pyspinel ] ++ extCapPackages;
    postBuild = ''
      # Link the builtin extcap programs because wireshark doesn't look in its own lib directory 
      # if the env var is set
      cp -vs ${wireshark}/lib/wireshark/extcap/* $out/bin

      # Some programs might've been wrapped and have a hidden `.orig.wrapped` file that we don't want
      # wireshark calling into
      rm -f $out/bin/.[!.]*
    '';
  });
in

symlinkJoin {
  name = "wireshark-wrapped";
  paths = [ wireshark ];
  nativeBuildInputs = [ makeWrapper ];
  passthru = {
    inherit extCapDir;
  };
  postBuild = ''
  for file in $out/bin/*; do
    wrapProgram $file --prefix WIRESHARK_EXTCAP_DIR : ${extCapDir}/bin
  done
  '' + lib.optionalString stdenv.isDarwin ''
  for file in $out/Applications/Wireshark.app/Contents/MacOS/*; do
    if [[ -f $file ]]; then
      wrapProgram $file --prefix WIRESHARK_EXTCAP_DIR : ${extCapDir}/bin
    fi
  done
  '';
  meta = wireshark.meta // {
    mainProgram = if stdenv.isDarwin then 
      # Ugly hack but it makes `nix run` work on macOS
      "../Applications/Wireshark.app/Contents/MacOS/Wireshark" 
    else
      wireshark.meta.mainProgram;
  };
}