{
  lib,
  telegram-desktop,
  fetchFromGitHub,
  zbar,
}:

telegram-desktop.override {
  pname = "forkgram-desktop";
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (old: {
    pname = "forkgram-desktop-unwrapped";
    version = "7.0.7";

    src = fetchFromGitHub {
      owner = "forkgram";
      repo = "tdesktop";
      rev = "v7.0.7";
      fetchSubmodules = true;
      hash = "sha256-rfTSXQ7/erPBpvlNqoZPnyaqBdQF4vZqU5P1r7BqNL0=";
    };

    buildInputs = old.buildInputs ++ [ zbar ];

    postPatch = (old.postPatch or "") + ''
      pushd cmake
      patch -p1 < ../patches/cmake_zbar.patch
      popd
    '';

    meta = old.meta // {
      description = "Forkgram desktop messaging app";
      homepage = "https://github.com/forkgram/tdesktop";
      mainProgram = "Forkgram";
    };
  });
}
