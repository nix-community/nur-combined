{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
}:

buildGoModule (finalAttrs: {
  pname = "comitium";
  version = "1.8.2";

  src = fetchFromSourcehut {
    owner = "~nytpu";
    repo = "comitium";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kydT2hLPb2Oj1/o+1N9Cvrdi4+DKi2tHX35oY6yGUU8=";
  };

  vendorHash = "sha256-wzT5A55ZFCa34fDUWPuG11XWBpCk4QLZamYwMGKLprM=";

  nativeBuildInputs = [ scdoc ];

  buildPhase = ''
    runHook preBuild
    make COMMIT=tarball
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = {
    description = "A feed aggregator for gemini supporting many formats and protocols";
    homepage = "https://git.sr.ht/~nytpu/comitium";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "comitium";
  };
})
