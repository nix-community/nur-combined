{ stdenv, buildPythonApplication, fetchgit
, aiohttp, iso8601, websockets
}:

buildPythonApplication rec {
  pname = "broca-unstable";
  version = "2018-02-07";

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/broca";
    rev = "0ed8797949d2f99bf8a259021daedc42243c2e44";
    sha256 = "1kxia3gd7fzqqalc2z5sp9d2vsqhcgmzzi43dp7x7mwwp1xq203d";
  };

  propagatedBuildInputs = [
    aiohttp
    iso8601
    websockets
  ];

  PKGVER = "0.1.0+${version}";

  postPatch = ''
    sed -i setup.py \
      -e $'/install_requires = \\[\'srht\', \'flask-login\'\\]/d'
    substituteInPlace broca-daemon \
      --replace '[ "broca.ini"' '[ "~/.config/broca/broca.ini", "broca.ini"'
  '';

  meta = with stdenv.lib; {
    description =
      "Bittorrent RPC proxy between Transmission clients and Synapse servers";
    homepage = https://broca.synapse-bt.org/;
    downloadPage = https://git.sr.ht/~sircmpwn/broca;
    license = with licenses; bsd3;
    maintainers = with maintainers; [ bb010g ];
  };
}
