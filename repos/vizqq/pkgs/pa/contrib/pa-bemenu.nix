{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  bemenu,
  wtype,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-bemenu";
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
    bemenu
    wtype
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-bemenu $out/bin/pa-bemenu
    wrapProgram $out/bin/pa-bemenu \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "bemenu support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-bemenu";
    platforms = lib.platforms.linux;
  };
}
