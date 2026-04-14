{
  sources,
  version,
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  fd,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      dbus-python
      pygobject3
    ]
  );
in
stdenvNoCC.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [ makeWrapper ];

  strictDeps = true;
  __structuredAttrs = true;

  installPhase = ''
    runHook preInstall

    install -D fd-runner-dbus.py $out/share/fd-runner-dbus/fd-runner-dbus.py

    mkdir -p $out/bin
    makeWrapper ${pythonEnv.interpreter} $out/bin/fd-runner-dbus \
      --add-flags $out/share/fd-runner-dbus/fd-runner-dbus.py \
      --prefix PATH : ${lib.makeBinPath [ fd ]}

    install -D org.kde.runners.fd.desktop $out/share/krunner/dbusplugins/org.kde.runners.fd.desktop

    mkdir -p $out/share/dbus-1/services
    cat > $out/share/dbus-1/services/org.kde.runners.fd.service <<EOF
    [D-BUS Service]
    Name=org.kde.runners.fd
    Exec=$out/bin/fd-runner-dbus
    EOF
  '';

  meta = {
    description = "KRunner plugin to search for files using fd";
    homepage = "https://github.com/wangzk/krunner-fd-plugin";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.lgpl3Plus;
  };
}
