{
  pkgs,
  self,
}:

let
  script = ../../libs/mkAppImage/extra-files.sh;
  apprun = pkgs.writeShellScriptBin "AppRun" "true";
  runtime = pkgs.writeShellScriptBin "runtime" "true";

  mkAppImage = import ../../libs/mkAppImage {
    inherit (pkgs) lib stdenvNoCC;
    stdenv = pkgs.stdenvNoCC;
    pkgsStatic.callPackage =
      path: _: if builtins.baseNameOf path == "bwrap-apprun" then apprun else runtime;
    squashfsTools = runtime;
    writeClosure = _: pkgs.writeText "mkappimage-closure" "";
  };

  fixture = pkgs.runCommand "mkappimage-extra-files-fixture" { } ''
    mkdir -p \
      $out/bin \
      $out/share/applications \
      $out/share/mkappimage \
      $out/share/mkappimage-icons \
      $out/share/icons/hicolor/256x256/apps \
      $out/share/icons/hicolor/128x128/apps

    touch $out/bin/example
    chmod +x $out/bin/example

    cat > $out/share/mkappimage/example.desktop <<EOF
    [Desktop Entry]
    Name=Example
    Exec=$out/bin/example --flag
    Icon=example
    EOF
    ln -s ../mkappimage/example.desktop $out/share/applications/example.desktop

    cat > $out/share/applications/unrelated.desktop <<EOF
    [Desktop Entry]
    Name=Unrelated
    Exec=unrelated
    EOF

    printf '%s\n' high-priority > $out/share/mkappimage-icons/example-256.png
    printf '%s\n' lower-priority > $out/share/mkappimage-icons/example-128.png
    ln -s ../../../../mkappimage-icons/example-256.png $out/share/icons/hicolor/256x256/apps/example.png
    ln -s ../../../../mkappimage-icons/example-128.png $out/share/icons/hicolor/128x128/apps/example.png
  '';

  fixturePackage = fixture // {
    pname = "example";
    version = "1";
    stdenv = pkgs.stdenvNoCC;
    meta.mainProgram = "example";
  };

  appImage = mkAppImage {
    src = fixturePackage;
  };

  noDesktop = pkgs.runCommand "mkappimage-no-desktop-fixture" { } ''
    mkdir -p $out/bin
    touch $out/bin/example
    chmod +x $out/bin/example
  '';

  multipleDesktops = pkgs.runCommand "mkappimage-multiple-desktops-fixture" { } ''
    mkdir -p $out/bin $out/share/applications
    touch $out/bin/example
    chmod +x $out/bin/example

    for name in first second; do
      cat > $out/share/applications/$name.desktop <<EOF
    [Desktop Entry]
    Name=$name
    Exec=$out/bin/example
    EOF
    done
  '';
in
{
  mkAppImage-entrypoint =
    assert pkgs.lib.hasInfix
      (builtins.unsafeDiscardStringContext "${script} ${pkgs.lib.getExe fixturePackage}")
      (builtins.unsafeDiscardStringContext appImage.buildPhase);
    pkgs.runCommand "mkAppImage-entrypoint" { } "touch $out";

  mkAppImage-extra-files = pkgs.runCommand "mkAppImage-extra-files" { } ''
    ${pkgs.runtimeShell} ${script} ${fixture}/bin/example

    test -f extras/example.desktop
    test ! -L extras/example.desktop
    test ! -e extras/unrelated.desktop
    test -f extras/usr/share/icons/hicolor/256x256/apps/example.png
    test ! -L extras/usr/share/icons/hicolor/256x256/apps/example.png
    cmp extras/.DirIcon ${fixture}/share/mkappimage-icons/example-256.png

    touch $out
  '';

  mkAppImage-invalid-store-path = pkgs.runCommand "mkAppImage-invalid-store-path" { } ''
    if ${pkgs.runtimeShell} ${script} /tmp/example 2>error; then
      echo "expected a non-store entrypoint to fail" >&2
      exit 1
    fi

    grep --fixed-strings "entrypoint '/tmp/example' is not in the nix store" error
    touch $out
  '';

  mkAppImage-no-desktop = pkgs.runCommand "mkAppImage-no-desktop" { } ''
    if ${pkgs.runtimeShell} ${script} ${noDesktop}/bin/example 2>error; then
      echo "expected a missing desktop entry to fail" >&2
      exit 1
    fi

    grep --fixed-strings "no .desktop found; giving up" error
    touch $out
  '';

  mkAppImage-multiple-desktops = pkgs.runCommand "mkAppImage-multiple-desktops" { } ''
    if ${pkgs.runtimeShell} ${script} ${multipleDesktops}/bin/example 2>error; then
      echo "expected multiple desktop entries to fail" >&2
      exit 1
    fi

    grep --fixed-strings "multiple .desktop entries found; giving up" error
    touch $out
  '';
}
