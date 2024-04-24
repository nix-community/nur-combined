{ lib
, pkgs
, fetchFromGitHub
, python312Packages
, SDL2
, steamPackages
, steam-run-native
, pkgsCross}:


let 
  truckersmp-cli = python312Packages.buildPythonApplication{

  pname = "truckersmp-cli";
  version = "0.10.1";

  src = fetchFromGitHub {
    repo = "truckersmp-cli";
    owner = "truckersmp-cli";
    rev = "a5fc6df4ac498c1b454a9305db326467b2d0906f";
    sha256 = "sha256-5BA4+937r4+cC9Ceil6ScC6AVtnRqVTlpzBA6vNbatc=";
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

  buildInputs = [ SDL2 steamPackages.steamcmd steamPackages.steam-runtime];

  propagatedBuildInputs = with python312Packages; [ vdf ];

  };
in 
  pkgs.buildFHSEnv {
    pname = "truckersmp-cli";
    version = "0.10.1";
    targetPkgs = pkgs: [ truckersmp-cli ];
    runScript = "truckersmp-cli";

    meta = {
      description = "A simple launcher for TruckersMP to play ATS or ETS2 in multiplayer.";
      homepage = "https://github.com/truckersmp-cli/truckersmp-cli";
      license = lib.licenses.mit;
  };
}