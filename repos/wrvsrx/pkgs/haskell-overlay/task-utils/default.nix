{
  mkDerivation,
  aeson,
  base,
  bytestring,
  Chart,
  Chart-cairo,
  containers,
  data-default,
  deepseq,
  directory,
  doclayout,
  fgl,
  filepath,
  graphviz,
  iCalendar,
  lib,
  optparse-applicative,
  parsec,
  pretty-simple,
  process,
  split,
  taskwarrior,
  terminal-size,
  text,
  time,
  transformers,
  unicode-show,
  utf8-string,
  uuid,
  yaml,
  fetchFromGitHub,
}:
mkDerivation {
  pname = "task-utils";
  version = "0-unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "task-utils";
    rev = "bb4ce8f8634f19c31d084e8a232ee62ea79e9cbc";
    hash = "sha256-y/zf2sJSkBb/cLlGnbd5xj1H+3bL0VDnbMY/HIUa0Ak=";
  };
  isLibrary = false;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson
    base
    bytestring
    Chart
    Chart-cairo
    containers
    data-default
    deepseq
    directory
    doclayout
    fgl
    filepath
    graphviz
    iCalendar
    optparse-applicative
    parsec
    pretty-simple
    process
    split
    taskwarrior
    terminal-size
    text
    time
    transformers
    unicode-show
    utf8-string
    uuid
    yaml
  ];
  executableHaskellDepends = [
    aeson
    base
    bytestring
    containers
    directory
    doclayout
    fgl
    graphviz
    optparse-applicative
    parsec
    pretty-simple
    process
    taskwarrior
    terminal-size
    text
    time
    unicode-show
    utf8-string
    uuid
  ];
  doHaddock = false;
  homepage = "https://github.com/wrvsrx/task-utils";
  license = lib.licenses.mit;
  mainProgram = "task-utils";
}
