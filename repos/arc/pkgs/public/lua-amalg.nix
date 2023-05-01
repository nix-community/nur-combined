{ lua, fetchurl, fetchFromGitHub }: lua.pkgs.buildLuarocksPackage rec {
  pname = "lua-amalg";
  version = "0.8";
  rockspecVersion = "scm-0";
  knownRockspec = fetchurl {
    url = "https://github.com/siffiejoe/lua-amalg/raw/v${version}/amalg-${rockspecVersion}.rockspec";
    sha256 = "sha256-GcQE5ZTDjFWdj3XTbUEOWJbyOyZnDXZlyzR8PM29iwc=";
  };
  src = fetchFromGitHub {
    owner = "siffiejoe";
    repo = pname;
    rev = "v${version}";
    sha256 = "1a569hrras5wm4gw5hr2i5hz899bwihz1hb31gfnd9z4dsi8wymb";
  };
  meta = { };
}
