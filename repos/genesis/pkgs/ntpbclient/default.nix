{ stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {
  version = "0.5.3";
  pname = "ntpbclient";

  src = fetchFromGitHub {
    owner = "mlafeldt";
    repo  = "ps2rd";
    rev = "v${version}";
    sha256 = "1ajap0w8sz8jmc5yj4gxvqmyymdahj0vhjlk3dm7xri9rrcv4rn6";
  };

  buildInputs = [ perl ];
  dontBuild = true;
  installPhase = ''install -Dm755 ./pc/ntpbclient/ntpbclient -t $out/bin '';

  meta = with stdenv.lib; {
    description = "Client application to talk to the server side of PS2rd";
    homepage = https://github.com/mlafeldt/ps2rd;
    license = licenses.gpl3;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.unix;
  };
}
