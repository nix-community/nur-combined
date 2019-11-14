{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  isPy3k,
  flask,
  flask-httpauth,
  stem,
  pyqt5,
  pycrypto,
  pysocks,
  pytest,
  requests,
  tor,
  obfs4,
}:

buildPythonApplication rec {
  pname = "onionshare";
  version = "2.2";
  src = fetchFromGitHub {
    owner = "micahflee";
    repo = pname;
    rev = "v${version}";
    sha256 = "0m8ygxcyp3nfzzhxs2dfnpqwh1vx0aws44lszpnnczz4fks3a5j4";
  };

  disable = !isPy3k;
  propagatedBuildInputs = [
    flask
    flask-httpauth
    stem
    pyqt5
    pycrypto
    pysocks
    requests
  ];
  buildInputs = [
    tor
    obfs4
  ];
  checkInputs = [
    pytest
  ];

  patches = [ ./nixify.patch ];

  # replace @tor@, @obfs4@, @geoip@ w/ store paths.
  inherit tor obfs4;
  inherit (tor) geoip;
  postPatch = "substituteAllInPlace onionshare/common.py";

  doCheck = false;  # need a $HOME

  meta = with lib; {
    description = "Securely and anonymously send and receive files";
    longDescription = ''
    OnionShare is an open source tool for securely and anonymously sending
    and receiving files using Tor onion services. It works by starting a web
    server directly on your computer and making it accessible as an
    unguessable Tor web address that others can load in Tor Browser to
    download files from you, or upload files to you. It doesn't require
    setting up a separate server, using a third party file-sharing service,
    or even logging into an account.

    Unlike services like email, Google Drive, DropBox, WeTransfer, or nearly
    any other way people typically send files to each other, when you use
    OnionShare you don't give any companies access to the files that you're
    sharing. So long as you share the unguessable web address in a secure way
    (like pasting it in an encrypted messaging app), no one but you and the
    person you're sharing with can access the files.
    '';

    homepage = https://onionshare.org/;

    license = licenses.gpl3Plus;
  };
}
