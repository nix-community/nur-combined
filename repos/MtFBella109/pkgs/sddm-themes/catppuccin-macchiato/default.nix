{ stdenv, fetchFromGitHub }:
  stdenv.mkDerivation rec {
    pname = "catppuccin-macchiato";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src/src/catppuccin-macchiato $out/share/sddm/themes/catpuccin-macchiato
    '';
    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "master";
      sha256 = "sha256-tyuwHt48cYqG5Pn9VHa4IB4xlybHOxPmhdN9eae36yo=";
    };
}
