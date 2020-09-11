{ stdenv, fetchgit, cmake, systemd, acpid }:

stdenv.mkDerivation rec {
  pname = "libthinkpad";
  version = "2.6";

  src = fetchgit {
    url = "https://github.com/libthinkpad/libthinkpad";
    rev = version;
    sha256 = "0jjnv6ipnndl5p5fni4v9dkh0m22xrrr04b16ywqdsv7c4sb771w";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ systemd acpid ];

  buildPhase = ''
    cmake . -DCMAKE_INSTALL_PREFIX=$out
    make
  '';

  meta = {
    homepage = "https://github.com/libthinkpad/libthinkpad";
    description = "A general purpose userspace ThinkPad library";
  };
}
