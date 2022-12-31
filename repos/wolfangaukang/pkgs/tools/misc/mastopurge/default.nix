{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, substituteAll
, go
, git }:

stdenv.mkDerivation rec {
  pname = "mastopurge";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ThomasLeister";
    repo = "mastopurge";
    rev = "v${version}";
    sha256 = "sha256-5sO+uzk5jDylNnanGG7EWSgv+w02bemVmhZapNiIQ7o=";
  };

  nativeBuildInputs = [
    makeWrapper
    go
    git
  ];

  patches = [
    (substituteAll {
      src = ./0001-Using-nix-version.patch;
      version = version;
    })
  ];

  postPatch = ''
    patchShebangs build.sh
  '';

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  buildPhase = ''
    runHook preBuild

    ./build.sh

    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv mastopurge $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Purges Mastodon accounts. Removes posts. Makes things clean again.";
    homepage = "https://github.com/ThomasLeister/mastopurge";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
