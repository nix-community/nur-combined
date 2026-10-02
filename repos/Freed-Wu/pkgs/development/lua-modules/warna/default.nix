{
  lib,
  luaPackages,
  fetchurl,
  fetchFromGitHub,
}:

with luaPackages;

let
  revision = "2";
in
buildLuarocksPackage rec {
  pname = "warna";
  version = "0.3.5";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/${pname}-${version}-${revision}.rockspec";
      hash = "sha256-GbRCMAKDqlT37WVfN5I1mNEcCjJU8WG6ZWkr9Rq9c24=";
    }).outPath;
  src = fetchFromGitHub {
    owner = "asumbek";
    repo = pname;
    rev = "v${version}-${revision}";
    hash = "sha256-6L2MNVlBwhQC/dqnXIMqQh+U11LqEx0KU3/FOCLySOA=";
  };

  meta = with lib; {
    homepage = "https://github.com/asumbek/warna";
    description = "Terminal text styling library for Lua";
    license = licenses.mit;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.all;
  };
}
