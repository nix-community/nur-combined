{
  lib,
  telegram-desktop,
  fetchFromGitHub,
  zbar,
  pango,
  tlottie,
}:

telegram-desktop.override {
  pname = "forkgram-desktop";
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (finalAttrs: previousAttrs: {
    pname = "forkgram-desktop-unwrapped";
    version = "7.2.10";

    src = fetchFromGitHub {
      owner = "forkgram";
      repo = "tdesktop";
      rev = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-r9DATa06/BqHVRjIkkne/0RNluGN6Jzu/Q5rXiPpLBE=";
    };

    buildInputs = previousAttrs.buildInputs ++ [
      zbar
      pango
      tlottie
    ];

    postPatch = (previousAttrs.postPatch or "") + ''
      pushd cmake
      patch -p1 < ../patches/cmake_zbar.patch
      popd
      sed -i 's/cmark_parser_set_allocation_abort_flag/\/\/cmark_parser_set_allocation_abort_flag/g' Telegram/SourceFiles/iv/markdown/iv_markdown_parse_convert.cpp
    '';

    meta = previousAttrs.meta // {
      description = "Forkgram desktop messaging app";
      homepage = "https://github.com/forkgram/tdesktop";
      mainProgram = "Forkgram";
    };
  });
}
