{ stdenv, lib, fetchFromGitLab, kernel, kmod }:

stdenv.mkDerivation rec {
  name = "microsoft-ergonomic-keyboard-${version}-${kernel.version}";
  version = "1.0";

  src = fetchFromGitLab {
    owner = "arnekeller";
    repo = "microsoft-ergonomic-keyboard";
    rev = "f23be31228daa7ce62f019acb8f7a127e5bd846c";
    sha256 = "0knjkx4bqjxqsm2wly3dj96w1ljzhxavs26a3m65bb04phcb2n8w";
  };

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  meta = with lib; {
    description = "A kernel module to fix the office key on MS ergonomic keyboards";
    homepage = "https://gitlab.com/arnekeller/microsoft-ergonomic-keyboard";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.fliegendewurst ];
    platforms = platforms.linux;
  };
}

