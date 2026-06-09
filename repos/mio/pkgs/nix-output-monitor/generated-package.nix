# This file has been autogenerate with cabal2nix.
# Update via ./update.sh
{
  mkDerivation,
  ansi-terminal,
  async,
  attoparsec,
  base,
  bytestring,
  cassava,
  containers,
  directory,
  extra,
  fetchzip,
  filelock,
  filepath,
  hermes-json,
  HUnit,
  lib,
  nix-derivation,
  optics,
  random,
  relude,
  safe,
  safe-exceptions,
  stm,
  streamly-core,
  strict,
  terminal-size,
  text,
  time,
  transformers,
  typed-process,
  unix,
  word8,
}:
mkDerivation {
  pname = "nix-output-monitor";
  version = "2.1.8";
  src = fetchzip {
    url = "https://code.maralorn.de/maralorn/nix-output-monitor/archive/388f56120f655a9cf4512e697b2c2afa06fe7434.tar.gz";
    sha256 = "18b1d66c57rw22n12zvr8w9mvbynlvig8r2msx81p73cb9a8zpyw";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    extra
    filelock
    filepath
    hermes-json
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    word8
  ];
  executableHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    extra
    filelock
    filepath
    hermes-json
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    typed-process
    unix
    word8
  ];
  testHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    extra
    filelock
    filepath
    hermes-json
    HUnit
    nix-derivation
    optics
    random
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    typed-process
    word8
  ];
  homepage = "https://code.maralorn.de/maralorn/nix-output-monitor";
  description = "Processes output of Nix commands to show helpful and pretty information";
  license = lib.licensesSpdx."EUPL-1.2";
  mainProgram = "nom";
  maintainers = [ lib.maintainers.maralorn ];
}
