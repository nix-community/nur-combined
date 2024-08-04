{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2024-06-01";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "fg.yazi";
    rev = "f7d41ae71249515763d9ee04ddf4bdc3b0b42f55";
    hash = "sha256-6LpnyXB7mri6aVEfnv6aG2mWlzpvaD8SiMqwUS+jJr0=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Yazi plugin for rg search with fzf file preview";
    homepage = "https://github.com/DreamMaoMao/fg.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
