{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  wmenu,
  wtype,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-wmenu";
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
    wmenu
    wtype
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-wmenu $out/bin/pa-wmenu
    wrapProgram $out/bin/pa-wmenu \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "wmenu support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-wmenu";
    platforms = lib.platforms.linux;
  };
}
