{ lua, fetchFromGitHub, lib }: lua.pkgs.buildLuarocksPackage rec {
  pname = "lua-amalg";
  version = "0.8";
  src = fetchFromGitHub {
    owner = "siffiejoe";
    repo = pname;
    rev = "v${version}";
    sha256 = "1a569hrras5wm4gw5hr2i5hz899bwihz1hb31gfnd9z4dsi8wymb";
  };
  rockspecFilename = "amalg-scm-0.rockspec";
}
