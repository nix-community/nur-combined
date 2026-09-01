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
  version = "0-unstable-2026-08-31";

  src = fetchFromGitHub {
    owner = "helheim-emacs";
    repo = "hel-collection";
    rev = "7d0d050fd555b3ac187e2754c0b2d327256a58ab";
    hash = "sha256-TeTyoWSeUur9LaTYWJ/w1CE1Ze+yuwVGBl1wzCICTd0=";
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
