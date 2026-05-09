{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "librime-qjs";
  version = "1.3.0-unstable-2026-03-27";
  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "fa3894b1f4b273a3e0d9cc4d9b862f647bb60812";
    fetchSubmodules = true;
    hash = "sha256-wn6faybQAGbRXioWSKw8I5j0QWjCnjnVUKc6wNB3Jnc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp --archive --verbose src/ tests/ thirdparty/ $out
    install --mode=644 --verbose --target-directory=$out CMakeLists.txt LICENSE readme.md

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
    tagFormat = "v*";
  };

  meta = {
    description = "Bring a fresh JavaScript plugin ecosystem to the Rime Input Method Engine";
    homepage = "https://github.com/HuangJian/librime-qjs";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
