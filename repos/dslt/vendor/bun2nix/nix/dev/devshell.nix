{
  perSystem =
    { pkgs, self', ... }:
    let
      inherit (pkgs) lib stdenv;

      moldHook =
        pkgs.makeSetupHook
          {
            name = "mold-hook";

            propagatedBuildInputs = with pkgs; [
              mold
            ];
          }
          (
            pkgs.writeText "moldHook.sh" ''
              export RUSTFLAGS="-C link-arg=-fuse-ld=mold"
            ''
          );
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy

          zig
          zon2nix

          mdbook

          bun
          self'.packages.bun2nix

          wasm-bindgen-cli_0_2_104
          wasm-pack
          lld

          elixir_1_19

          (lib.optional (!stdenv.isDarwin) moldHook)
        ];
      };
    };
}
