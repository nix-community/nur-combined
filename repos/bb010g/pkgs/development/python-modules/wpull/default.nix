{ lib, buildPythonPackage, fetchFromGitHub, fetchpatch
, chardet, dnspython, html5lib, namedlist, sqlalchemy, tornado_4, Yapsy
}:

buildPythonPackage rec {
  pname = "wpull";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "ArchiveTeam";
    repo = "wpull";
    rev = "ddf051aa3322479325ba20aa778cb2cb97606bf5";
    sha256 = "06hfh0r2wjpcmkz7ky1k6f9c10r0p8wk9g6z7fpnacss72qbgmjw";
  };

  propagatedBuildInputs = [
    chardet
    dnspython
    html5lib
    namedlist
    sqlalchemy
    tornado_4
    Yapsy
  ];

  patches = [
    # use dnspython>=1.13 (e.g. Nixpkgs's 1.16) instead of dnspython3==1.12
    ./dnspython.patch
    # fix tests for dnspython >= 1.16
    (fetchpatch {
      url = "https://github.com/ArchiveTeam/wpull/pull/420/commits/81dad6ad99a14d4906090138b23ca4fcb76bb688.patch";
      sha256 = "0cy2vccqwvyf4b0mm2003b57f46npikh5jpcgnrfqg303g2l6w81";
    })
  ];

  doCheck = false;

  meta = with lib; {
    description = "Wget-compatible web downloader and crawler.";
    homepage = "https://github.com/ArchiveTeam/wpull";
    longDescription = ''
      Wpull is a Wget-compatible (or remake/clone/replacement/alternative) web
      downloader and crawler.

      Notable Features:
      - Written in Python: lightweight, modifiable, robust, & scriptable
      - Graceful stopping; on-disk database resume
      - PhantomJS & youtube-dl integration (experimental)
    '';
    license = with licenses; gpl3;
    maintainers = with maintainers; [ bb010g ];
  };
}

