{ stdenv, fetchgit, fetchpatch, cmake, linenoise, opencv, ... }:

stdenv.mkDerivation rec {
  version = "master";
  name = "fuji-cam-wifi-tool-${version}";

  src = fetchgit {
    url = "https://github.com/hkr/fuji-cam-wifi-tool.git";
    rev = "d66aad105f8533f62cf308647850c04f3436af26";
    sha256 = "0bnqdqs7g1p5qz3jnlazydznym516bwwxsyzybqxqxy01jjpc5kw";
  };

  patches = [ ./my.patch ];

  buildInputs = [ linenoise opencv ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DWITH_OPENCV=ON" ];

  meta = with stdenv.lib; {
    description =
      "Trying to reverse-engineer the wifi remote control protocol used by Fuji X series cameras";
    homepage = "https://github.com/hkr/fuji-cam-wifi-tool";
    license = licenses.unlicense;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}
