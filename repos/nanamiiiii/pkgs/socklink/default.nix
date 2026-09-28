{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nix-update-script,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  procps,
  which,
}:
let
  runtimePath = lib.makeBinPath (
    [
      gawk
      gnugrep
      gnused
    ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      coreutils
      procps
      which
    ]
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "socklink";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/mshroyer/socklink/releases/download/v${finalAttrs.version}/socklink.sh";
    hash = "sha256-8M4TK7X7IcSmtDLtXpctAmfBDYQe2G6KSwx4iryHb/0=";
  };

  dontUnpack = true;
  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/socklink.sh"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/socklink.sh" \
      --prefix PATH : "${runtimePath}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform SSH_AUTH_SOCK manager for tmux";
    homepage = "https://github.com/mshroyer/socklink";
    license = lib.licenses.mit;
    mainProgram = "socklink.sh";
    platforms = lib.platforms.unix;
  };
})
