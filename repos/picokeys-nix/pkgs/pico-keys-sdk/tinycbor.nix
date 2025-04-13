{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "tinycbor";
  version = "unstable-2022-09-07";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "tinycbor";
    rev = "e27261ed5e2ed059d160f16ae776951a08a861fc";
    hash = "sha256-/5FcwsEhJfh6noV0HJAQVTHBGHDBc99KwOnPsaeUlLw=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/tinycbor
    cp -r . $out/share/tinycbor
    runHook postInstall
  '';

  meta = {
    description = "Concise Binary Object Representation (CBOR) Library";
    homepage = "https://github.com/intel/tinycbor/tree/e27261ed5e2ed059d160f16ae776951a08a861fc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
