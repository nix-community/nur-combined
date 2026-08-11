{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "bbcode";
  version = "0.02";

  src = fetchFromGitHub {
    owner = "ivartj";
    repo = "bbcode";
    # rev = version;
    # https://github.com/ivartj/bbcode/pull/2
    rev = "50d5215967b3194964215be4510833fc20050a33";
    hash = "sha256-FrZnh9gtrA7o4AYUXgDDyXj8kH/eKKIvPAVyu9wHymw=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = {
    description = "BBCode implementation in C";
    homepage = "https://github.com/ivartj/bbcode";
    # FIXME unfree https://github.com/ivartj/bbcode/issues/1
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bbcode";
    platforms = lib.platforms.all;
  };
}
