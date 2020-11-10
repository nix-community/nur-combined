{ stdenv, fetchFromGitHub, cmake } :

stdenv.mkDerivation rec {
  pname = "spglib";
  version = "1.15.1";


  src = fetchFromGitHub {
    owner = "atztogo";
    repo = "spglib";
    rev = "v${version}";
    sha256 = "1f5i0xnxjdhaxqklg1z232z6ra1yv0knfixvbd519k6fildwnr3z";
  };

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "C library for finding and handling crystal symmetries";
    homepage = "https://atztogo.github.io/spglib/";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

