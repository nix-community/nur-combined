{
  runCommand,
  copyparty-showcase-videos,
  vaculib,
}:
runCommand "share-root" { } ''
  mkdir -p "$out"
  cd "$out"
  ln -s ${vaculib.path ./root-readme.md} readme.md
  cp ${copyparty-showcase-videos}/* .
''
