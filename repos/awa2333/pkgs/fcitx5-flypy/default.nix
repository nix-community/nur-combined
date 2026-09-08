{
  pkgs,
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  name = "fcitx5-flypy";
  version = "20251211";
  src = fetchFromGitHub {
    owner = "cubercsl";
    repo = "rime-flypy";
    tag = "v${version}";
    hash = "sha256-Lw54pNXUzsVv9OFp7c5Bf+pCCA0DWTslSTrN/raX9CM=";
  };
  makeFlags = [
    "PREFIX=$(out)"
  ];
  nativeBuildInputs = with pkgs; [
    python3
    libime
  ];
  preBuild = ''
    patchShebangs scripts/fcitx5-flypy-dict
    cd fcitx5
  '';
  meta = {
    description = "flypy schema for fcitx5(小鹤音形fcitx5码表)";
    homepage = "https://flypy.cc";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
