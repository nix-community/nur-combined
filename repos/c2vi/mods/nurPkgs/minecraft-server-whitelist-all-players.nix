{ lib
, python3Packages
, python3
, stdenv
}:

stdenv.mkDerivation {
  pname = "minecraft-server-whitelist-all-players";
  version = "1.0";
  pyproject = false;

  propagatedBuildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      requests
    ]))
  ];


  dontUnpack = true;
  src = ./.;

  installPhase = "install -Dm755 ${./minecraft-server-whitelist-all-players.py} $out/bin/minecraft-server-whitelist-all-players";

  meta = with lib; {
    description = "A small python script to generate a whitelist.json from all players that ever joined the server.";
    longDescription = ''
      A small python script to generate a whitelist.json from the playerdata directory of a minecraft server. It adds all players that were ever on the server to this generated whitelist.json file.
      You need to specify the playerdata directory containing all the players .dat files as the first argument to the script.
    '';
    homepage = "https://github.com/c2vi/nixos/tree/master/mods/nurPkgs";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
