{
  lib,
  stdenv,
  fetchFromSourcehut,
  hareHook,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "powerctl";
  # Tag 1.1 (2022) predates several Hare stdlib compatibility fixes and no longer
  # compiles; track master instead.
  version = "1.1-unstable-2026-07-14";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "powerctl";
    rev = "ab2e71c7c693da0e09226d8a43fd5693c370adad";
    hash = "sha256-sZ7gMbwE6ImuuHyOrXZghxmtdyR1ktzPgMCc5xyhz3M=";
  };

  nativeBuildInputs = [
    hareHook
    scdoc
  ];

  # Upstream's install target makes the binary setuid root. Nix strips setuid bits
  # from store paths, so drop it; on NixOS use security.wrappers instead.
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "chmod u+s \$(DESTDIR)/\$(BINDIR)/powerctl" "true"
  '';

  dontConfigure = true;

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "CLI tool for power management on Linux";
    longDescription = ''
      powerctl suspends or hibernates the system and inspects or configures the
      kernel's supported sleep states. Changing a state requires root; since Nix
      cannot ship setuid binaries, on NixOS wrap it with security.wrappers
      (setuid root, group "power") if non-root users should be able to use it.
      The `powerctl -q` query mode needs no privileges.
    '';
    homepage = "https://git.sr.ht/~sircmpwn/powerctl";
    license = lib.licenses.gpl3Only;
    mainProgram = "powerctl";
    # powerctl drives /sys/power, so it is Linux-only; hareHook also covers the BSDs.
    platforms = lib.intersectLists hareHook.meta.platforms lib.platforms.linux;
    inherit (hareHook.meta) badPlatforms;
  };
})
