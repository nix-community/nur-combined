{
  lib,
  fetchurl,
  runCommand,
}:

let
  commit = "07df397d119f3e0bbf395eae5546d1a6076539d2";
  vendor = "amlogic";
  name = "meson-sm1-x96-max-plus";
  fileName = "${name}.dtb";
  file = fetchurl {
    name = fileName;
    url = "https://raw.githubusercontent.com/ophub/amlogic-s9xxx-armbian/${commit}/build-armbian/armbian-files/platform-files/${vendor}/bootfs/dtb/${vendor}/${fileName}";
    hash = "sha256-G0JY60/cPGzoQBC69erplNfxAb8OhRLeZGI53ELdOwI=";
  };
in
runCommand "${name}"
  {
    meta = {
      description = "Prebuilt device tree blob for X96 Max+ (Amlogic S905X3)";
      homepage = "https://github.com/ophub/amlogic-s9xxx-armbian";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [ knightfemale ];
      platforms = [ "aarch64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  }
  ''
    install -Dm444 ${file} $out/dtbs/${vendor}/${fileName}
  ''
