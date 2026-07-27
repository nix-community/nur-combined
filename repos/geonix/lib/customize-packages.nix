/*
  Function: customizePackages
  Description: Customize Geospatial NIX packages using overrides.nix template
  file.

  Parameters:
  * nixpkgs:            nixpkgs attribute set. Use `inherit nixpkgs;`
  * geopkgs:            geopkgs attribute set. User `inherit geonix;`
  * pythonVersion:      Python version.
                        Example: `python39`. Default: `python3`
  * postgresqlVersion:  PostgreSQL version.
                        Example: `postgresql_12. `Default: `postgresql`
  * overridesFile:      file containing packages overrides definitions.
                        Default: false
*/

{ nixpkgs
, geopkgs
, pythonVersion ? "python3"
, postgresqlVersion ? "postgresql"
, overridesFile ? false
}:

let
  inherit (nixpkgs.lib) mapAttrs';

  customPkgs = import overridesFile {
    nixpkgs = nixpkgs;
    geopkgs = geopkgs;
    pythonVersion = pythonVersion;
    postgresqlVersion = postgresqlVersion;
  };
in
customPkgs

# Python packages
// mapAttrs'
  (name: value: { name = "${pythonVersion}-" + name; value = value; })
  customPkgs.python-packages

# PostgreSQL packages
// mapAttrs'
  (name: value: { name = "${postgresqlVersion}-" + name; value = value; })
  customPkgs.postgresql-packages
