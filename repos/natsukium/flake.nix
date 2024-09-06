{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues (import ./overlays);
          };
        }
      );
      overlays.default = import ./overlay.nix;

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = import nixpkgs { inherit system; };
            update-readme = pkgs.writeShellApplication {
              name = "update-readme";
              runtimeInputs = [ pkgs.emacs ];
              text = ''
                emacs -l ob -l ob-shell --batch --eval "
                  (progn
                    (let ((org-confirm-babel-evaluate nil))
                    (dolist (file command-line-args-left)
                      (with-current-buffer (find-file-noselect file)
                        (org-babel-execute-buffer)
                        (save-buffer)))))
                  " README.org
              '';
            };
          in
          pkgs.mkShellNoCC {
            packages = [
              pkgs.nvfetcher
              update-readme
            ];
          };
      });
    };
}
