{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeBinaryWrapper,
  nix-update-script,
  bashNonInteractive,
  jaq,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jqjq";
  version = "0-unstable-2026-03-30";

  src = fetchFromGitHub {
    owner = "wader";
    repo = "jqjq";
    rev = "adfc53104329c4a4ec81ac30552ccddb3a9fc5eb";
    hash = "sha256-PPYJ8VFhvVUj7WdMdj5HzU23o/oPekfzgNgAdSD9o24=";
  };

  # This is wrong, but there's something wrong with
  # patchShebangs
  postPatch = ''
    patchShebangs --build jqjq.jq
  '';

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = [
    bashNonInteractive
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share"
    cp jqjq.jq "$out/share/jqjq.jq"

    makeWrapper "$out/share/jqjq.jq" "$out/bin/jqjq" \
      --set JQ ${lib.getExe jaq}

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/jqjq" --run-tests < jqjq.test

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "jq implementation in jq";
    homepage = "https://github.com/wader/jqjq";
    maintainers = with lib.maintainers; [ RossSmyth ];
    mainProgram = "jqjq";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
