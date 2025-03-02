{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation (finalAttr: {
  pname = "xpad-noone";
  version = "0-unstable-c3d1610";

  src = fetchFromGitHub {
    owner = "medusalix";
    repo = finalAttr.pname;
    rev = "c3d1610";
    hash = "sha256-jDRyvbU9GsnM1ARTuwnoD7ZXlfBxne13UpSKRo7HHSY=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    substituteInPlace Makefile --replace-fail "/lib/modules/\$(shell uname -r)/build" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  '';

  installPhase = ''
    runHook preInstall

    install *.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/xpad-noone

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/medusalix/xpad-noone";
    description = "Xpad driver from the Linux kernel with support for Xbox One controllers removed";
    license = with licenses; [
      gpl2Only
    ];
    maintainers = with maintainers; [ Cryolitia ];
    platforms = [ "x86_64-linux" ];
  };
})
