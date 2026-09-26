{
  stdenv,
  fetchFromGitHub,
  libgig,
}:
stdenv.mkDerivation {
  pname = "convert-gig-file";
  version = "0-unstable-2012-05-10";

  src = fetchFromGitHub {
    owner = "stevefolta";
    repo = "gig2sfz";
    rev = "9ba665cd7d8cb9f621f2663b48381fe5837a9b4b";
    hash = "sha256-L7a4OltB09tmUHgTuMh5+n8qDDWyt47uXvXHB9W/XEw=";
  };

  CFLAGS = "-I${libgig}/include/libgig -L${libgig}/lib/libgig -lgig";
  nativeBuildInputs = [ libgig ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    substituteInPlace convert-gig-file \
      --replace-fail "gig2sfz" "$out/bin/gig2sfz" \
      --replace-fail "gigextract" ${libgig}/bin/gigextract

    install convert-gig-file gig2sfz $out/bin

    runHook postInstall
  '';

  meta = {
    mainProgram = "convert-gig-file";
  };
}
