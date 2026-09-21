{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "sfm";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "sfm";
    rev = "3ed122c02670f7d58d5c80853a5ddd40fce25d2b";
    hash = "sha256-/38OaV0SXXJck5Wl4PgJH/kTtPHOr5/lKdZFGBA53SQ=";
  };
  
  installFlags = [ "PREFIX=$(out)" ]; 

  meta = {
    description = "A very minimal and suckless terminal file manager";
    homepage = "https://github.com/yashsio/sfm";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "sfm";
  };
}

