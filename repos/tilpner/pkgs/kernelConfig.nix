{ stdenv, lib, linux, linuxConfig, bison, flex }:

{ baseTarget ? "tinyconfig", config ? {} }:
let
  tiny = (linuxConfig {
    name = "kernel.config";
    inherit (linux) src;

    makeTarget = baseTarget;
  }).overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      bison flex
    ];
  });

  linuxSrc = stdenv.mkDerivation {
    name = "linuxSrc";
    src = linux.src;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      cp -r . $out
    '';
  };

  setSingle = opt: val: with lib;
    if val == true then "--enable ${opt}"
    else if val == false then "--disable ${opt}"
    else if isString val then "--set-str ${opt} ${escapeShellArg val}"
    else builtins.throw "invalid type";
    
  setConfig = config: with lib;
    "bash ${linuxSrc}/scripts/config ${concatStringsSep " " (mapAttrsToList setSingle config)}";
in stdenv.mkDerivation {
  name = "kernel.config";
  src = tiny;

  buildCommand = ''
    cp $src ./.config
    chmod u+w ./.config
    ${setConfig config}
    cp ./.config $out
  '';
}
