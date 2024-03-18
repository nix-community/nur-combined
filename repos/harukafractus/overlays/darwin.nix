final: prev: {
  firefox-bin = prev.callPackage ../pkgs/firefox { edition = "firefox"; };
  firefox-beta-bin = prev.callPackage ../pkgs/firefox { edition = "firefox-beta";};
  firefox-devedition-bin = prev.callPackage ../pkgs/firefox { edition = "firefox-devedition";};
  firefox-esr-bin = prev.callPackage ../pkgs/firefox { edition = "firefox-esr";};
  firefox-nightly-bin = prev.callPackage ../pkgs/firefox { edition = "firefox-nightly";};
  librewolf = prev.callPackage ../pkgs/librewolf { };
} 