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

  outputs = [ "bin" "man" "out" ];

  nativeBuildInputs = [ pkgconfig python3 ];
  buildInputs = [ libxcb ];

  preFixup = ''
    # move buildRustCrate outputs to proper split locations
    shopt -s dotglob
    if [[ -d "$out/bin" ]]; then
      mkdir -p "$bin/bin"
      mv -nt "$bin"/bin "$out"/bin/*
      rmdir "$out/bin"
    fi
    if [[ -d "$out/lib" ]]; then
      mkdir -p "$lib/lib"
      mv -nt "$lib"/lib "$out"/lib/*
      rmdir "$out/lib"
    fi
    if [[ -s "$out/env" ]]; then
      mv -nt "$lib" "$out"/env
    fi

    mkdir -p "$man/man/man1"
    cp man/xcolor.1 "$man/man/man1/"
    mkdir -p "$bin/share/"{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
    cp target/release/build/xcolor-*/out/xcolor.bash "$bin/share/bash-completion/completions/"
    cp target/release/build/xcolor-*/out/xcolor.fish "$bin/share/fish/vendor_completions.d/"
    cp target/release/build/xcolor-*/out/_xcolor "$bin/share/zsh/site-functions/"
  '';

  meta = with stdenv.lib; {
    description = "Lightweight color picker for X11";
    homepage = https://github.com/Soft/xcolor;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
