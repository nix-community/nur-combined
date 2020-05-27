# Helper function to wrap pandoc with a list of filters, creating a new pandoc
# executable that always applies those filters

{ stdenv, makeWrapper, pandoc }:

# A list of paths to executables
filters:

assert builtins.isList filters;
assert builtins.all builtins.isPath filters;

let
  filterFlags =
    builtins.concatStringsSep " "
    (builtins.map (x: "--filter ${x}") filters);
in stdenv.mkDerivation {
  name = "pandoc-with-filters";

  unpackPhase = "true";
  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin/"
    makeWrapper \
      ${pandoc}/bin/pandoc \
      "$out/bin/pandoc" \
      --add-flags "${filterFlags}"
  '';
}
