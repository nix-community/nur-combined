{
  stdenv,
  fetchFromGitHub,
  perl,
  tcl,
  lua,
  luafilesystem,
  luaposix,
  rsync,
  procps,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  name = "Lmod-${version}";

  version = "7.8.21";
  src = fetchFromGitHub {
    owner = "TACC";
    repo = "Lmod";
    rev = "refs/tags/${version}";
    sha256 = "sha256-J/5dqFS4jzH7cOyyCCqZLtBCtwLvjagJ4FuQ7ROwLpM=";
  };

  buildInputs = [lua tcl perl rsync procps makeWrapper];
  propagatedBuildInputs = [luaposix luafilesystem];
  preConfigure = ''makeFlags="PREFIX=$out" '';

  LUA_PATH = "${luaposix}/share/lua/5.2/?.lua;;";
  LUA_CPATH = "${luafilesystem}/lib/lua/5.2/?.so;${luaposix}/lib/?.so;;";

  postInstall = ''
    ls $out/lmod/${version}/libexec/lmod
    wrapProgram $out/lmod/${version}/libexec/lmod --prefix LUA_PATH : "$LUA_PATH" \
      --prefix LUA_CPATH : "$LUA_CPATH"

  '';

  meta = {
    description = "Tool for configuring environments";
  };
}
