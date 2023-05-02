{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, autoreconfHook
, wayland
}:

stdenv.mkDerivation rec {
  pname = "wldbg";
  version = "unstable-2018-02-18";

  src = fetchFromGitHub {
    owner = "mchalupa";
    repo = pname;
    rev = "8ff952ce5ce4081109ccb9ea03cfd6158784a9cf";
    hash = "sha256-7/ooV8zM7yirEBtevDuER4V7UGA6HrgsoawbtfKcXdQ=";
  };

  patches = [ ./fix-build.diff ];

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ wayland ];
  
  meta = with lib; {
    description = "Tool for processing wayland connections";
    homepage = "https://github.com/mchalupa/wldbg";
    license = licenses.mit;
  };
}

