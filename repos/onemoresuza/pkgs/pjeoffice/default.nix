{
  stdenvNoCC,
  lib,
  buildFHSEnv,
  fetchzip,
  makeWrapper,
  jdk11,
  openssl, # some tokens may only work with openssl_1_1
  pcsc-safenet,
  tokenLibs ? [pcsc-safenet],
  libGL,
}: let
  pjeOffice = let
    mainProgram = "pjeoffice";
  in
    stdenvNoCC.mkDerivation {
      pname = "pjeoffice";
      version = "1.0.28";
      src = fetchzip {
        url = "https://cnj-pje-programs.s3-sa-east-1.amazonaws.com/pje-office/pje-office_unix_no_embedded.tar.gz";
        hash = "sha256-oHMChXpCfC18C/WB7MtJVW1/6F5nP2XNad4oPEjIzcE=";
      };

      nativeBuildInputs = [makeWrapper];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        install -Dt $out/share/pjeoffice ./pjeOffice.jar
        mkdir $out/bin
        makeWrapper ${lib.getExe jdk11} $out/bin/${mainProgram} \
          --add-flags "-jar $out/share/pjeoffice/pjeOffice.jar"

        runHook postInstall
      '';

      meta = {
        description = "CNJ software for digital signatures for the PJe system";
        homepage = "https://www.pje.jus.br/wiki/index.php/PJeOffice";
        license = lib.licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [binaryBytecode];
        inherit mainProgram;
      };
    };
in
  buildFHSEnv {
    name = "pjeoffice";
    targetPkgs = pkgs:
      [
        pjeOffice
        openssl
      ]
      ++ tokenLibs;
    multiPkgs = pkgs: [
      libGL
    ];
    runScript = pjeOffice.meta.mainProgram;
    inherit (pjeOffice) meta;
  }
