{ lib
, stdenv
, fetchFromGitHub
, python3
, zlib
}:
stdenv.mkDerivation rec {
  pname = "open-vmdk";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "vmware";
    repo = "open-vmdk";
    rev = "v${version}";
    hash = "sha256-sxsTX6Au9YW233pkQ//g1y3412tLyDqmLX8sT3wNf2k=";
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
    --replace 'PREFIX=/usr' "PREFIX=$out" \
    --replace 'vmdk-convert' "$out/bin/vmdk-convert"
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "Assistant tool for creating Open Virtual Appliance (OVA)";
    homepage = "https://github.com/vmware/open-vmdk";
    license = licenses.apsl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ vifino ];
  };
}
