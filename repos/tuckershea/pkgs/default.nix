{
  pkgs
}:
{
  get-authkey = pkgs.callPackage ./get-authkey { };
  linux-bench = pkgs.callPackage ./linux-bench { };
  mailrise = pkgs.callPackage ./mailrise { };

  chrome-extensions = import ./chrome-extensions { inherit pkgs; };
  firefox-extensions = import ./firefox-extensions { inherit pkgs; };
}

