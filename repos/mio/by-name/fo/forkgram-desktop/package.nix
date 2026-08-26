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
    version = "7.1.1";

    src = fetchFromGitHub {
      owner = "forkgram";
      repo = "tdesktop";
      rev = "v7.1.1";
      fetchSubmodules = true;
      hash = "sha256-Xl3PKEScggz0Po8K6oZ9J7aEVW3hA2LuxVPI3yLE4MU=";
    };

    buildInputs = old.buildInputs ++ [ zbar ];

    postPatch = (old.postPatch or "") + ''
      pushd cmake
      patch -p1 < ../patches/cmake_zbar.patch
      popd
      sed -i 's/cmark_parser_set_allocation_abort_flag/\/\/cmark_parser_set_allocation_abort_flag/g' Telegram/SourceFiles/iv/markdown/iv_markdown_parse_convert.cpp
    '';

    meta = old.meta // {
      description = "Forkgram desktop messaging app";
      homepage = "https://github.com/forkgram/tdesktop";
      mainProgram = "Forkgram";
    };
  });
}
