{
  stdenv,
  lib,
  fetchFromGitHub,
  rustc,
  raylib,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "crust";
  version = "0-unstable-2025-04-23";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "Crust";
    rev = "209c68dd45d5b279e4b337b1674968474dcdf5ef";
    hash = "sha256-jjhT9RmmxeU7jmcv7JGete70RQz8uNQvJItMjwpFcKs=";
  };

  patches = [ ./use-nix-raylib.patch ];

  nativeBuildInputs = [ rustc ];
  buildInputs = [ raylib ];

  installPhase = "mkdir -p $out/bin; cp main $out/bin/crust";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust that is actually Fun";
    homepage = "https://github.com/tsoding/Crust";
    license = lib.licenses.mit; # not yet actually licensed but I will infer this for now.
    mainProgram = "crust";
  };
}
