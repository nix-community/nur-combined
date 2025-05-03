{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  rage,
  age' ? rage,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-rekey";
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
    age'
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-rekey $out/bin/pa-rekey
    wrapProgram $out/bin/pa-rekey \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "rekey support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-rekey";
    platforms = lib.platforms.linux;
  };
}
