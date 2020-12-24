{ stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "saait";
  version = "2020-11-15";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = "f242e6ade5979fd153b0b2a97a252912fa91b842";
    sha256 = "1pbynkkqa3pi80jqdvrah9j4y1sydj6v2fy24wvxckayh56v8k38";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    description = "The most boring static page generator";
    homepage = "https://git.codemadness.org/saait/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
