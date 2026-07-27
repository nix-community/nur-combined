# https://github.com/nix-community/home-manager/blob/3b955f5f0a942f9f60cdc9cacb7844335d0f21c3/modules/programs/emacs.nix
{
  runCommand,
  writeText,
  emacs-pgtk,
  emacsPackages,
  pkgsCross,
  unstable,
  eownerdead,
  ...
}:
emacs-pgtk.pkgs.withPackages (
  p:
  let
    # Use emacsPackages for cache
    fromUsePackage =
      initEl:
      map (name: p.${name}) (
        builtins.fromJSON (
          builtins.readFile (
            runCommand "from-use-package" {
              nativeBuildInputs = [ p.emacs ];
            } "emacs --script ${./use-package-list.el} ${initEl} > $out || true"
          )
        )
      );

    packages =
      (fromUsePackage ./init.el)
      ++ (with p; [
        treesit-grammars.with-all-grammars
        llvm-mode
        (tramp-rpc.override {
          archs = [ ]; # TODO: Build fails
          tramp = eownerdead.emacsPackages.tramp;
        })
      ])
      ++ [
        unstable.emacs-pgtk.pkgs.ghostel
        unstable.emacs-pgtk.pkgs.agent-shell
        eownerdead.emacsPackages.eglot-supplements
        eownerdead.emacsPackages.majutsu
      ];

    userConfig = emacsPackages.trivialBuild {
      pname = "default";
      src = writeText "default.el" (builtins.readFile ./init.el);
      version = "0.1.0";
      packageRequires = packages;
    };
  in
  packages ++ [ userConfig ]
)
