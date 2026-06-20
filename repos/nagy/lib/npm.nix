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
          env = {
            NPM_CONFIG_CACHE = "/tmp";
          };
        }
        // args
      )
      ''
        npm install --global --prefix "$out" $pname@$version
        patchShebangs "$out"
      '';
}
