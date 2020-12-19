{ stdenv, fetchFromGitHub, python38Packages }:

python38Packages.buildPythonApplication rec {
  pname = "electrumx";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "spesmilo";
    repo = "electrumx";
    rev = "1.16.0";
    sha256 = "1yqx94vvgswbh9jwh8jn9bama88izh2f5f43wy6j6qlr1n044r4r";
  };

  propagatedBuildInputs = with python38Packages; [ wheel pytest setuptools aiohttp attrs plyvel pylru aiorpcx ujson uvloop ];

  patches = [ ./setup.patch ];

  meta = with stdenv.lib; {
    description = "A reimplementation of electrum-server.";
    longDescription = ''
      This project is a fork of kyuupichan/electrumx. 
      The original author dropped support for Bitcoin, which we intend to keep.
    '';
    homepage = "https://electrumx-spesmilo.readthedocs.io";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
