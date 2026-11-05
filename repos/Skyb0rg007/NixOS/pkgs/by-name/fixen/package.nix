{
  lib,
  fetchFromGitHub,
  haskell,
  nix-update-script,
}:
let
  # MultilineStrings requires GHC >= 9.12
  haskellPackages = haskell.packages.ghc912;
in
haskellPackages.mkDerivation rec {
  pname = "fixen";
  version = "26.7";

  src = fetchFromGitHub {
    owner = "plilab";
    repo = "fixen";
    tag = version;
    hash = "sha256-uFjPDYNmRQ0DaCLlpvQbBPk8i6/XfT0AQUeVyGSJynM=";
  };

  # Map.filterKeys was added in containers 0.8
  postPatch = ''
    substituteInPlace src/Fixen/SymbolSolver/{Priorities,Validation}.hs \
      --replace-fail "Map.filterKeys" "(\p -> Map.filterWithKey (\k _ -> p k))"
  '';

  # Upstream pins exact dependency versions
  jailbreak = true;

  isLibrary = false;
  isExecutable = true;

  # Keep GHC out of the runtime closure
  enableSharedExecutables = false;
  enableLibraryProfiling = false;
  doHaddock = false;
  postFixup = ''
    rm -rf $out/lib $out/nix-support $out/share/doc
  '';
  disallowGhcReference = true;

  libraryHaskellDepends = with haskellPackages; [
    array
    base
    base-unicode-symbols
    containers
    data-default
    directory
    dlist
    filepath
    hashable
    lens
    megaparsec
    mtl
    parser-combinators
    prettyprinter
    prettyprinter-ansi-terminal
    text
    transformers
    unordered-containers
    wcwidth
  ];

  executableHaskellDepends = with haskellPackages; [
    base
    containers
    directory
    filepath
    megaparsec
    mtl
    optparse-applicative
    parser-combinators
    prettyprinter
    prettyprinter-ansi-terminal
    text
    transformers
  ];

  passthru.updateScript = nix-update-script { };

  description = "Domain-specific language for work-queue algorithms";
  homepage = "https://fixen-lang.org/";
  license = lib.licenses.mit;
  maintainers = [ lib.maintainers.skyesoss ];
  mainProgram = "fixen";
}
