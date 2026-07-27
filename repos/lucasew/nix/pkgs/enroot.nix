{ stdenv
, fetchFromGitHub
, flock
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "enroot";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "enroot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Sw4kfsb0Gi21At2pU8lt5wIfCih7VZ7Zf9/62xBKKRU=";
    fetchSubmodules = true;
  };

  postPatch = ''
  substituteInPlace Makefile \
    --replace-fail 'git submodule update' 'echo git submodule update'
  '';

  makeTarget = "install";
  makeFlags = ["DESTDIR=${placeholder "out"}" "prefix=/"];

  nativeBuildInputs = [
    flock
  ];
})
