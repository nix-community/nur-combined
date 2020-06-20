{ stdenv, fetchFromGitLab, meson, ninja, cairo, pkg-config, cmake, libX11, libpng }:
stdenv.mkDerivation rec {
  pname = "pscircle";
  version = "1.3.1";

  src = fetchFromGitLab {
    owner = "mildlyparallel";
    repo = "pscircle";
    rev = "v${version}";
    sha256 = "1sm99423hh90kr4wdjqi9sdrrpk65j2vz2hzj65zcxfxyr6khjci";
  };

  nativeBuildInputs = [ meson ninja ];
  buildInputs = [ cairo libX11 libpng cmake pkg-config ];

  meta = with stdenv.lib; {
    description = "Allows you to see your linux processes as a tree";
    license = licenses.mit;
    homepage = "https://gitlab.com/mildlyparallel/pscircle";
    maintainers = [ "Extends <sharosari@gmail.com>" ];
    platforms = platforms.linux;
  };
}

