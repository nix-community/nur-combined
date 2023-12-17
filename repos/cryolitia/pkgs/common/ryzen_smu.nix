{ stdenv
, fetchFromGitLab
, fetchurl
, kernel
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ryzen_smu";
  version = "0.1.5";

  src = fetchFromGitLab {
    owner = "leogx9r";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-n4uWikGg0Kcki/TvV4BiRO3/VE5M6/KopPncj5RQFAQ=";
  };

  patches = [
    # Add Rembrandt support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/20

    # Add Phoenix support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/24
    (fetchurl {
      url = "https://gitlab.com/leogx9r/ryzen_smu/-/merge_requests/12.patch";
      hash = "sha256-kO5jQ6EfsX+fxiF1EXEWCezRe5QEa/f/oLnjglWZ2jQ=";
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

    runHook postInstall
  '';

})
