# TODO make it work with cgroup2, see readme.txt

# TODO patch file paths or use buildFHSEnv

# TODO wrap with bubblewrap

# TODO require platform linux x64

{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  ocl-icd,
  pciutils,
  xorg,
  alsa-lib,
  mesa,
  gtk3,
  nss,
}:

let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in

stdenv.mkDerivation rec {
  pname = "cudominer";
  #inherit (sources) version;
  version = "${sources.version}-broken";

  srcs = (
    let
      fetch = name: hash: fetchurl {
        url = "https://download.cudo.org/tenants/${sources.tenant}/${sources.platform}/release/v${sources.version}/${name}";
        inherit hash;
      };
    in
    lib.mapAttrsToList fetch sources.hashes
  );

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    ocl-icd
    gtk3
    nss
    alsa-lib
    pciutils
    mesa
    xorg.libXxf86vm
    xorg.libxshmfence
  ];

  installPhase = ''
    mkdir -p $out/local
    mv usr/local/cudo-miner $out/local
    mv usr/share $out
    mv etc $out
    mv usr/local/bin $out
    if [ -n "$(find . -type f)" ]; then
      echo "error: failed to install files:"
      find . -type f
      exit 1
    fi
  '';

  meta = with lib; {
    description = "Cryptocurrency Miner";
    mainProgram = "cudominercli";
    homepage = "https://www.cudominer.com/cudo-miner-cryptocurrency-mining-software/";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
