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
    version = "7.0.9";

    src = fetchFromGitHub {
      owner = "forkgram";
      repo = "tdesktop";
      rev = "v7.0.9";
      fetchSubmodules = true;
      hash = "sha256-eqywFL7WWOV577STfepGx8l0bKpspigddSvsrJ48A0Q=";
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
