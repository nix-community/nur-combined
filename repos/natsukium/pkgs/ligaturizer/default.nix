{
  lib,
  stdenv,
  fetchFromGitHub,
  fontforge,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "ligaturizer";
  version = "5";

  src = fetchFromGitHub {
    owner = "ToxicFrog";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-sFzoUvA4DB9CVonW/OZWWpwP0R4So6YlAQeqe7HLq50=";
  };

  postPatch = ''
    substituteInPlace ./ligaturize.py \
      --replace "fonts/fira/distr/otf" "$out/lib/fonts/fira/distr/otf"
  '';

  nativeBuildInputs = [makeWrapper];
  buildInputs = [fontforge];

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    install -Dm755 *.py -t $out/lib
    install -Dm644 fonts/fira/distr/otf/* -t $out/lib/fonts/fira/distr/otf
    makeWrapper ${fontforge}/bin/fontforge $out/bin/ligaturizer \
      --argv0 ligaturizer \
      --add-flags "-lang py" \
      --add-flags "-script $out/lib/ligaturize.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A tool for adding ligatures to any coding font";
    homepage = "https://github.com/ToxicFrog/Ligaturizer";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
