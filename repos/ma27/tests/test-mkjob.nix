{ lib, mkJob, pkgs }:

lib.runTests {

  testMkJob = with lib; {
    expr = let
      job = mkJob {
        channel = "18.09";
        overlays = [];
        supportedSystems = [ "x86_64-linux" ];
        jobset = { mapTestOn, linux, ... }: mapTestOn {
          hello = linux;
        };
      };
    in {
      names = builtins.attrNames job;
      archs = flatten (mapAttrsToList (k: v: builtins.attrNames v) job);
    };

    expected = {
      names = [ "hello" ];
      archs = [ "x86_64-linux" ];
    };
  };

}
