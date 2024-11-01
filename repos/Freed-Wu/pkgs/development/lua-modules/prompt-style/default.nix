{ luaPackages, fetchurl, fetchFromGitHub }:

with luaPackages;
buildLuarocksPackage {
  pname = "prompt-style";
  version = "0.0.1-0";
  knownRockspec = (fetchurl {
    url = "mirror://luarocks/prompt-style-0.0.1-0.rockspec";
    sha256 = "sha256-LUeGkyLlfjEPOrvQl8z1Y0GROiglheGIsUi6/I7y4a0=";
  }).outPath;
  src = fetchFromGitHub {
    owner = "wakatime";
    repo = "prompt-style.lua";
    rev = "0.0.1";
    fetchSubmodules = false;
    sha256 = "sha256-ejVM+cWAAsxREFxA6e3ZICqkREEZXaZp8u5RSysLNck=";
  };

  postFixup = ''
    install -D bin/* -t $out/bin
  '';

  disabled = luaOlder "5.1";
  propagatedBuildInputs = [ ansicolors luaprompt luafilesystem ];
  meta = {
    homepage = "https://github.com/wakatime/prompt-style.lua";
    description = "Lua plugin for powerlevel10k style prompt and WakaTime time tracking";
    license.fullName = "GPL-3.0";
  };
}
