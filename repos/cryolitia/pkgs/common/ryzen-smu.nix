{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, kernel
}:
let

  pname' = "ryzen_smu";
  version' = "0.1.5";

  src' = fetchFromGitHub {
    owner = "Cryolitia";
    repo = pname';
    rev = "ce1aa918efa33ca79998f0f7d467c04d4b07016c";
    hash = "sha256-s9SSmbL6ixWqZUKEhrZdxN4xoWgk+8ClZPoKq2FDAAE=";
  };

  monitor-cpu = stdenv.mkDerivation {
    pname = "monitor-cpu";
    version = version';

    src = src';

    makeFlags = [
      "-C userspace"
    ];

    installPhase = ''
      runHook preInstall

      install userspace/monitor_cpu -Dm755 -t $out/bin

      runHook postInstall
    '';
  };

in
stdenv.mkDerivation {
  pname = pname';
  version = version';

  src = src';

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install ryzen_smu.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/ryzen_smu
    install ${monitor-cpu}/bin/monitor_cpu -Dm755 -t $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/leogx9r/ryzen_smu";
    description = "A Linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "monitor_cpu";
    platforms = platforms.linux;
  };
}
