{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, autoreconfHook
, wayland
}:

stdenv.mkDerivation rec {
  pname = "wldbg";
  version = "0.2.0-unstable-2023-10-19";

  src = fetchFromGitHub {
    owner = "mchalupa";
    repo = pname;
    rev = "a443a4ffe4922c8d484ed0679c7f5fcc3e8d00a4";
    hash = "sha256-wsh56ejOgKZZA8fQbY+imSYaCKZNuAqKPoHWLkrQ2FE=";
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

