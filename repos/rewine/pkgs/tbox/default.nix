{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "tbox";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "tboox";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6SqMvwxKSiJO7Z33xx7cJoECu5AJ1gWF8ZsiERWx8DU=";
  };

  configureFlags = [
    "-force_utf8=y"
    "--hash=y"
    "--charset=y"
    "--float=y"
    "--demo=n"
  ];

  meta = with lib; {
    description = "A glib-like multi-platform c library";
    homepage = "docs.tboox.org";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

