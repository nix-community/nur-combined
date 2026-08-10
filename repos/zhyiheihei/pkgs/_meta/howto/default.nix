{
  writeTextFile,
  lib,
  _meta,
}:
writeTextFile rec {
  name = "00000-howto";
  text = ''
    Use this repository as a flake input or overlay:

    {
      inputs.zhyi-packages.url = "github:zhyiheihei/zhyi-packages";
    }

    Binary cache:

    {
      nix.settings.substituters = [ "${_meta.atticUrl}" ];
      nix.settings.trusted-public-keys = [ "${_meta.atticPublicKey}" ];
    }
  '';
  meta = {
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    description = text;
    homepage = "https://github.com/zhyiheihei/zhyi-packages";
    license = lib.licenses.unlicense;
  };
}
