{ lib, stdenvNoCC, fetchfromgh, unzip, makeWrapper }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sloth";
  version = "3.2";

  src = fetchfromgh {
    owner = "sveinbjornt";
    repo = "Sloth";
    name = "sloth-${finalAttrs.version}.zip";
    hash = "sha256-8/x8I769V8kGxstDuXXUaMtGvg03n2vhrKvmaltSISo=";
    inherit (finalAttrs) version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Sloth.app/Contents/MacOS/Sloth,bin/sloth}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Nice GUI for lsof";
    homepage = "https://sveinbjorn.org/sloth";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    mainProgram = "sloth";
    skip.ci = true;
  };
})
