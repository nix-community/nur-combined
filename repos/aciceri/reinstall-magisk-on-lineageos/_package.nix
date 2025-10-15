{
  writeShellScriptBin,
  android-tools,
  jq,
  stdenv,
  fetchFromGitHub,
  lib,
}:
let
  rev = "1ca911ed555d4badd705c6c71750b78be8962b0b";
  src = fetchFromGitHub {
    owner = "NicolasWebDev";
    repo = "reinstall-magisk-on-lineageos";
    hash = "sha256-95LzcWL4efR77i8UlzIT+7wQXp+91K2sUwcjmHvTf+Q=";
    inherit rev;
  };
  patchedSrc = stdenv.mkDerivation {
    name = "patched-reinstall-magisk-on-lineageos-source";
    version = lib.sources.shortRev rev;
    inherit src;
    installPhase = ''
      mkdir -p $out/bin
      cp reinstall-magisk-on-lineageos $out/bin/reinstall-magisk-on-lineageos
    '';
    patchPhase = ''
      substituteInPlace reinstall-magisk-on-lineageos \
        --replace-fail "paste_yours_here" "\"\$1\""
    '';
  };
  path = lib.makeBinPath [
    android-tools
    jq
  ];
  reinstall-magisk-on-lineageos = writeShellScriptBin "reinstall-magisk-on-lineageos" ''
    export PATH=$PATH:${path}
    exec ${patchedSrc}/bin/reinstall-magisk-on-lineageos $1
  '';
in
reinstall-magisk-on-lineageos.overrideAttrs {
  version = patchedSrc.version;
  meta = {
    description = "Small bash script to reinstall magisk after each LineageOS update";
    repository = "https://github.com/NicolasWebDev/reinstall-magisk-on-lineageos";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.aciceri ];
  };
}
