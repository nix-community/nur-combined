# copy pasted from http://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/icons/bibata-cursors/translucent.nix
#
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "bibata-cursors-translucent";
  version = "git";

  src = fetchFromGitHub {
    owner = "rosxz";
    repo = "Bibata_Cursor_Translucent";
    rev = "6b33097a687d20ecd8160b0e4a39aa74c40f43ee";
    sha256 = "sha256-q4VQ91ZMGvAsu9q/Hf6oHqjbdQ26auV/zHfxmExEHQA=";
  };

  installPhase = ''
    install -dm 0755 $out/share/icons
    cp -pr Bibata_* $out/share/icons/
  '';

  meta = with lib; {
    description = "Translucent Varient of the Material Based Cursor, with symlink fixes";
    homepage = "https://github.com/rosxz/Bibata_Cursor_Translucent";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [];
  };
}
