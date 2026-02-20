{ pkgs, ... }:

let
  revision = "8e808208e4f030716d49261d5aa1ddddd639ab93";
  path = "rk-flash-tool/tools/Linux_Upgrade_Tool/upgrade_tool";
in
pkgs.stdenv.mkDerivation {
  pname = "upgrade_tool";
  version = "2.44";

  src = pkgs.fetchurl {
    url = "https://github.com/dmfrpro/flash-utils/raw/${revision}/${path}";
    sha256 = "sha256-ZXga/nx2M9jHIYfnjDGCLXn3IkqXm5IjaZcNy74GpDA=";
  };

  dontUnpack = true;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    pkg-config
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m0755 $src $out/bin/upgrade_tool

    runHook postInstall
  '';

  meta = {
    license = pkgs.lib.licenses.unfree;
    homepage = "https://docs.radxa.com/en/compute-module/cm3j/low-level-dev/upgrade-tool";
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    maintainers = [ "dmfrpro" ];
    description = "Rockchip Firmware Upgrade Utility";
    platforms = [ "x86_64-linux" ];
    mainProgram = "upgrade_tool";
  };
}
