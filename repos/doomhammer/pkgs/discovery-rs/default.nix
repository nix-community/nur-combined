{
  source,
  lib,
  rustPlatform,
  perl,
}:

rustPlatform.buildRustPackage {
  inherit (source)
    pname
    version
    src
    ;

  cargoLock = source.cargoLock."Cargo.lock";

  meta = {
    description = "A cli utility to discover mDNS services on your network.";
    homepage = "https://github.com/JustPretender/discovery-rs";
    license = lib.licenses.mit;
  };
}
