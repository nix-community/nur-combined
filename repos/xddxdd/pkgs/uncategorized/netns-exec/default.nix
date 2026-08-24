{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "netns-exec";
  version = "0-unstable-2016-07-30";
  src = fetchFromGitHub {
    owner = "pekman";
    repo = "netns-exec";
    rev = "aa346fd058d47b238ae1b86250f414bcab2e7927";
    fetchSubmodules = true;
    hash = "sha256-CnIgzRb58KIvdx7T9LpervSB2Ol6JMxmSM/Ti3K1+Dg=";
  };
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-m4755" "-m755"

    # Force use sched func from libc
    substituteInPlace iproute2/configure \
      --replace-fail '$CC -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c' "true"
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = lib.licenses.gpl2Only;
    mainProgram = "netns-exec";
  };
})
