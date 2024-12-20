_: {
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          just
          nix-output-monitor
          nvfetcher
        ];
      };
    };
}
