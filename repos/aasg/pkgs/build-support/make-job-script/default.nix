{ lib, writeTextFile, stdenv, runtimeShell }:
let
  inherit (lib) replaceChars;

  # Taken from <nixpkgs/nixos/modules/system/boot/systemd.nix>.
  makeJobScript = name: text:
    let
      scriptName = replaceChars [ "\\" "@" ] [ "-" "_" ] name;
      out = writeTextFile {
        name = "unit-script-${scriptName}";
        executable = true;
        destination = "/bin/${scriptName}";
        text = ''
          #!${runtimeShell} -e
          ${text}
        '';
        checkPhase = ''
          ${stdenv.shell} -n "$out/bin/${scriptName}"
        '';
      };
    in
    "${out}/bin/${scriptName}";
in
makeJobScript
