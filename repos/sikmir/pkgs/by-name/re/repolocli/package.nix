{
  stdenv,
  lib,
  rustPlatform,
  fetchFromSourcehut,
  curl,
  libiconv,
  openssl,
  pkg-config,
  makeWrapper,
}:

rustPlatform.buildRustPackage {
  pname = "repolocli";
  version = "0-unstable-2021-04-06";

  src = fetchFromSourcehut {
    owner = "~matthiasbeyer";
    repo = "repolocli";
    rev = "32b24f4e03d0dc48db7f7d9927501b07b4821c33";
    hash = "sha256-hNT+DilBpzjoJBVgXTB9kU4Obh8cszXFLCTaNhiOZHM=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-XGjpZIMDaNTEoBe4siuy2jIQjsj6+hbss8QUzXCb1cQ=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs =
    lib.optionals stdenv.isLinux [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      curl
      libiconv
    ];

  postInstall = ''
    install -Dm644 repolocli.toml -t $out/etc/xdg

    wrapProgram $out/bin/repolocli \
      --prefix XDG_CONFIG_DIRS : $out/etc/xdg
  '';

  meta = {
    description = "Repology commandline interface (and API)";
    homepage = "https://git.sr.ht/~matthiasbeyer/repolocli";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isLinux;
  };
}
