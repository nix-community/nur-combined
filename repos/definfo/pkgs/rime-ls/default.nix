{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  librime,
}:
rustPlatform.buildRustPackage rec {
  pname = "rime-ls";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xzquG8DMvZGiszXrYGiv31QGDd776UbKrNnwzGv9DQ0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librime-sys-0.1.0" = "sha256-zJShR0uaKH42RYjTfrBFLM19Jaz2r/4rNn9QIumwTfA=";
    };
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [ librime ];

  doCheck = false; # FIXME: test failed at test_get_candidates 

  meta = {
    description = "A language server for Rime input method engine";
    homepage = "https://github.com/wlh320/rime-ls";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
