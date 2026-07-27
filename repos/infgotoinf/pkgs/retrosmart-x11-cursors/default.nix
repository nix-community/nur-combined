{
  lib,
  stdenv,
  fetchurl,
  imagemagick,
  xcursorgen
}:

# Used this https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ap/apple-cursor/package.nix
# and this https://wiki.nixos.org/wiki/Nixpkgs/Create_and_debug_packages
# for reference
stdenv.mkDerivation rec {
  pname = "retrosmart-x11-cursors";
  version = "3.1a";

  src = fetchurl {
    url = "https://github.com/mdomlop/${pname}/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-7j5ViGi/WB/zKImQYKmfjGisLSEeRTnAJ47EPPVd21U=";
  };

  sourceRoot = "${pname}-${version}";

  nativeBuildInputs = [
    imagemagick
    xcursorgen
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -dm 0755 $out/share/icons
    cp -r retrosmart-xcursor-* $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "An old-fashioned look X11 cursor theme";
    homepage = "https://github.com/mdomlop/retrosmart-x11-cursors";
    downloadPage = "https://github.com/stgiga/UnifontEX/releases";
    license = with lib.licenses; [
      gpl3
    ];
    platforms = lib.platforms.all;
  };
}
