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
  patchPhase = ''
    runHook prePatch
    #apply patch from https://github.com/joshuaboniface/rffmpeg/issues/94
    sed -i 's/cmd_name\s*=.*/cmd_name = os.path.basename(all_args[0])/' rffmpeg
    runHook postPatch
  '';
  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 rffmpeg $out/bin
    install -Dm755 rffmpeg $out/bin/ffmpeg
    install -Dm755 rffmpeg $out/bin/ffprobe
    wrapProgram $out/bin/rffmpeg \
     --set-default RFFMPEG_CONFIG ${rffmpeg_config} \
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dependencies} 
    #independetnly wrap ffmpeg and ffprobe so their executable name is not rffmpeg.
    # this avoids this issue: https://github.com/joshuaboniface/rffmpeg/issues/94
    wrapProgram $out/bin/ffmpeg \
     --set-default RFFMPEG_CONFIG ${rffmpeg_config} \
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dependencies} 
    wrapProgram $out/bin/ffprobe \
     --set-default RFFMPEG_CONFIG ${rffmpeg_config} \
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dependencies} 
    runHook postInstall
  '';
  meta = {
    description = "rffmpeg: remote SSH FFmpeg wrapper tool";
    homepage = "https://github.com/joshuaboniface/rffmpeg";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
}
