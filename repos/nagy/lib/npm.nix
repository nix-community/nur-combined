{
  pkgs,
}:

{
  npmWritePackage =
    {
      pname,
      version ? "latest",
    }@args:
    pkgs.runCommandLocal "${pname}-${version}"
      (
        {
          buildInputs = [ pkgs.nodejs ];
          NPM_CONFIG_CACHE = "/tmp";
          NPM_CONFIG_PREFIX = placeholder "out";
        }
        // args
      )
      ''
        npm install --global $pname@$version
        patchShebangs $out
      '';
}
