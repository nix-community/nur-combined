{ autoreconfHook, fetchgit, python37, stdenv }:
let
  my-python-packages = python-packages: with python-packages; [
    alembic
    Babel
    bcrypt
    celery
    certifi
    configobj
    dateutil
    email_validator
    exifread
    gst-python
    itsdangerous
    jinja2
    jsonschema
    lxml
    markdown
    oauthlib
    PasteDeploy
    pasteScript
    pillow
    PyLD
    pytest
    pytest_xdist
    pytz
    requests
    six
    sphinx
    sqlalchemy
    TurboCheetah
    unidecode
    virtualenv
    waitress
    webtest
    werkzeug
    wtforms
  ];
  python-with-my-packages = python37.withPackages my-python-packages;
in stdenv.mkDerivation rec {
  name = "mediagoblin-${version}";
  version = "v0.10.0";

  src = fetchgit {
    url = "https://git.savannah.gnu.org/git/mediagoblin.git";
    rev = "${version}";
    sha256 = "13s66snz9710xr7s2icnmmqb4756fq369gn0qa6cwja4xr25sjd4";
    fetchSubmodules = true;
  };

  buildInputs = [
    autoreconfHook
    python-with-my-packages
  ];

  meta = with stdenv.lib; {
    description =
      "MediaGoblin is a free software media publishing platform that anyone can run.";
    longDescription = ''
      MediaGoblin is a free software media publishing platform that
      anyone can run. You can think of it as a decentralized alternative
      to Flickr, YouTube, SoundCloud, etc.
    '';
    homepage = "https://mediagoblin.org";
    changelog =
      "https://git.savannah.gnu.org/cgit/mediagoblin.git/plain/NEWS?h=v${version}";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sehqlr ];
    platforms = platforms.linux;
    # broken = true;
  };
}

