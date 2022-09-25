{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  freetype,
  libxkbcommon,
  wayland,
}: let
  rpathLibs = [
    fontconfig
    freetype
    libxkbcommon
    wayland
  ];
in
  rustPlatform.buildRustPackage rec {
    pname = "kickoff";
    version = "main";

    src = fetchFromGitHub {
      owner = "j0ru";
      repo = pname;
      rev = "41fac1e663facd6dc3a041cd2192e017b7f57f32";
      sha256 = "sha256-2xsOCGHsQmyy8CVmfVfbRxB89EDbj29fr/c7NYuUjHo=";
    };

    cargoHash = "sha256-NsMDGGA4LA9ofPVBCHVKS/MGthThcTZ1QywHENSXgfQ=";

    nativeBuildInputs = [pkg-config];

    buildInputs = [
      fontconfig
    ];

    postInstall = ''
      # Strip executable and set RPATH
      # Stolen from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/terminal-emulators/alacritty>
      strip -s $out/bin/kickoff
      patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/kickoff
    '';

    dontPatchELF = true;

    meta = with lib; {
      description = "Minimalistic program launcher heavily inspired by rofi.";
      homepage = "https://github.com/j0ru/kickoff";
      license = licenses.gpl3Plus;
      maintainers = [maintainers.polykernel];
      platforms = platforms.linux;
    };
  }
