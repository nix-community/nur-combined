{ stdenv, rustPlatform, fetchFromGitHub
, lz4
, pkgconfig
}:

rustPlatform.buildRustPackage rec {
  name = "mozlz4-tool-${version}";
  version = "0.2.0+${stdenv.lib.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "lilydjwg";
    repo = "mozlz4-tool";
    rev = "c561c2f7fc92fb0a283facde9b66324b4eadf7fa";
    sha256 = "09300w0750ij75jf5xn1fyrh57c2545dcv7s1sc67n95d6jv6khq";
  };

  cargoSha256 = "06lc2fffm3xi7lzwgcvpdnz2sk1952sxh8cxyh2s8dham70687ib";

  outputs = [ "out" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ lz4 ];

  meta = with stdenv.lib; {
    description = "A tool to process mozlz4 files";
    longDescription = ''
      A simple tool to decompress and compress files into the mozlz4 format used
      by Firefox.
    '';
    homepage = https://github.com/lilydjwg/mozlz4-tool;
    license = with licenses; free;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
