{
  lib,
  callPackage,
  cutefish-toolkit,
  icu,
  mpv,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-video-player";

  extraBuildInputs = [
    cutefish-toolkit
    icu
    mpv
  ];

  # libmpv is dlopened by SONAME the first time a file is played.
  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [ mpv ]} "$out/bin/cutefish-video-player"
  '';

  meta = {
    description = "Video player for the Cutefish desktop, using libmpv";
    mainProgram = "cutefish-video-player";
  };
}
