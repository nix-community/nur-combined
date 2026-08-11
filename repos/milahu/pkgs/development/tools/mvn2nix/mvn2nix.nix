# based on src/mvn2nix/default.nix
# avoid external sources: niv, nix-gitignore, nixpkgs
# fix: error: access to URI 'https://github.com/NixOS/nixpkgs/archive/a332da8588aeea4feb9359d23f58d95520899e3c.tar.gz' is forbidden in restricted mode
# avoid overlays

{ lib
, pkgs
, jdk_headless
}:

# create scope to override jdk
lib.makeScope pkgs.newScope (self: with self; rec {

  jdk = jdk_headless;

  mvn2nix = (self.callPackage ./src/mvn2nix/derivation.nix { }) // {
    # fix: error: attribute 'buildMavenRepositoryFromLockFile' missing
    # at pkgs/mwdumper/mwdumper.nix:
    #     mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
    inherit buildMavenRepository buildMavenRepositoryFromLockFile;
  };

  mvn2nix-bootstrap = self.callPackage ./src/mvn2nix/derivation.nix { bootstrap = true; };

  buildMavenRepository =
    (self.callPackage ./src/mvn2nix/maven.nix { }).buildMavenRepository;

  buildMavenRepositoryFromLockFile =
    (self.callPackage ./src/mvn2nix/maven.nix { }).buildMavenRepositoryFromLockFile;

})
