{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "neocities";
  gemdir = ./.;
  exes = [ "neocities" ];

  passthru.updateScript = bundlerUpdateScript "neocities";

  meta = with lib; {
    description = "A CLI and library for using the Neocities API.";
    longDescription = ''
      A CLI and library for using the Neocities API.
      Makes it easy to quickly upload, push, delete, and list your Neocities site.
    '';
    homepage = "https://neocities.org/cli";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
