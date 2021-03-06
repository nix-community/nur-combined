{ stdenv, fetchFromGitHub
, lz4
, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "lz4json-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "andikleen";
    repo = "lz4json";
    rev = "v2";
    sha256 = "1xxn8yzr6j8j6prmbj6mxspdczigarfiv3vlm9k70yxmky65ijh3";
  };

  outputs = [ "bin" "man" "out" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ lz4.dev ];

  installPhase = ''
    runHook preInstall

    mkdir -p ''${!outputBin}/bin
    cp -t ''${!outputBin}/bin lz4jsoncat

    mkdir -p $out/share/man/man1
    cp -t $out/share/man/man1 lz4jsoncat.1

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "C decompress tool for mozilla lz4json format";
    longDescription = ''
      A little utility to unpack lz4json files as generated by Firefox's
      bookmark backups and session restore. This is a different format from
      what the normal lz4 utility expects. The data is dumped to stdout.
    '';
    homepage = "https://github.com/andikleen/lz4json";
    license = with licenses; mit;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
