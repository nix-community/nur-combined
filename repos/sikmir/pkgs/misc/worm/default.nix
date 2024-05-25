{
  lib,
  stdenv,
  nimPackages,
  fetchFromGitHub,
  pkg-config,
  xorg,
}:

nimPackages.buildNimPackage rec {
  pname = "worm";
  version = "0.3.2";
  nimBinOnly = true;

  src = fetchFromGitHub {
    owner = "codic12";
    repo = "worm";
    rev = "v${version}";
    hash = "sha256-fm969whcYILMphR8Vr8oarx2iEJiIhzifU2wNYaU/Kg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    with nimPackages;
    [
      pixie
      regex
      unicodedb
      x11
    ]
    ++ (with xorg; [
      libX11
      libXft
      libXinerama
    ]);

  postInstall = ''
    install -Dm644 assets/worm.desktop -t $out/share/applications
  '';

  meta = {
    description = "A dynamic, tag-based window manager written in Nim";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
