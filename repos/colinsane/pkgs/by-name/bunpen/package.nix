{
  dbus,
  hareHook,
  iproute2,
  iptables,
  lib,
  passt,
  procps,
  stdenv,
  systemdMinimal,
  util-linux,
  which,
  xdg-dbus-proxy,
}: stdenv.mkDerivation {
  pname = "bunpen";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    hareHook
    which
  ];

  makeFlags = [
    "PREFIX=${builtins.placeholder "out"}"
    "IP=${lib.getExe' iproute2 "ip"}"
    "IPTABLES=${lib.getExe' iptables "iptables"}"
    "PASTA=${lib.getExe' passt "pasta"}"
    "XDG_DBUS_PROXY=${lib.getExe xdg-dbus-proxy}"
  ];

  nativeCheckInputs = [
    dbus  # for `dbus-daemon`
    iproute2  # for `ip`
    procps  # for `ps`
    systemdMinimal  # for `busctl`
    util-linux  # for `setsid`
    which
  ];

  doCheck = true;

  postPatch = ''
    patchShebangs --build integration_test
  '';

  meta = {
    description = "userspace sandbox helper";
    longDescription = ''
      run any executable in an isolated environment,
      selectively exposing the specific resources (paths, IPC) it needs.
    '';
    mainProgram = "bunpen";
  };
}
