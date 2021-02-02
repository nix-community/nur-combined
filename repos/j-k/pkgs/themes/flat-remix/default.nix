{ stdenv, lib, fetchFromGitHub, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "flat-remix-theme";
  version = "20201129";

  src = fetchFromGitHub {
    owner = "daniruiz";
    repo = "flat-remix-gtk";
    rev = version;
    sha256 = "15awbswv2ay5l6zbc53qsir61s6yv69l25vbm4sp0gvza12lf2cl";
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  dontBuild = true;

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A GTK application theme inspired by material design.";
    longDescription = ''
      Flat Remix is a GTK application theme inspired by material design.
      It is mostly flat using a colorful palette with some shadows, highlights, and gradients for some depth.
    '';
    homepage = "https://drasite.com/flat-remix-gtk";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jk ];
  };
}
