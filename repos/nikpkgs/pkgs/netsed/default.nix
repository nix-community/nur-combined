{
  lib,
  stdenv,
  fetchgit,
}:
with lib;
let
  pname = "netsed";
  author = "xlab";
  version = "20230501";
  src = fetchgit {
    name = "${pname}-${version}.tar.gz";
    url = "https://github.com/${author}/${pname}";
    rev = "9e613e0b62b7b5cfa8ca96d8f337d70123f04c0b";
    sha256 = "sha256-sR4zit47S4VJ+u+N20glhub3ZVQNdYHQEsN9uTRvaVY=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  patches = [ ./stfu.patch ];

  makeFlags = [ "PREFIX=${builtins.placeholder "out"}" ];

  meta = with lib; {
    description = "NetSED is small and handful utility designed to alter the contents of packets forwarded thru your network in real time.";
    homepage = "https://github.com/${author}/${pname}";
    license = licenses.gpl2Only;
  };
}
