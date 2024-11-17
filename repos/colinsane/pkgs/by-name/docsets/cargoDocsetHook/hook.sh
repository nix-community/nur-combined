postBuildHooks+=(_cargoDocset)
postInstallHooks+=(_cargoDocsetInstall)

_cargoDocset() {
  cargo docset ${cargoDocsetFlags:-}
}

_cargoDocsetInstall() {
  mkdir -p $out/share/docsets
  cp -R target/docset/* $out/share/docsets/
}
