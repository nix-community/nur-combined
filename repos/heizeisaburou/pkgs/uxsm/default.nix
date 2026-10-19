# The recipe of https://github.com/heizeisaburou/uxsm, the same one as its
# packaging/nix/package.nix (submitted to nixpkgs as NixOS/nixpkgs#574216,
# closed until the project is more mature), with the maintainer written out:
# nixpkgs has no heizeisaburou entry in lib.maintainers.
#
# Nix does not call the Makefile: buildGoModule builds and installs the binary
# itself, so any other installed file has to be added in postInstall too.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "uxsm";
  version = "0.1.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "heizeisaburou";
    repo = "uxsm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SW+j06+kVSxv4hPiVToMm2w5NSeea9dhVGa9dDJn5jw=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # The test sets PATH=/usr/bin:/bin for the loader shell, so id, tr and env
  # are not found in the sandbox. Since 1983120 it uses the caller's PATH, so
  # this can go once a release includes that commit.
  checkFlags = [ "-skip=^TestRunLoader$" ];

  nativeBuildInputs = [ installShellFiles ];

  # The units and the manual page are templates that the upstream Makefile
  # fills in at install time; buildGoModule does not use the Makefile.
  # Only some of the units call the binary, hence --replace-quiet there.
  postInstall = ''
    for f in data/systemd/user/*.in; do
      unit=$out/lib/systemd/user/$(basename "$f" .in)
      install -Dm644 "$f" "$unit"
      substituteInPlace "$unit" --replace-quiet @BINDIR@ $out/bin
    done

    substitute data/man/uxsm.1.in uxsm.1 \
      --replace-fail @BINDIR@ $out/bin \
      --replace-fail @VERSION@ ${finalAttrs.version}
    installManPage uxsm.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "X11 session manager for systemd --user, the X11 counterpart of uwsm";
    homepage = "https://github.com/heizeisaburou/uxsm";
    changelog = "https://github.com/heizeisaburou/uxsm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [
      {
        email = "heizeisaburou@gmail.com";
        github = "heizeisaburou";
        githubId = 243756430;
        name = "平城三郎";
      }
    ];
    mainProgram = "uxsm";
    platforms = lib.platforms.linux;
  };
})
