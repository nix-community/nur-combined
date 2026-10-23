{
  lib,
  telegram-desktop,
  fetchFromGitHub,
  zbar,
  pango,
  tlottie,
  wallet-engine,
}:

telegram-desktop.override {
  pname = "forkgram-desktop";
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "forkgram-desktop-unwrapped";
      version = "7.3.3";

      src = fetchFromGitHub {
        owner = "forkgram";
        repo = "tdesktop";
        tag = "v${finalAttrs.version}";
        fetchSubmodules = true;
        hash = "sha256-TesT9OHMhWRHSVhAsso0ajOVmCVhBDqUJGW9XvOuNHY=";
      };

      buildInputs = previousAttrs.buildInputs ++ [
        zbar
        pango
        tlottie
        wallet-engine
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
        changelog = "https://github.com/forkgram/tdesktop/releases/tag/v${finalAttrs.version}";
        mainProgram = "Forkgram";
      };
    }
  );
}
