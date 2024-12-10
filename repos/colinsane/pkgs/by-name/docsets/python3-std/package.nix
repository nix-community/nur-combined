{
  doc2dash,
  python3,
  runCommand,
}:
runCommand "docsets-python3-std" {
  preferLocalBuild = true;
  nativeBuildInputs = [ doc2dash ];
} ''
  # doc2dash inherits file permissions from the sources,
  # so we need to copy them here, in order to make them +w, else the build fails EPERM
  cp -R ${python3.doc}/share/doc/* doc
  chmod -R u+w doc

  # `--parser ...` lets me inject my own module that doc2dash loads and delegates docset styling to
  PYTHONPATH=${./.} doc2dash --parser sparse_sphinx_parser.InterSphinxParserLessNoise --index-page library/index.html doc/html

  mkdir -p $out/share/docsets
  cp -R *.docset $out/share/docsets
''
