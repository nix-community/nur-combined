{ stdenv, fetchFromGitHub, gzip, exa }:

stdenv.mkDerivation rec {
  pname = "vlmcsd";
  version = "1113";

  src = fetchFromGitHub {
    owner = "Wind4";
    repo = pname;
    rev = "svn${version}";
    sha256 = "sha256-OKysOm44T9wrAaopp9HfLlox5InlpV33AHGXRSjhDqc=";
  };

  buildPhase = ''
    make

    pushd man
    ${gzip}/bin/gzip -fk *.[0-9]
    popd
  '';

  installPhase = ''
    pushd bin
    for bin in vlmcs{d,}; do
      install -Dm755 $bin "$out/bin/$bin"
    done
    popd

    pushd man
    for manpage in *.[0-9]; do
      section=''${manpage##*.}
      install -Dm644 "$manpage.gz" "$out/share/man/man$section/$manpage.gz"
    done
    popd
  '';

  meta = with stdenv.lib; {
    description = "KMS Emulator in C.";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = licenses.unfree;
  };
}
