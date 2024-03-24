{ lib, stdenv
, bash
, bubblewrap
, firejail
, landlock-sandboxer
, libcap
, substituteAll
, profileDir ? "/share/sane-sandboxed/profiles"
}:

let
  sane-sandboxed = substituteAll {
    src = ./sane-sandboxed;
    inherit bash bubblewrap firejail libcap;
    landlockSandboxer = landlock-sandboxer;
    firejailProfileDirs = "/run/current-system/sw/etc/firejail /etc/firejail ${firejail}/etc/firejail";
  };
  self = stdenv.mkDerivation {
    pname = "sane-sandboxed";
    version = "0.1";

    src = sane-sandboxed;
    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      substituteAll "$src" sane-sandboxed \
        --replace-fail '@out@' "$out"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -d "$out"
      install -d "$out/bin"
      install -m 755 sane-sandboxed $out/bin/sane-sandboxed
      runHook postInstall
    '';

    passthru = {
      inherit landlock-sandboxer;
      withProfiles = profiles: self.overrideAttrs (base: {
        inherit profiles;
        postInstall = (base.postInstall or "") + ''
          install -d $out/share/sane-sandboxed
          ln -s "${profiles}/${profileDir}" "$out/${profileDir}"
        '';
      });
    };

    meta = {
      description = ''
        helper program to run some other program in a sandbox.
        factoring this out allows:
        1. to abstract over the particular sandbox implementation (bwrap, firejail, ...).
        2. to modify sandbox settings without forcing a rebuild of the sandboxed package.
      '';
      mainProgram = "sane-sandboxed";
    };
  };
in self
