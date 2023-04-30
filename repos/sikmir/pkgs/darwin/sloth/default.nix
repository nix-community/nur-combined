{ lib, stdenvNoCC, fetchfromgh, unzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sloth-bin";
  version = "3.2";

  src = fetchfromgh {
    owner = "sveinbjornt";
    repo = "Sloth";
    name = "sloth-${finalAttrs.version}.zip";
    hash = "sha256-8/x8I769V8kGxstDuXXUaMtGvg03n2vhrKvmaltSISo=";
    inherit (finalAttrs) version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "Nice GUI for lsof";
    homepage = "https://sveinbjorn.org/sloth";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
