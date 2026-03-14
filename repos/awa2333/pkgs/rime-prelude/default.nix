{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  name = "rime-prelude";
  version = "0.0.0.20251230";
  src = fetchFromGitHub {
    owner = "rime";
    repo = "${name}";
    rev = "db691d2420b8e656a79692a94f9db0fb3e7aa12b";
    hash = "sha256-sllcT3Kq572xJvlh+j4zN0AUblFzXlhZtL9RGT/GY7g=";
  };
  installPhase = ''
    runHook preInstall
    install -d $out/share/rime-data
    cp *.yaml $out/share/rime-data
    runHook postInstall
  '';
  meta = {
    description = "Essential files for building up your Rime configuration.";
    homepage = "https://github.com/rime/rime-prelude";
    platforms = lib.platforms.all;
    license = lib.licenses.lgpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
