{ pname, version, rev, sha256, sources }:

{ stdenvNoCC, fetchFromGitHub, yq, lib }: with lib; stdenvNoCC.mkDerivation {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = pname;
    inherit rev sha256;
  };

  nativeBuildInputs = [ yq ];

  buildPhase = ''
    runHook preBuild
    yq -Mc . list.yaml > list.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d $out
    mv list.json $out/list.yaml
    runHook postInstall
  '';

  passthru = {
    sources = importJSON sources;
  };
}
