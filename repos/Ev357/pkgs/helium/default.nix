{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "helium";
  version = "0.6.4.1";

  src = let
    platformMap = {
      "x86_64-linux" = "x86_64";
      "aarch64-linux" = "arm64";
    };

    platform = platformMap.${pkgs.system};

    hashes = {
      "x86_64-linux" = "sha256-DlEFuFwx2Qjr9eb6uiSYzM/F3r2hdtkMW5drJyJt/YE=";
      "aarch64-linux" = "sha256-B63tvOtSRlMRJozvzC7lqG2LM0ZgLIq2G/AHABl+Qqg=";
    };

    hash = hashes.${pkgs.system};
  in
    pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${platform}.AppImage";
      inherit hash;
    };

  extraInstallCommands = let
    contents = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/helium"
    cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
    cp -r ${contents}/usr/share/* "$out/share"
    cp "${contents}/${pname}.desktop" "$out/share/applications/"
    substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

  meta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
    platforms = ["x86_64-linux" "aarch64-linux"];
    license = lib.licenses.gpl3;
    mainProgram = "helium";
  };
}
