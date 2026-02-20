{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "rockchip-udev-rules";
  version = "1.0";
  src = ./51-rockchip.rules;

  nativeBuildInputs = [
    pkgs.udevCheckHook
  ];

  doInstallCheck = true;
  
  dontUnpack = true;

  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/51-rockchip.rules
  '';

  meta = {
    license = pkgs.lib.licenses.mit;
    sourceProvenance = [ pkgs.lib.sourceTypes.fromSource ];
    maintainers = [ "dmfrpro" ];
    description = "Rockchip Udev Rules";
    platforms = pkgs.lib.platforms.linux;
  };
}
