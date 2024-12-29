{ lib, fetchFromGitHub, stdenvNoCC, wallpapersCategory }: stdenvNoCC.mkDerivation {
  pname = "gruvbox-wallpapers-${wallpapersCategory}";
  version = "0-unstable-2024-12-19";
  src = fetchFromGitHub {
    owner = "AngelJumbo";
    repo = "gruvbox-wallpapers";
    rev = "edb315e711791d2eca4e5873d583ba47325672e0";
    hash = "sha256-Lklzk//gVhGmsPE8uWXcaN8y5fHMoKsneerWkJ8RG70=";
  };
  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;
  dontCheck = true;
  dontFixup = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp wallpapers/${wallpapersCategory}/* $out 
    runHook postInstall
  '';
  meta = {
    homepage = "https://gruvbox-wallpapers.pages.dev/";
    description = "Opinionated list of Gruvbox-friendly wallpapers by AngelJumbo in ${wallpapersCategory} category";
    longDescription = ''
      Opinionated list of Gruvbox-friendly wallpapers by AngelJumbo in ${wallpapersCategory} category

      The author of this package is not responsible for violations of copyright laws. The author of this package wrote the source code that is used by the Nix package manager to obtain images from an open source, in this case, a GitHub repository. If you have any copyright infringement claims, please direct them to the creator of that GitHub repository: "https://github.com/AngelJumbo/gruvbox-wallpapers".
    '';
    license = [ lib.licenses.unfree ]; # repository author didn't assigned any license so according to nixpkgs guidelines it's unfree
  };
}

