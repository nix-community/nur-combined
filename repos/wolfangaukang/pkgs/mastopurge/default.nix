{ lib
, stdenv
, fetchFromGitHub
, substituteAll
, go
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mastopurge";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ThomasLeister";
    repo = "mastopurge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5sO+uzk5jDylNnanGG7EWSgv+w02bemVmhZapNiIQ7o=";
  };

  nativeBuildInputs = [
    go
  ];

  patches = [
    (substituteAll {
      src = ./0001-Using-nix-version.patch;
      version = finalAttrs.version;
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
    changelog = "https://github.com/ThomasLeister/mastopurge/releases/tag/${finalAttrs.src.rev}";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "mastopurge";
    maintainers = with maintainers; [ wolfangaukang ];
  };
})
