{ lib, fetchurl, linkFarm }:
with lib; rec {
  # Create a maven environment from the output of the mvn2nix command
  # the resulting store path can be used as the a .m2 repository for subsequent
  # maven invocations.
  # ex.
  # 	mvn package --offline -Dmaven.repo.local=${repository}
  #
  # @param dependencies: A attrset of dependencies to build the repository
  buildMavenRepository = { dependencies }:
    let
      dependenciesAsDrv = (forEach (attrValues dependencies) (dependency: {
        drv = fetchurl {
          url = dependency.url;
          sha256 = dependency.sha256;
        };
        layout = dependency.layout;
      }));
    in linkFarm "mvn2nix-repository" (forEach dependenciesAsDrv (dependency: {
      name = dependency.layout;
      path = dependency.drv;
    }));

  # Create a maven environment from the output of the mvn2nix command
  # the resulting store path can be used as the a .m2 repository for subsequent
  # maven invocations.
  # ex.
  # 	mvn package --offline -Dmaven.repo.local=${repository}
  #
  # @param file: A path to a file containing the JSON output of running mvn2nix
  buildMavenRepositoryFromLockFile = { file }:
    let
      dependencies = (builtins.fromJSON (builtins.readFile file)).dependencies;
    in buildMavenRepository { inherit dependencies; };
}
