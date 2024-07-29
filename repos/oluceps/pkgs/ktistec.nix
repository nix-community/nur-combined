{
  lib,
  fetchFromGitHub,
  fetchpatch,
  crystal,
  jq,
  libxml2,
  makeWrapper,
  gmp,
  sqlite,
  pkg-config,
}:

crystal.buildCrystalPackage rec {
  pname = "ktistec";
  version = "2.0.0-unstable-2024-07-20";

  src = fetchFromGitHub {
    owner = "toddsundsted";
    repo = pname;
    rev = "af675254af6b531eb880864eadb6b43e16eb54f8";
    hash = "sha256-TbBVj8H51+D6YhGIIVC2R2yw6mFGrf91IP/05A3iLEA=";
  };

  postPatch = ''
    rm shard.lock
    ln -s ${./lock/ktistec.lock} shard.lock
  '';
  format = "shards";

  nativeBuildInput = [ pkg-config ];
  buildInputs = [
    libxml2
    sqlite
    gmp
  ];

  shardsFile = ./lock/shards.nix;
  crystalBinaries.server.src = "src/ktistec/server.cr";

  doCheck = false;

  meta = with lib; {
    description = "Performant, and portable jq wrapper";
    mainProgram = "oq";
    homepage = "https://blacksmoke16.github.io/oq/";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne ];
    platforms = platforms.unix;
  };
}
