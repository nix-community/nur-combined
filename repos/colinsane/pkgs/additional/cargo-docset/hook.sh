postBuildHooks+=(_cargoDocset)
postInstallHooks+=(_cargoDocsetInstall)

_cargoDocset() {
  cargo docset
}

_cargoDocsetInstall() {
  mkdir -p $out/share/docset
  cp -R target/docset/* $out/share/docset/
}
