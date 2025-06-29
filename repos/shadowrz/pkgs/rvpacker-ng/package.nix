{ lib, bundlerApp }:

bundlerApp {
  pname = "rvpacker-ng";
  gemdir = ./.;
  exes = [ "rvpacker" ];

  meta = with lib; {
    description = "Pack and unpack any RPG Maker VX Ace data files";
    homepage = "https://gitlab.com/Darkness9724/rvpacker-ng";
    license = licenses.mit;
  };
}
