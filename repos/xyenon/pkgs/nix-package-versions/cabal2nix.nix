{
  mkDerivation,
  aeson,
  async,
  base,
  blaze-html,
  blaze-markup,
  bytestring,
  concurrency,
  containers,
  directory,
  exceptions,
  extra,
  fetchgit,
  filepath,
  hashable,
  hspec,
  hspec-expectations,
  http-client,
  http-types,
  lib,
  mtl,
  optparse-applicative,
  prettyprinter,
  process,
  req,
  skylighting,
  sqlite-simple,
  stm,
  temporary,
  text,
  time,
  timeit,
  unordered-containers,
  wai,
  warp,
}:
mkDerivation {
  pname = "nix-package-versions";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/lazamar/nix-package-versions.git";
    sha256 = "07vk25mqa9624lv74c7dbpz5ay6r7239jhy0sq0951c3mwpf17rk";
    rev = "6cdfa21a11f5e8e7ea8a0736c8ddf7941898c9fe";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson
    async
    base
    bytestring
    concurrency
    containers
    directory
    exceptions
    extra
    filepath
    hashable
    http-client
    http-types
    mtl
    prettyprinter
    process
    req
    sqlite-simple
    stm
    temporary
    text
    time
    timeit
    unordered-containers
  ];
  executableHaskellDepends = [
    base
    blaze-html
    blaze-markup
    bytestring
    containers
    filepath
    http-types
    optparse-applicative
    prettyprinter
    skylighting
    text
    time
    wai
    warp
  ];
  testHaskellDepends = [
    base
    hspec
    hspec-expectations
    temporary
    time
    unordered-containers
  ];
  homepage = "https://github.com/githubuser/nix-package-versions#readme";
  license = lib.licenses.bsd3;
  mainProgram = "nix-package-versions";
  maintainers = [ lib.maintainers.xyenon ];
}
