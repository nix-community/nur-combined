{
  stdenvNoCC,
  fetchurl,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  pname = "hyprcursor-bibata";
  version = "1.0";

  src = [
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Modern-Amber.tar.gz";
      hash = "sha256-BVbAb58KvOKhOmBXZfgef24ayovSDCQ21dtNtNM2pX0=";
    })
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Modern-Classic.tar.gz";
      hash = "sha256-+ZXnbI3bBLcb0nv2YW3eM/tK4dsraNM4UAO9BpSqfXk=";
    })
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Modern-Ice.tar.gz";
      hash = "sha256-3ttG6Hnr9TPtvIiIbQrsSodu5iZV4Y62xaKvQmkdLPg=";
    })
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Original-Amber.tar.gz";
      hash = "sha256-WTXiuRje6VJlVDayvI9GzvKYNjdgXYqKRi8t2QRanDk=";
    })
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Original-Classic.tar.gz";
      hash = "sha256-y4yRJYTI9uf/sbIJxwi0bZxgsiAXykn253qgDkHZa7g=";
    })
    (fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/${version}/hypr_Bibata-Original-Ice.tar.gz";
      hash = "sha256-J24W7tr4hilpV6DWl1xKafFrCHjhrcwubN06xcRs4ts=";
    })
  ];

  unpackPhase = ''
    runHook preUnpack

    for archive in $srcs; do
      name=$(basename "$archive" .tar.gz)
      name=''${name#hypr_}
      mkdir -p "$name"
      tar -xzf "$archive" -C "$name"
    done

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    for dir in *; do
      if [ -d "$dir" ]; then
        cp -r "$dir" $out/share/icons/
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Material Based Cursor Theme for Hyprland";
    homepage = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = ["Prinky"];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
}
