{ lib
, buildGoModule
, fetchgit
, nixosTests
,
}:

buildGoModule {
  pname = "legit";
  version = "unstable-2025-03-29";

  src = fetchgit {
    url = "https://git.alanpearce.eu/legit.git";
    rev = "823f7aea9ece5805367520be94f68b06e36e53d5";
    hash = "sha256-UnxD3nJUu89o3tr1kLPllPRTT3WV67SbtAqUkmRm7dE=";
  };

  vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";

  postInstall = ''
    mkdir -p $out/lib/legit/templates
    mkdir -p $out/lib/legit/static

    cp -r $src/templates/* $out/lib/legit/templates
    cp -r $src/static/* $out/lib/legit/static
  '';

  passthru.tests = { inherit (nixosTests) legit; };

  meta = {
    description = "Web frontend for git";
    homepage = "https://github.com/icyphox/legit";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alanpearce ];
    mainProgram = "legit";
  };
}
