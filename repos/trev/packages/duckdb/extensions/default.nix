{ callPackage }:

{
  avro = callPackage ./avro.nix { };
  aws = callPackage ./aws.nix { };
  azure = callPackage ./azure.nix { };
  ducklake = callPackage ./ducklake.nix { };
  encodings = callPackage ./encodings.nix { };
  excel = callPackage ./excel.nix { };
  fts = callPackage ./fts.nix { };
  httpfs = callPackage ./httpfs.nix { };
  iceberg = callPackage ./iceberg.nix { };
  inet = callPackage ./inet.nix { };
  mysql-scanner = callPackage ./mysql-scanner.nix { };
  odbc-scanner = callPackage ./odbc-scanner.nix { };
  postgres-scanner = callPackage ./postgres-scanner.nix { };
  quack = callPackage ./quack.nix { };
  spatial = callPackage ./spatial.nix { };
  sqlite-scanner = callPackage ./sqlite-scanner.nix { };
  sqlsmith = callPackage ./sqlsmith.nix { };
  vss = callPackage ./vss.nix { };
}
