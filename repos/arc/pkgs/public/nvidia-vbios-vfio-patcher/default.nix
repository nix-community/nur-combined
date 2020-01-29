{ stdenvNoCC, python3, fetchFromGitHub }: stdenvNoCC.mkDerivation {
  pname = "nvidia-vbios-vfio-patcher";
  version = "2019-02-05";

  src = fetchFromGitHub {
    owner = "Matoking";
    repo = "NVIDIA-vBIOS-VFIO-Patcher";
    rev = "d269523";
    sha256 = "091zj4n8lipf0fl4avhvmjy5dd9y24sgz4lbhzvi8l407qsrq6vs";
  };

  patches = [
    # https://github.com/Matoking/NVIDIA-vBIOS-VFIO-Patcher/pull/11#issuecomment-570853954
    ./rtx.patch
  ];

  buildPhase = "true";
  buildInputs = [ python3 ];

  installPhase = ''
    install -Dm0755 nvidia_vbios_vfio_patcher.py $out/bin/nvidia_vbios_vfio_patcher
  '';
}
