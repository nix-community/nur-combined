{
  lib,
  luaPackages,
  fetchurl,
  fetchFromGitHub,
  wakatime-cli,
# pandoc,
# neovim,
# neomutt,
# texlive
}:

with luaPackages;
buildLuarocksPackage rec {
  pname = "prompt-style";
  version = "0.0.8";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/prompt-style-${version}-1.rockspec";
      sha256 = "sha256-ifFcZB+hrTG1rmunLrfozGCo9XLJybVD8S0N+RPYlEc=";
    }).outPath;
  src = fetchFromGitHub {
    owner = "wakatime";
    repo = "prompt-style.lua";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-v+CFOvTFcFLKF6WDdJzD2ZBYfKEKkgQz98w+PI3Bi30=";
  };

  postFixup = ''
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
  buildInputs = [ wakatime-cli ];
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
