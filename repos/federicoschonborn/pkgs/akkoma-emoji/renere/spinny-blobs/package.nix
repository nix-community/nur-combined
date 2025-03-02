{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "renere-spinny-blobs";
  version = "0-unstable-2025-02-26";

  outputs = [
    "out"
    "blobcatsOnly"
    "blobfoxesOnly"
  ];

  src = fetchFromGitLab {
    owner = "renere";
    repo = "spinny_blobs";
    rev = "3a985a67650137193c20702aae65b487e194db5c";
    hash = "sha256-DPMAJBsiwZyD9ooGieX/JhyuLDb3g3QSKOFaR2wPBKc=";
  };

  installPhase = ''
    runHook preInstall

    cp -r render/cat/trimmed/. $out
    cp -r render/fox/trimmed/. $out
    cp -r render/cat/trimmed $blobcatsOnly
    cp -r render/fox/trimmed $blobfoxesOnly

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "these are the spinny (pride) blobs of life";
    homepage = "https://gitlab.com/renere/spinny_blobs";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
