{ qtbase, go, goModules }:

{
  pname = "protonmail-bridge";

  tags = "pmapi_prod";

  QT_PKG_CONFIG = "true";
  QT_VERSION = qtbase.version;

  nativeBuildInputs = [
    goModules.qt
    qtbase
  ];

  buildPhase = ''
    cp cmd/Desktop-Bridge/main.go .

    ## Enable writable vendor
    GOMODULE=gomodule
    mv vendor $GOMODULE-vendor
    mkdir vendor
    readarray -t files < <(find $GOMODULE-vendor/ -type f | grep -v github.com/therecipe/qt | sed "s/$GOMODULE-//")
    for f in "''${files[@]}"; do
      mkdir -p $(dirname $f)
      cp -s $PWD/$GOMODULE-$f $f
    done
    unset GOMODULE

    ##
    mkdir -p vendor/github.com/therecipe
    cp -r gomodule-vendor/github.com/therecipe/qt vendor/github.com/therecipe/qt
    chmod -R a+w vendor/github.com/therecipe/qt

    # Add vendor to GOPATH because fuck
    mkdir -p $GOPATH
    ln -s $PWD/vendor $GOPATH/src

    qtsetup check
    GOROOT=${go}/share/go qtdeploy "''${buildFlagsArray[@]}" build desktop
  '';

  meta.broken = true;
}
