{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  lxml,
}:

buildPythonApplication rec {
  pname = "ebutt2srt";
  version = "unstable-2025-09-18";

  src = fetchFromGitHub {
    owner = "Licmeth";
    repo = "EbuTT2srt";
    # https://github.com/Licmeth/EbuTT2srt/pull/1
    rev = "7d0680f5f7701a3c71f7739b3322826815ad069b";
    hash = "sha256-x5gOkn5nGZibopyjZ2GuagH9NiyZA4oKnQvtlqe7jQ8=";
  };

  dependencies = [
    lxml
  ];

  meta = {
    description = "Convert EBUTT subtitles to SRT subtitles";
    homepage = "https://github.com/Licmeth/EbuTT2srt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ebutt2srt";
    platforms = lib.platforms.all;
  };
}
