{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neotrain";
  version = "0-unstable-2025-02-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neotrain";
    rev = "ae45331d583f2bb68317c835386ce7c8412b99b0";
    hash = "sha256-TH2uoKG4WTcLARlEVo7vYfZyHgZdHalr6VysAX0jOas=";
  };

  installPhase = ''
    runHook preInstall

    cp -r high-res/png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Source files for the neotrain emoji";
    homepage = "https://codeberg.org/fotoente/neotrain";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
