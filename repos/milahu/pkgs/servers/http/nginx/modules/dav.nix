{
  lib,
  mkNginxPlugin,
  fetchFromGitHub,
  expat,
}:

mkNginxPlugin rec {
  pname = "dav";
  version = "4.0.1";
  src = fetchFromGitHub {
    owner = "arut";
    repo = "nginx-dav-ext-module";
    # https://github.com/arut/nginx-dav-ext-module/pull/80
    rev = "9f112cf8e396ea5e1bdc70cedfa4f5cbc48fe98a";
    hash = "sha256-BMYRH/BNuq/TTWPWdQJpz/Mx64vNEN7SQ/Swu3by92A=";
  };

  inputs = [ expat ];

  meta = with lib; {
    description = "WebDAV PROPFIND,OPTIONS,LOCK,UNLOCK support";
    homepage = "https://github.com/mid1221213/nginx-dav-ext-module";
    license = with licenses; [ bsd2 ];
    maintainers = [ ];
  };
}
