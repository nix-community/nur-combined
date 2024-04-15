{
  description = "A flake for building my envs";

  inputs.nixpkgs.url = "github:dguibert/nixpkgs/pu";
  inputs.nix.url = "github:dguibert/nix/pu";
  #inputs.nix.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.nix-ccache.url       = "github:dguibert/nix-ccache/pu";
  #inputs.nix-ccache.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  #inputs.nur_dguibert_envs.url= "github:dguibert/nur-packages/pu?dir=envs";
  inputs.nur_dguibert_envs.url = "git+file:///home/dguibert/nur-packages?dir=envs";
  inputs.nur_dguibert_envs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nur_dguibert_envs.inputs.nix.follows = "nix";
  inputs.nur_dguibert_envs.inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-processmgmt.url = "github:svanderburg/nix-processmgmt";
  inputs.nix-processmgmt.flake = false;
  inputs.nix-processmgmt-services.url = "github:svanderburg/nix-processmgmt-services";
  inputs.nix-processmgmt-services.flake = false;

  outputs = {
    self,
    nixpkgs,
    nix,
    #, nix-ccache
    nur_dguibert_envs,
    flake-utils,
    nix-processmgmt,
    nix-processmgmt-services,
    ...
  } @ flakes: let
    nixpkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [
          nix.overlay
          nur_dguibert_envs.overlay
          nur_dguibert_envs.overlays.extra-builtins
          self.overlay
        ];
        config.allowUnfree = true;
      };
  in
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgsFor system;
    in rec {
      legacyPackages = pkgs;

      devShell = pkgs.mkShell {
        name = "nixproc";
        ENVRC = "nixproc";
        buildInputs = with pkgs; [
          pkgs.nix
          jq
          nixproc.common
          nixproc.systemd
          dysnomia
        ];
        shellHook = ''
          export NIX_PATH=nix-processmgmt-services=${nix-processmgmt-services}:nix-processmgmt=${nix-processmgmt}:$NIX_PATH
        '';
      };
    }))
    // rec {
      overlay = final: prev: let
        nixproc = import "${nix-processmgmt}/tools" {
          pkgs = prev;
          system = prev.pkgs.localSystem.system;
        };
      in {
        inherit nixproc;

        dysnomia = prev.callPackage ({
          enableApacheWebApplication ? false,
          enableAxis2WebService ? false,
          enableEjabberdDump ? false,
          enableMySQLDatabase ? false,
          enablePostgreSQLDatabase ? false,
          enableTomcatWebApplication ? false,
          enableMongoDatabase ? false,
          enableSubversionRepository ? false,
          enableInfluxDatabase ? false,
          enableSupervisordProgram ? false,
          enableSystemdUnit ? false,
          enableDockerContainer ? false,
          enableS6RCService ? false,
          catalinaBaseDir ? "/var/tomcat",
          jobTemplate ? "systemd",
          enableLegacy ? false,
        }:
          prev.stdenv.mkDerivation {
            name = "dysnomia";
            version = "20210302";
            src = prev.fetchFromGitHub {
              owner = "svanderburg";
              repo = "dysnomia";
              rev = "506a9ac14cfc0f6dae1a08405b8d05deceef9bb6";
              sha256 = "sha256-AZQRvxcmPckZ9eQUImhwItr820yLsPTatC2l9qRNdZE=";
            };

            preConfigure = ''
              ./bootstrap
            '';

            configureFlags =
              [
                (
                  if enableApacheWebApplication
                  then "--with-apache"
                  else "--without-apache"
                )
                (
                  if enableAxis2WebService
                  then "--with-axis2"
                  else "--without-axis2"
                )
                (
                  if enableEjabberdDump
                  then "--with-ejabberd"
                  else "--without-ejabberd"
                )
                (
                  if enableMySQLDatabase
                  then "--with-mysql"
                  else "--without-mysql"
                )
                (
                  if enablePostgreSQLDatabase
                  then "--with-postgresql"
                  else "--without-postgresql"
                )
                (
                  if enableMongoDatabase
                  then "--with-mongodb"
                  else "--without-mongodb"
                )
                (
                  if enableTomcatWebApplication
                  then "--with-tomcat=${catalinaBaseDir}"
                  else "--without-tomcat"
                )
                (
                  if enableSubversionRepository
                  then "--with-subversion"
                  else "--without-subversion"
                )
                (
                  if enableInfluxDatabase
                  then "--with-influxdb"
                  else "--without-influxdb"
                )
                (
                  if enableSupervisordProgram
                  then "--with-supervisord"
                  else "--without-supervisord"
                )
                (
                  if enableSystemdUnit
                  then "--with-systemd"
                  else "--without-systemd"
                )
                (
                  if prev.stdenv.isDarwin
                  then "--with-launchd"
                  else "--without-launchd"
                )
                (
                  if enableDockerContainer
                  then "--with-docker"
                  else "--without-docker"
                )
                (
                  if enableS6RCService
                  then "--with-s6-rc"
                  else "--without-s6-rc"
                )
                "--with-job-template=${jobTemplate}"
              ]
              ++ prev.lib.optional enableLegacy "--enable-legacy";

            buildInputs = with prev;
              [getopt netcat autoconf automake help2man]
              ++ prev.lib.optional enableEjabberdDump prev.ejabberd
              ++ prev.lib.optional enableMySQLDatabase prev.mysql
              ++ prev.lib.optional enablePostgreSQLDatabase prev.postgresql
              ++ prev.lib.optional enableMongoDatabase prev.mongodb
              ++ prev.lib.optional enableMongoDatabase prev.mongodb-tools
              ++ prev.lib.optional enableSubversionRepository prev.subversion
              ++ prev.lib.optional enableInfluxDatabase prev.influxdb
              ++ prev.lib.optional enableSystemdUnit prev.systemd
              ++ prev.lib.optional enableSupervisordProgram prev.pythonPackages.supervisor
              ++ prev.lib.optional enableDockerContainer prev.docker
              ++ prev.lib.optional enableS6RCService prev.s6-rc;

            meta = {
              description = "Automated deployment of mutable components and services for Disnix";
              license = prev.lib.licenses.mit;
              maintainers = [prev.lib.maintainers.sander];
              platforms = prev.lib.platforms.unix;
            };
          }) {};
      };
    };
}
