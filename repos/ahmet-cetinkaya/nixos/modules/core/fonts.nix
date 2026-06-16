{
  pkgs,
  inputs,
  ...
}: {
  fonts.fontconfig.enable = true;
  fonts.packages = with inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
    manrope
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
}
