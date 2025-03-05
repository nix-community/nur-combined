{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation {
  name = "operator-mono-lig";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "willfore";
    repo = "vscode_operator_mono_lig";
    rev = "7fddbc3fe39810563634c7b2700cef943a44d68c";
    hash = "sha256-wTzsbSo7U73OJ7U+W2o7dGLWNmiCJsvqkHZrgGlmKxM";
  };

  installPhase = ''
    runHook preInstall
    find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/willfore/vscode_operator_mono_lig";
    description = "Operator Mono with ligatures";
    # license = licenses.unfree;
    platforms = platforms.all;
  };
}
