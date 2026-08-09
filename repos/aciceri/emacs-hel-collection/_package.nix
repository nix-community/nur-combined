{
  emacsPackages,
  callPackage,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  # Defaulted so the package stays callable with `callPackage f { }`, while the
  # emacs module can inject the single `hel` instance built against its `epkgs`.
  hel ? callPackage ../emacs-hel/_package.nix { inherit emacsPackages; },
  ...
}:
# hel-collection (Hel bindings for third-party packages) absorbed the
# now-archived hel-agent-shell. Its modes/ tree is loaded by path at runtime,
# so install it alongside the elisp instead of flattening like mcp-server.
emacsPackages.trivialBuild {
  pname = "hel-collection";
  version = "0-unstable-2026-08-07";

  src = fetchFromGitHub {
    owner = "helheim-emacs";
    repo = "hel-collection";
    rev = "60d59e70eee3f486756ecfba7d08df9807bfa4ca";
    hash = "sha256-P6pOLZnFPUSSgpmG/5/phngWADMLzVvK3f3rTvfVDN0=";
  };

  packageRequires = [
    hel
    emacsPackages.dash
  ];

  postInstall = ''
    cp -r modes $out/share/emacs/site-lisp/
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-hel-collection --version=branch";

  meta = {
    description = "Collection of Hel keybindings for built-in and third-party Emacs packages";
    homepage = "https://github.com/helheim-emacs/hel-collection";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
