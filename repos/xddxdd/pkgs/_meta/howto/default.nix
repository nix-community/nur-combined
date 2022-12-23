{ writeTextFile
, lib
, _meta
, ...
}:

writeTextFile rec {
  name = "00000-howto";
  text = ''
    This NUR has a binary cache. Use the following settings to access it:

    nix.settings.substituters = [ "${_meta.url}" ];
    nix.settings.trusted-public-keys = [ "${_meta.publicKey}" ];

    Or, use variables from this repository in case I change them:

    nix.settings.substituters = [ nur.repos.xddxdd._meta.url ];
    nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.publicKey ];
  '';
  meta = {
    description = text;
    homepage = "https://github.com/xddxdd/nur-packages";
    license = lib.licenses.unlicense;
  };
}
