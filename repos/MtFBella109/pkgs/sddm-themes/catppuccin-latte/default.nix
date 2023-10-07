{ stdenv, fetchFromGitHub }:
  stdenv.mkDerivation rec {
    pname = "catppuccin-frappe";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src/src/catppuccin-frappe $out/share/sddm/themes/catpuccin-frappe
    '';
    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "master";
      sha256 = "sha256:SjYwyUvvx/ageqVH5MmYmHNRKNvvnF3DYMJ/f2/L+Go=";
    };
}
