{
  lib,
  luaPackages,
  fetchurl,
  fetchFromGitHub,
# pandoc,
# neovim,
# neomutt,
# texlive
}:

with luaPackages;
buildLuarocksPackage rec {
  pname = "prompt-style";
  version = "0.0.3";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/prompt-style-${version}-1.rockspec";
      sha256 = "sha256-QObeNZlIz50XUJWvuswRHQ0m66brAfLwFf8kNJW+bK4=";
    }).outPath;
  src = fetchFromGitHub {
    owner = "wakatime";
    repo = "prompt-style.lua";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-E2xCYa+WBqv6jVq925dTsWlYBJQM3WbLKzjU1NdO2S0=";
  };

  postFixup =
    ''
      rm $out/bin/*
    ''
    + (
      let
        lua_version = builtins.elemAt (lib.split "\\." luaPackages.lua.version) 2;
      in
      if lua_version == "3" then
        ''
          install -D bin/{texluap,neomuttp} -t $out/bin
        ''
      # sed -i -e's=/usr/bin/env -S neomutt=${neomutt}/bin/neomutt=g' $out/bin/neomuttp
      # sed -i -e's=/usr/bin/env -S luatex=${texlive}/bin/luatex=g' $out/bin/texluap
      else if lua_version == "4" then
        ''
          install -D bin/pandocp -t $out/bin
        ''
      # sed -i -e's=/usr/bin/env -S pandoc=${pandoc}/bin/pandoc=g' $out/bin/pandocp
      else if lua_version == "2" then
        ''''
      else
        ''
          install -D bin/{texluajitp,nvimp} -t $out/bin
        ''
      # sed -i -e's=/usr/bin/env -S nvim=${neovim}/bin/nvim=g' $out/bin/nvimp
      # sed -i -e's=/usr/bin/env -S luajittex=${texlive}/bin/luajittex=g' $out/bin/texluajitp
    );

  disabled = luaOlder "5.1";
  propagatedBuildInputs = [
    ansicolors
    luaprompt
    luafilesystem
  ];
  meta = with lib; {
    homepage = "https://github.com/wakatime/prompt-style.lua";
    description = "Lua plugin for powerlevel10k style prompt and WakaTime time tracking";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
