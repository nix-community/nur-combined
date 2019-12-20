{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "silver";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "reujab";
    repo = pname;
    rev = "v${version}";
    sha256 = "0p992lvsvs0fr2dksb84h9xyzxxwi8y3720zz2b7l5yg61brz72m";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ openssl ];

  cargoSha256 = "0iwgipj6vpc6gy06m873lylzv3fbsmc6srk9lqnyc2zik3h3v9la";

  meta = with stdenv.lib; {
    description = "A cross-shell customizable powerline-like prompt with icons";
    homepage = https://github.com/reujab/silver;
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
