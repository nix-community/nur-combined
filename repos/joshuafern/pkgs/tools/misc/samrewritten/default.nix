{ stdenv, lib, fetchFromGitHub, pkg-config, curl, glibmm, gtkmm3, yajl }:

stdenv.mkDerivation rec {
  pname = "samrewritten";
  version = "r133";

  src = fetchFromGitHub {
    owner = "PaulCombal";
    repo = pname;
    rev = "a8399302d806c9659daf88e101941447b3d1348e";
    sha256 = "1qfvpnkl565a9sfgqyyxhha7i1pg679zmf8fmafdp3b3mn2mpcgk";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl glibmm gtkmm3 yajl ];

  NIX_LDFLAGS = "-lpthread";

  installPhase = ''  
    install -dm755 "$out/usr/lib/"
    # Copy required files.
    mkdir -p $out/usr/lib/${pname}
    cp -r --parents ./{bin/{launch.sh,libsteam_api.so,samrewritten},glade} "$out/usr/lib/${pname}"
    # Executable
    install -dm755 "$out/usr/bin"
    ln -s "$out/usr/lib/${pname}/bin/launch.sh" "$out/usr/bin/samrewritten"
  '';

  meta = with stdenv.lib; {
    description = "Allows you to unlock and relock your Steam achievements";
    homepage    = "https://github.com/PaulCombal/SamRewritten";
    license     = licenses.gpl3;
    maintainers = with maintainers; [ joshuafern ];
    platforms   = platforms.linux;
  };
}
