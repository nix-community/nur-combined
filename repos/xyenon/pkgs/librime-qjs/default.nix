{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  quickjs-ng,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "0-unstable-2025-03-14";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "9b541af24dc487faefc020c962e18fb250065b46";
    hash = "sha256-+ZVsmJBRhhxHMzDr3AvbXnvvR5HVvBMwOtvmXdSfja8=";
  };

  propagatedBuildInputs = [ quickjs-ng ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp --archive --verbose src/ tests/ $out
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
