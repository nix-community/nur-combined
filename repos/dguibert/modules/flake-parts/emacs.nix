{
  inputs,
  perSystem,
  ...
}: let
in {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages.my-emacs = pkgs.my-emacs;

    devShells.emacs = pkgs.mkShell {
      name = "emacs";
      ENVRC = "emacs";
      CHEMACS_PROFILE = "dev";
      buildInputs = with pkgs; let
      in [
        biber
        my-texlive
        my-emacs
        gnuplot
        dtach
      ];
    };
  };
}
