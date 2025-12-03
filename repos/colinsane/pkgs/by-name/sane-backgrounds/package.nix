# NixOS backgrounds:
# - <https://github.com/NixOS/nixos-artwork>
#   - <https://github.com/NixOS/nixos-artwork/issues/50>  (colorful; unmerged)
#   - <https://github.com/NixOS/nixos-artwork/pull/60/files>  (desktop-oriented; clean; unmerged)
# - <https://itsfoss.com/content/images/2023/04/nixos-tutorials.png>
{
  stdenvNoCC,
  inkscape,
}:
stdenvNoCC.mkDerivation {
  pname = "sane-backgrounds";
  version = "0.3";

  src = ./.;

  nativeBuildInputs = [ inkscape ];

  buildPhase = ''
    inkscape sane-nixos-bg.svg -o sane-nixos-bg.png
  '';

  installPhase = ''
    mkdir -p $out/share/backgrounds
    cp *.svg *.png $out/share/backgrounds
  '';
}
