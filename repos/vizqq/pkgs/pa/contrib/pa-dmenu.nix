{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  dmenu,
  xdotool,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-dmenu";
  version = "unstable-${source.date}";

  sourceRoot = "${src.name}/contrib";

  buildInputs = [
    bash
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  wrapperPath = lib.makeBinPath [
    pa
    dmenu
    xdotool
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-dmenu $out/bin/pa-dmenu
    wrapProgram $out/bin/pa-dmenu \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "dmenu support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-dmenu";
    platforms = lib.platforms.linux;
  };
}
