{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "access-os-plymouth-theme";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "boo15mario";
    repo = "access-os-plymouth-theme";
    rev = "main";
    sha256 = "0s4dc970ikw445hxa2p4da25g77rrb4lp4ix6wzivigqfd0mywvz";
  };

  installPhase = ''
    mkdir -p $out/share/plymouth/themes
    cp -r access-os-boot $out/share/plymouth/themes/
  '';

  meta = with lib; {
    description = "Official Plymouth boot splash theme for access-OS.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
