{ pkgs, lib, ... }: {
  npmWritePackage = { pname, version ? "latest" }:
    pkgs.runCommandLocal "${pname}-${version}" {
      inherit pname version;
      dontUnpack = true;
      buildInputs = [ pkgs.nodejs ];
      NPM_CONFIG_CACHE = "/tmp";
      NPM_CONFIG_PREFIX = placeholder "out";
    } ''
      npm install --global $pname@$version
      patchShebangs $out
    '';
}
