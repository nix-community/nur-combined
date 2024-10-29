{
  lib,
  fetchFromGitHub,
  crystal,
  libxml2,
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
    ln -s ${./ktistec.lock} shard.lock
  '';
  format = "shards";

  nativeBuildInput = [ pkg-config ];
  buildInputs = [
    libxml2
    sqlite
    gmp
  ];

  shardsFile = ./shards.nix;
  crystalBinaries.server.src = "src/ktistec/server.cr";

  postInstall = ''
    mkdir -p $out/app
    cp -r etc $out/app/etc
    cp -r public $out/app/public
  '';
  doCheck = false;

  meta = with lib; {
    description = "Single user ActivityPub server";
    mainProgram = "ktistec";
    homepage = "https://github.com/toddsundsted/ktistec";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ oluceps ];
    platforms = platforms.unix;
  };
}
