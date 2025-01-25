{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2025-01-23";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "feb58faaa427951c69ffbb652dcbcfd761b20ea3";
    hash = "sha256-wQz1HZbCbjYEOwjhZitCmmUx3bIqjfBcvh9ZUdXllUI=";
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
