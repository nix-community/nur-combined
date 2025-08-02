{
  lib,
  stdenv,
  fetchFromBitbucket,
  fuse2,
  boost,
  icu,
  libzip,
  pandoc,
  pkg-config,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fuse-zip";
  version = "0.7.2";

  src = fetchFromBitbucket {
    owner = "agalanin";
    repo = "fuse-zip";
    rev = "3715770db5dc34b5035ec9904ca091aeeb473af8";
    hash = "sha256-X0l6NwFrKdL0Ywy75RtXn7/3rXePeiozfUVUYbR3Ejs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pandoc
    pkg-config
  ];

  buildInputs = [
    boost
    fuse2.dev
    icu
    libzip
  ];
  #buildPhase = "ls -al ${fuse3}/";
  makeFlags = [ "CXXFLAGS=-I${fuse2.dev}/include/fuse3" ]; # "prefix=$out" ];
  #CXXFLAGS = "-I${pkgs.fuse3}/include/fuse3";

  doInstallCheck = true;
  installPhase = ''
    make prefix=$out install
  '';
#  passthru = {
#    updateScript = gitUpdater { rev-prefix = "v"; };
#  };
  postInstallPhase = "ls -al";
  meta = {
    description = "FUSE file system for ZIP archives";
    homepage = "https://bitbucket.org/agalanin/fuse-zip";
    changelog = "https://bitbucket.org/agalanin/fuse-zip/releases/tag/v${finalAttrs.version}";
    longDescription = ''
      fuse-zip is a tool allowing to open, explore and extract ZIP archives.
    '';
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "fuse-zip";
  };
})
