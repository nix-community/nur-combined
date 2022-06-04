{
  stdenv
, fetchFromGitHub
, libpcap
, cmake
}: stdenv.mkDerivation rec {
  pname = "switch-lan-play";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "spacemeowx2";
    repo = pname;
    rev = "v${version}";
    sha256 = "04z86sayz2zm7gpiakw4appxf8nbna736rvbmifsq2fh2yw8dsvj";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libpcap ];
}
