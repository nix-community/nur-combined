{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeBinaryWrapper,
  gnused,
  rffmpeg_config ? "/etc/rffmpeg/rffmpeg.yml",
}:

python3Packages.buildPythonApplication rec {
  pname = "rffmpeg";
  version = "v20251103";
  src = fetchFromGitHub {
    owner = "joshuaboniface";
    repo = "rffmpeg";
    rev = "f54ac843c7c8a157562e7ce37aaebbc5cb41354e";
    sha256 = "sha256-UI//X2L6sGWVllfNrRzHrlF4yG+83eldXYVBMrgQqiM=";
  };
  nativeBuildInputs = [
    makeBinaryWrapper
    gnused
  ];
  pyproject = false;
  dependencies = [
    python3Packages.click
    python3Packages.pyyaml
    python3Packages.subprocess4
    python3Packages.psycopg2
  ];
  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 rffmpeg $out/bin
    mkdir -p $out/share/rffmpeg
    install -Dm644 rffmpeg.yml.sample $out/share/rffmpeg/rffmpeg.yml.sample
    wrapProgram $out/bin/rffmpeg \
     --set-default RFFMPEG_CONFIG ${rffmpeg_config}
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dependencies}
     ln -s $out/bin/rffmpeg $out/bin/ffmpeg
     ln -s $out/bin/rffmpeg $out/bin/ffprobe
    runHook postInstall
  '';
  meta = {
    description = "rffmpeg: remote SSH FFmpeg wrapper tool";
    homepage = "https://github.com/joshuaboniface/rffmpeg";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
}
