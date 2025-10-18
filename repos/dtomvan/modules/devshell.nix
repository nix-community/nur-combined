{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          gh
          git
          jujutsu
          just
          nix-output-monitor
          nix-update
          self'.formatter
        ];
      };
    };
}
