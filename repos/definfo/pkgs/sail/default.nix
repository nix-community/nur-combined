{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  buildDunePackage,
  base64,
  omd,
  menhir,
  menhirLib,
  ott,
  linenoise,
  dune-site,
  pprint,
  makeWrapper,
  lem,
  linksem,
  yojson,
}:

buildDunePackage {
  pname = "sail";
  version = "0.19.1-unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "rems-project";
    repo = "sail";
    rev = "8a1836c24a3113d207bab8dea8df8670b7828d9d";
    hash = "sha256-eJRcXREdJkZKrM8o79SIIrLZIg+9u6bCt0ExPRJRTkQ=";
  };

  minimalOCamlVersion = "4.08";

  nativeBuildInputs = [
    makeWrapper
    ott
    menhir
    lem
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.sigtool
  ];

  propagatedBuildInputs = [
    base64
    omd
    dune-site
    linenoise
    menhirLib
    pprint
    linksem
    yojson
  ];

  preBuild = ''
    rm -r aarch*  # Remove code derived from non-bsd2 arm spec
    rm -r snapshots  # Some of this might be derived from stuff in the aarch dir, it builds fine without it
  '';

  # `buildDunePackage` only builds the [pname] package
  # This doesnt work in this case, as sail includes multiple packages in the same source tree
  buildPhase = ''
    runHook preBuild

    dune build --release ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}

    runHook postBuild
  '';
  checkPhase = ''
    runHook preCheck

    dune runtest ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}

    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall

    dune install --prefix $out --libdir $OCAMLFIND_DESTDIR
    wrapProgram $out/bin/sail --set SAIL_DIR $out/share/sail

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/rems-project/sail";
    description = "Language for describing the instruction-set architecture (ISA) semantics of processors";
    maintainers = with maintainers; [ genericnerdyusername ];
    license = licenses.bsd2;
  };
}
