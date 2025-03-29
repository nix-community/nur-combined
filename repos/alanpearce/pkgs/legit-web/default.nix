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
    rev = "ba5bcefcd3249fbaf77a487a7480a395016e3318";
    hash = "sha256-x1/g/u0i9RCQjy8Iz0CG1oJTktOHhgg9jymPDQUVeIw=";
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
