{
  lib,
  stdenv,
  source,
  bash,
  makeWrapper,

  pa ? null,
  fuzzel,
  wtype,
}:
stdenv.mkDerivation rec {
  inherit (source) src;

  pname = "${source.pname}-fuzzel";
  version = "unstable-${source.date}";

  sourceRoot = "${src.name}/contrib";

  postPatch = ''
    substituteInPlace pa-fuzzel \
      --replace-fail '-dmenu' '--dmenu'
  '';

  buildInputs = [
    bash
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  wrapperPath = lib.makeBinPath [
    pa
    fuzzel
    wtype
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pa-fuzzel $out/bin/pa-fuzzel
    wrapProgram $out/bin/pa-fuzzel \
      --prefix PATH : ${wrapperPath}
  '';

  meta = {
    description = "fuzzel support for pa";
    homepage = "https://github.com/biox/pa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "pa-fuzzel";
    platforms = lib.platforms.linux;
  };
}
