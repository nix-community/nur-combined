{ lib
, fetchFromGitHub
, python3Packages
, SDL2
, steamPackages
, steam-run-native
, pkgsCross
}:

python3Packages.buildPythonApplication rec {
  pname = "truckersmp-cli";
  version = "0.7.2";

  src = fetchFromGitHub {
    repo = pname;
    owner = pname;
    rev = "c96a44a7046498ca83359763681a20d459933bc7";
    sha256 = "sha256-GF76c7js5ytgqiY9G3xPpRqGGlL8o9dOSFr0OryDSaQ=";
  };

  postPatch = ''
    substituteInPlace truckersmp_cli/variables.py --replace \
      'libSDL2-2.0.so.0' '${SDL2}/lib/libSDL2.so'

    substituteInPlace truckersmp_cli/steamcmd.py --replace \
      'steamcmd_path = os.path.join(Dir.steamcmddir, "steamcmd.sh")' \
      'steamcmd_path = "${steamPackages.steamcmd}/bin/steamcmd"'

    substituteInPlace truckersmp_cli/utils.py --replace \
      '"""Download files."""' 'print(files_to_download)'

    substituteInPlace truckersmp_cli/utils.py --replace \
      '[(newpath, dest, md5), ]' \
      '[(newpath, dest["abspath"], md5), ]'
    
    ${pkgsCross.mingwW64.buildPackages.gcc}/bin/x86_64-w64-mingw32-gcc truckersmp-cli.c -o truckersmp_cli/truckersmp-cli.exe
  '';

  nativeBuildInputs = [ pkgsCross.mingwW64.buildPackages.gcc ];

  buildInputs = [ SDL2 steamPackages.steamcmd steamPackages.steam-runtime ];

  propagatedBuildInputs = with python3Packages; [ vdf steam-run-native ];
}
