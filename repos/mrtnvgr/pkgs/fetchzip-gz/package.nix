{ fetchzip, zstd, ... }:
{ ... } @ args:
fetchzip ({
  nativeBuildInputs = [ zstd ];
} // args)
