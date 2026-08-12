{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  git ? null,
  pa ? null,
  rage,
  age' ? rage,
  gnupg,

  gitSupport ? false,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-pass";
  version = "unstable-${source.date}";

  sourceRoot = "${src.name}/contrib";

  buildInputs = [
    bash
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  wrapperPath = lib.makeBinPath (
    [
      pa
      age'
      gnupg
    ]
    ++ lib.optional gitSupport git
  );

  installPhase = ''
    mkdir -p $out/bin
    cp pa-pass $out/bin/pa-pass
    wrapProgram $out/bin/pa-pass \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "migrate passwords from pass to pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-pass";
    platforms = lib.platforms.linux;
  };
}
