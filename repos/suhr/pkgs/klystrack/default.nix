{ stdenv, fetchFromGitHub
, pkgconfig
, SDL2, SDL2_image
}:

stdenv.mkDerivation rec {
  name = "klystrack";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "kometbomb";
    repo = "klystrack";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "1ca92fvm5jy9fnhww4hi7y4gvfi5cj3j2wkr0dgrx6b53ldc8nmx";
  };

  buildInputs = [
    SDL2.dev SDL2_image
  ];
  nativeBuildInputs = [ pkgconfig ];

  buildPhase = ''
    make DESTDIR=$out CFG=release
  '';

  installPhase = ''
    install -D -m 755 bin.release/klystrack $out/bin/klystrack
    mkdir -p $out/lib/klystrack
    cp -R res $out/lib/klystrack
  '';

  meta = with stdenv.lib; {
    description = "A chiptune tracker";
    homepage = https://github.com/kometbomb/klystrack;
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
