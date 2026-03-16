{
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenv,
  tcl-8_6,
  tclPackages,
  tk-8_6,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "imunes";
  version = "3.0.0b";

  src = fetchFromGitHub {
    owner = "imunes";
    repo = "imunes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I43wnE3IviVR5dBOaVyFyDhiWIocczOlmECy1Bq8j0I=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [ "PREFIX=$(out)" ];

  preFixup = ''
    for f in $(find $out/bin/ -type f -executable); do
      wrapProgram "$f" \
        --prefix PATH : ${lib.makeBinPath [ tcl-8_6 ]} \
        --prefix TCLLIBPATH ' ' ${tclPackages.tcllib}/lib/tcllib${lib.getVersion tclPackages.tcllib} \
        --prefix TCLLIBPATH ' ' ${tk-8_6}/lib/tk8.6
    done
  '';

  meta = {
    description = "Integrated Multiprotocol Network Emulator/Simulator";
    homepage = "https://imunes.net/";
    downloadPage = "https://github.com/imunes/imunes/tags";
    changelog = "https://github.com/imunes/imunes/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "imunes";
    platforms = with lib.platforms; freebsd ++ linux;
  };
})
