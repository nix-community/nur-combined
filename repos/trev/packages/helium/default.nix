{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:
let
  version = "0.10.7.1";
  pname = "helium";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-+vmxXcg8TkR/GAiHKnjq4b04bGtQzErfJkOb4P4nZUk=";
  };
in

appimageTools.wrapType2 {
  inherit pname version src;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      pname
    ];
  };

  meta = {
    mainProgram = "helium";
    description = "Helium Browser for Linux";
    homepage = "https://github.com/imputnet/helium-linux";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/V${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
