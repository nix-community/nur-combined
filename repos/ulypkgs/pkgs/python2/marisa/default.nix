{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  marisa,
  swig,
  isPy3k,
}:

buildPythonPackage (finalAttrs: {
  pname = "marisa";
  version = "1.3.40";

  disabled = isPy3k;

  src = fetchFromGitHub {
    owner = "s-yata";
    repo = "marisa-trie";
    rev = "8dba9850b89d7828ebf33b8ab84df2b54d31260b";
    hash = "sha256-YyTS/jCfdPIt3WpJazZh9OIx+ps6c8ci7XSU+Z5Ld14=";
  };

  nativeBuildInputs = [
    swig
    marisa
  ];
  buildInputs = [ marisa ];

  sourceRoot = "${finalAttrs.src.name}/bindings/python";

  meta = with lib; {
    description = "Python binding for marisa package (do not confuse with marisa-trie python bindings)";
    homepage = "https://github.com/s-yata/marisa-trie";
    license = with licenses; [
      bsd2
      lgpl2
    ];
    maintainers = with maintainers; [ vanzef ];
  };
})
