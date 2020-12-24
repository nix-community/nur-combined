{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "libshlist";
  version = "1.1";

  src = fetchzip {
    url = "https://github.com/Ventto/libshlist/archive/v${version}.tar.gz";
    sha256 = "1csx076ycnprxfw0ks3q1ygnla66qwrrmjz0krhrlj5v26ij4xrq";
  };

  patchPhase = ''
    patchShebangs ./liblist.sh
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp ./liblist.sh $out/lib/
  '';

  meta = with stdenv.lib; {
    description = "libshlist";
    homepage = "https://github.com/Ventto/libshlist";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ jk ];
  };
}
