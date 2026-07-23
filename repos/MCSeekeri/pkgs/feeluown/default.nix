{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6Packages,
  mpv,
  makeWrapper,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "feeluown";
  version = "5.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "feeluown";
    repo = "FeelUOwn";
    rev = "v${finalAttrs.version}";
    hash = "sha256-glFTT8xQGlhgIg9VDE2Y5mSEzZmqDOmB5jENZwVZ4FI=";
  };

  nativeBuildInputs = (with python3Packages; [ setuptools ]) ++ [ makeWrapper ];

  propagatedBuildInputs = (with python3Packages; [ pyqt6 janus requests qasync tomlkit packaging pydantic mutagen fluent-runtime ]) ++ (with qt6Packages; [ pyotherside ]) ++ [ mpv ];


  postFixup = let
    libPath = lib.makeLibraryPath [ mpv ];
  in ''
    wrapProgram $out/bin/feeluown --prefix LD_LIBRARY_PATH : ${libPath}
  '';

  preBuild = ''
    export HOME=$TMPDIR
  '';

  meta = {
    description = "NetEase Music player for Linux";
    homepage = "https://github.com/feeluown/FeelUOwn";
    changelog = "https://github.com/feeluown/FeelUOwn/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "feeluown";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
