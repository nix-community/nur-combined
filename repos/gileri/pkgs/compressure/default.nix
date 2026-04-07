{
  stdenv,
  autoreconfHook,
  copyDesktopItems,
  fetchFromGitHub,
  lib,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  pkg-config,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_net,
  SDL2_ttf,
  libxcb,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "compressure";
  version = "0-unstable-2024-05-02";

  src = fetchFromGitHub {
    owner = "brejc8";
    repo = "ComPressure";
    rev = "d8bfda6c1227397708074a919cda80a32ea8c530";
    hash = "sha256-6ldZqtxXBQKjtjWyXrclLjmHelRtR5WIrlGG1MYtvVE=";
    fetchSubmodules = true;
  };

  patches = [
    ./makefile.patch
  ];

  configureFlags = [
    "--disable-steam"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "ComPressure";
      comment = meta.description;
      exec = "ComPressure";
      icon = "compressure";
      categories = [ "Game" ];
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    copyDesktopItems
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libxcb
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_net
    SDL2_ttf
    zlib
    zstd
  ];

  postInstall = ''
    install -m644 -D -t $out/share/compressure/ *.json *.png *.ttf *.ogg
    mkdir -p $out/share/icons/hicolor/256x256/apps
    ln -s $out/share/compressure/icon.png $out/share/icons/hicolor/256x256/apps/compressure.png
    wrapProgram $out/bin/ComPressure --chdir $out/share/compressure
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Game about designing increasingly complex computation units powered by high pressure steam";
    longDescription = ''
      For too long have we relied on cogs and gears to control our lives. Welcome to a new age, the age of steam!
      The simple valve, which controls the flow of steam based on the pressure on it's control ports,
      is the only component that is needed to revolutionise our control over machines.
      From simple switches, to adders, tabulators, and eventually entire computers.
      Your companions will guide you through the discovery of steam based computation.

      A word of warning though. This game is hard. One can not discover an entire new field of science alone.
      Which is why an Academy of steam engineers (Discord) is available to you.
      A friendly community who are happy to assist you and share their latest steam innovations.

      Each solved challenge yields another useful element that can be used in future designs.
      Poor solutions in previous stages make poor components to use further on,
      so you will be coming back to old designs, tuning and optimising them with things you have learned.
    '';
    homepage = "https://discord.com/invite/7ZVZgA7gkS";
    changelog = "https://github.com/brejc8/ComPressure/commits/${src.rev}/";
    license = lib.licenses.cc-by-40;
    maintainers = with lib.maintainers; [ gileri ];
    mainProgram = "ComPressure";
    platforms = [ "x86_64-linux" ];
  };
}
