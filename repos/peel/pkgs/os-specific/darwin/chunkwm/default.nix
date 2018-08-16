{ newScope, callPackage, stdenv, fetchFromGitHub, Carbon, Cocoa, ApplicationServices, imagemagick }:

let
  repoName = "chunkwm";
  repoV = "0.4.5";
  repoSha = "1ywcpzg3p0hsri7jn5f963ciswqnwbhg9niglhms6zyw9rm0wwzw";

  self = chunkwm;
  callPackage = newScope self;

  chunkwm = with self; {
      core = callPackage ./core.nix {
        cfg = { name = "core";
            version = repoV;
            sha256 = repoSha;
          };
        inherit Carbon Cocoa;
      };

      border = callPackage ./plugin.nix {
        cfg = { name = "border";
            version = repoV;
            sha256 = repoSha;
          };
        inherit Carbon Cocoa ApplicationServices;
      };

      ffm = callPackage ./plugin.nix {
        cfg = { name = "ffm";
            version = repoV;
            sha256 = repoSha;
          };
      inherit Carbon Cocoa ApplicationServices;
      };

      tiling = callPackage ./plugin.nix {
        cfg = { name = "tiling";
            version = repoV;
            sha256 = repoSha;
          };
        inherit Carbon Cocoa ApplicationServices;
      };

      purify = callPackage ./plugin.nix {
        cfg = { name = "purify";
            version = repoV;
            sha256 = repoSha;
          };
        inherit Carbon Cocoa ApplicationServices;
      };
  }; in chunkwm
