{
  lib,
  bashNonInteractive,
  coreutils,
  fetchFromGitHub,
  gamescope,
  gawk,
  gnugrep,
  gnome-randr,
  gnused,
  jq,
  makeWrapper,
  nix-update-script,
  perl,
  procps,
  stdenvNoCC,
  wlr-randr,
  withGamescope ? true,
  withGnomeRandr ? true,
  withWlrRandr ? true,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "scopebuddy";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "OpenGamingCollective";
    repo = "ScopeBuddy";
    tag = finalAttrs.version;
    hash = "sha256-Z4KE6Qs5dcNdoEra1sx69I8EsxztAeVNGgO0ltYz7r0=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    bashNonInteractive
  ];

  dontConfigure = true;
  dontBuild = true;

  # The SCB_AUTO_* display detection uses kscreen-doctor, gdctl, gnome-randr or
  # wlr-randr. kscreen-doctor and gdctl come with KDE Plasma and GNOME and are
  # taken from PATH. gamescope, gnome-randr and wlr-randr are appended to PATH
  # as fallbacks, so copies already in PATH take precedence, e.g. the
  # capSysNice gamescope wrapper of the NixOS `programs.gamescope` module.
  installPhase = ''
    runHook preInstall

    install -Dm755 bin/scopebuddy $out/bin/scopebuddy
    wrapProgram $out/bin/scopebuddy \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          gnused
          jq
          perl
          procps
        ]
      } \
      --suffix PATH : ${
        lib.makeBinPath (
          lib.optional withGamescope gamescope
          ++ lib.optional withGnomeRandr gnome-randr
          ++ lib.optional withWlrRandr wlr-randr
        )
      }
    ln -s scopebuddy $out/bin/scb

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manager script to make gamescope easier to use on the desktop";
    homepage = "https://github.com/OpenGamingCollective/ScopeBuddy";
    changelog = "https://github.com/OpenGamingCollective/ScopeBuddy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    mainProgram = "scopebuddy";
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
  };
})
