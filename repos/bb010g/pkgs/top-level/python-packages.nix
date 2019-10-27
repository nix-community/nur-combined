pySelf: pySuper: let inherit (pySelf) callPackage; in

{
  namedList = pySuper.namedList or
    (callPackage ../development/python-modules/namedlist { });

  wpull = callPackage ../development/python-modules/wpull { };
}
