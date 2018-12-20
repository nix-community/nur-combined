{ stdenv, fetchFromGitHub, rustPlatform
, libxcb
, pkgconfig, python3 }:

rustPlatform.buildRustPackage rec {
  name = "xcolor-${version}";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Soft";
    repo = "xcolor";
    rev = "${version}";
    sha256 = "1nxyy0d12xw1pksshxl31h2fzcaqazlw60g1h279jh103b2xdbhz";
  };

  cargoSha256 = "0wm89q9i0qb32c21jfvcrp3d58685npdzqpvdi16h92hsnz42pzy";

  nativeBuildInputs = [ pkgconfig python3 ];
  buildInputs = [ libxcb ];

  preFixup = ''
    mkdir -p "$out/man/man1"
    cp man/xcolor.1 "$out/man/man1/"
    mkdir -p "$out/share/"{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
    cp target/release/build/xcolor-*/out/xcolor.bash "$out/share/bash-completion/completions/"
    cp target/release/build/xcolor-*/out/xcolor.fish "$out/share/fish/vendor_completions.d/"
    cp target/release/build/xcolor-*/out/_xcolor "$out/share/zsh/site-functions/"
  '';

  meta = with stdenv.lib; {
    description = "Lightweight color picker for X11";
    homepage = https://github.com/Soft/xcolor;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
