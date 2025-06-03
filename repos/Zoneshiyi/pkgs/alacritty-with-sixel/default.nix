{
  pkgs,
  lib,
  ...
}:
pkgs.alacritty.override (
  let
    rp = pkgs.rustPlatform;
  in
  {
    rustPlatform = rp // {
      buildRustPackage =
        args:
        rp.buildRustPackage (
          args
          // {
            version = "0.15.1";
            src = pkgs.fetchFromGitHub {
              owner = "ayosec";
              repo = "alacritty";
              rev = "814e8fefc60b4457ea155d11df9f27795de830ec";
              hash = "sha256-NgA04vTAODp1g79Q/zvAYORdDypI/i5+kqq61mflc48=";
            };
            cargoHash = "sha256-Pr2VTPa/1SNr1W4NkxDKquj10uArR/M3WxVjhI1Ioko=";
            meta = with lib; {
              description = "Cross-platform, GPU-accelerated terminal emulator(With Sixel support)";
              homepage = "https://github.com/ayosec/alacritty";
              license = licenses.mit;
              mainProgram = "alacritty";
              platforms = platforms.unix;
            };
          }
        );
    };
  }
)
