{ stdenv, fetchFromGitHub }:
  stdenv.mkDerivation rec {
    pname = "catppuccin-latte";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src/src/catppuccin-latte $out/share/sddm/themes/catpuccin-latte
    '';
    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "master";
      sha256 = "sha256:SjYwyUvvx/ageqVH5MmYmHNRKNvvnF3DYMJ/f2/L+Go=";
    };
}
