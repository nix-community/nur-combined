{ stdenv, buildFHSUserEnv, symlinkJoin, optpath } :

let
  version = "16b01";
  g16root = "${optpath}/gaussian/g${version}";

  buildEnv = exe: buildFHSUserEnv {
    name = exe;

    targetPkgs = pkgs: with pkgs; [ tcsh ];

    runScript = "${g16root}/${exe}";

    profile = ''
      export GAUSS_EXEDIR=${g16root}/g${version}/
      export GAUSS_SCRDIR=$TMPDIR
      export g16root=${optpath}/gaussian
      source ${g16root}/bsd/g16.profile
    '';
  };

  executables = [ "g16" "formchk" "freqchk" "cubegen" "trajgen" ];


in symlinkJoin {
  name = "gaussian-${version}";
  paths = map (x: buildEnv x) executables;
  meta = with stdenv.lib; {
    description = "Quantum chemistry programm package";
    license = licenses.unfree;
  };
}
