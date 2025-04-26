{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "latest-unstable-2025-04-24";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "ddd0e4a8fa50af293e4f4ad4f5dea68b728e0e3c";
    fetchSubmodules = true;
    hash = "sha256-IHyADqc99GN5pTXk1Nv+UOm0OmlJeGhZMyEd0FKL03U=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp --archive --verbose src/ tests/ thirdparty/ $out
    install --mode=644 --verbose --target-directory=$out CMakeLists.txt LICENSE readme.md

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Bring a fresh JavaScript plugin ecosystem to the Rime Input Method Engine";
    homepage = "https://github.com/HuangJian/librime-qjs";
    license = licenses.bsd3;
    maintainers = with maintainers; [ xyenon ];
  };
}
