{
  hareHook,
  iproute2,
  iptables,
  lib,
  passt,
  procps,
  stdenv,
  util-linux,
  which,
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
  ];

  nativeCheckInputs = [
    iproute2  # for `ip`
    procps  # for `ps`
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
