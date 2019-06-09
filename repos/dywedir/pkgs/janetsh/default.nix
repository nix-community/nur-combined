{ stdenv, fetchFromGitHub, pkg-config, janet, readline80 }:

stdenv.mkDerivation rec {
  pname = "janetsh";
  version = "unstable-2019-06-06";

  src = fetchFromGitHub {
    owner = "andrewchambers";
    repo = pname;
    rev = "a09143f6317aec75823f8c9593732a485bf65632";
    sha256 = "07r4cq4fq2psasshisngbrgn59bdz1vhsl85bfcf0yqyvwcmbgfr";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ janet readline80 ];

  doCheck = false;

  preConfigure = ''
    patchShebangs ./support/do
  '';

  meta = with stdenv.lib; {
    description = "Interactive shell and scripting tool based on the Janet programming language";
    homepage = "https://github.com/andrewchambers/janetsh";
    license = licenses.mit;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.all;
  };

  passthru = {
    shellPath = "/bin/janetsh-posix-wrapper";
  };
}
