{
lib,
stdenv,
fetchFromGitHub,
python3,
zlib,
}:
stdenv.mkDerivation rec {
  pname = "open-vmdk";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "vmware";
    repo = "open-vmdk";
    rev = "v${version}";
    hash = "sha256-IFuDjKipM+/73ZEjU8tHV2C016G5uGMUc2EzXi+Q/IU=";
  };

  installFlags = ["PREFIX=$(out)"];

  nativeBuildInputs = [
    python3
    python3.pkgs.wrapPython
    zlib
  ];

  pythonPath = with python3.pkgs; [
    pyyaml
    lxml
  ];

  postPatch = ''
    sed -i '/open-vmdk.conf/d' ova/Makefile
    substituteInPlace ova/mkova.sh \
      --replace 'PREFIX=/usr' "PREFIX=$out" 
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "Open VMDK is an assistant tool for creating Open Virtual Appliance (OVA)";
    homepage = "https://github.com/vmware/open-vmdk";
    license = licenses.apsl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [vifino];
  };
}
