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

    install -D org.kde.runners.fd.service $out/share/dbus-1/services/org.kde.runners.fd.service
    install -D org.kde.runners.fd.desktop $out/share/krunner/dbusplugins/org.kde.runners.fd.desktop

    substituteInPlace $out/share/dbus-1/services/org.kde.runners.fd.service \
      --replace 'ExecStart=%h/.local/share/krunner/dbusplugins/fd-runner-dbus.py' "ExecStart=$out/bin/fd-runner-dbus"
  '';
}
