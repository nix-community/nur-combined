{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, kernel
}:
let
  pname' = "ryzen-smu";
  version' = "0.1.5";

  src' = fetchFromGitLab {
    owner = "leogx9r";
    repo = pname';
    rev = "v${version'}";
    hash = "sha256-n4uWikGg0Kcki/TvV4BiRO3/VE5M6/KopPncj5RQFAQ=";
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

  patches = [
    # Add Rembrandt support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/20
    (fetchurl {
      url = "https://gitlab.com/moson-mo/ryzen_smu/-/commit/cdfe728b3299400b7cd17d31bdfe5bedab6b1cc9.patch";
      hash = "sha256-XD+Xz3/1MwoXUocqQK13Uiy5oOa1VRN1qRLmFmq4CEQ=";
    })

    # Add Phoenix support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/24
    (fetchurl {
      url = "https://gitlab.com/moson-mo/ryzen_smu/-/commit/58feed93d8e55f27b0e6b7f66e0be165cf52fc23.patch";
      hash = "sha256-y9f/COdP0CDs7Yt6w+J47c+1oJXOYkNvOPe7SaUX2Xw=";
    })
  ];

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
