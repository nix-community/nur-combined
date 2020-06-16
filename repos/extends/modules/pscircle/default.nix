{ stdenv, fetchFromGitLab, meson, ninja, cmake, pkg-config, cairo }:
stdenv.mkDerivation rec {
  name = "pscircle";
  version = "1.3.1";

  src = fetchFromGitLab {
    owner = "mildlyparallel";
    repo = "pscircle";
    rev = "v${version}";
    sha256 = "1sm99423hh90kr4wdjqi9sdrrpk65j2vz2hzj65zcxfxyr6khjci";
  };

  nativeBuildInputs = [ ninja meson ];
  buildInputs = [ pkg-config cairo cmake ];

  meta = with stdenv.lib; {
    description = "Represents your linux processes in a tree";
    license = licenses.gpl2;
    maintainers = [ maintainers.extends ];
    platforms = platforms.all;
  };
}
