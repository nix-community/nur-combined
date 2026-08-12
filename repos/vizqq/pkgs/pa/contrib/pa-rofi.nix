{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  rofi,
  xdotool,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-rofi";
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
    rofi
    xdotool
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-rofi $out/bin/pa-rofi
    wrapProgram $out/bin/pa-rofi \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "rofi support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-rofi";
    platforms = lib.platforms.linux;
  };
}
