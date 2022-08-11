{ lib, bundlerApp }:

bundlerApp {
  pname = "rvpacker";
  gemdir = ./.;
  exes = [ "rvpacker" ];

  meta = with lib; {
    description = "A tool to unpack & pack RPGMaker data files into text so they can be version controlled & collaborated on";
    homepage = "https://github.com/Solistra/rvpacker";
    license = licenses.mit;
  };
}
