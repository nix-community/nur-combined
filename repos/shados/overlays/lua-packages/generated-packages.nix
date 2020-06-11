
/* generated-packages.nix is an auto-generated file -- DO NOT EDIT!
Regenerate it with:
nixpkgs$ /nix/store/q36ls71b177lyndydzjazfjpdw19gp5n-nixos-20.09pre228622.029a5de0839/nixos/maintainers/scripts/update-luarocks-packages generated-packages.nix

These packages are manually refined in lua-overrides.nix
*/
{ self, stdenv, fetchurl, fetchgit, pkgs, ... } @ args:
self: super:
with self;
{

cmark = buildLuarocksPackage {
  pname = "cmark";
  version = "0.29.0-1";

  src = fetchurl {
    url    = mirror://luarocks/cmark-0.29.0-1.src.rock;
    sha256 = "04a039jmyk6scl1frkqf38qwnb095c43rr0ygz3qcjaq9vb7kdg2";
  };

  meta = with stdenv.lib; {
    homepage = "https://github.com/jgm/cmark-lua";
    description = "Lua wrapper for libcmark, CommonMark Markdown parsing\
      and rendering library";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "BSD2";
  };
};
copas = buildLuarocksPackage {
  pname = "copas";
  version = "2.0.2-1";

  src = fetchurl {
    url    = mirror://luarocks/copas-2.0.2-1.src.rock;
    sha256 = "01viw2d3aishkkfak3mf33whwr04jcckkckm25ap3g1k8r7yvvgg";
  };
  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua luasocket coxpcall ];

  meta = with stdenv.lib; {
    homepage = "http://www.keplerproject.org/copas/";
    description = "Coroutine Oriented Portable Asynchronous Services";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
etlua = buildLuarocksPackage {
  pname = "etlua";
  version = "1.3.0-1";

  src = fetchurl {
    url    = mirror://luarocks/etlua-1.3.0-1.src.rock;
    sha256 = "029710wg0viwf57f97sqwjqrllcbj8a4igj31rljkiisyf36y6ka";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/leafo/etlua";
    description = "Embedded templates for Lua";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
inotify = buildLuarocksPackage {
  pname = "inotify";
  version = "0.5-1";

  src = fetchurl {
    url    = mirror://luarocks/inotify-0.5-1.src.rock;
    sha256 = "0dml7r9hy40psmsjvqsp3jcn4qjjga1xhy1l0wg7wb8kgdvvar4i";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "http://hoelz.ro/projects/linotify";
    description = "Inotify bindings for Lua";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
lcmark = buildLuarocksPackage {
  pname = "lcmark";
  version = "0.29.0-5";

  src = fetchurl {
    url    = mirror://luarocks/lcmark-0.29.0-5.src.rock;
    sha256 = "1hcmrfkikgg41p9dmwbk286pgdfw41r6a1h13mbpjd1sf0yh5dk9";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua cmark yaml lpeg optparse ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/jgm/lcmark";
    description = "A command-line CommonMark converter with flexible\
      features, and a lua module that exposes these features.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "BSD2";
  };
};
ldbus = buildLuarocksPackage {
  pname = "ldbus";
  version = "scm-0";

  knownRockspec = (fetchurl {
    url    = mirror://luarocks/ldbus-scm-0.rockspec;
    sha256 = "1yhkw5y8h1qf44vx31934k042cmnc7zcv2k0pv0g27wsmlxrlznx";
  }).outPath;

  src = fetchgit ( removeAttrs (builtins.fromJSON ''{
  "url": "git://github.com/daurnimator/ldbus.git",
  "rev": "9e176fe851006037a643610e6d8f3a8e597d4073",
  "date": "2019-08-16T14:26:05+10:00",
  "path": "/nix/store/gg4zldd6kx048d6p65b9cimg3arma8yh-ldbus",
  "sha256": "06wcz4i5b7kphqbry274q3ivnsh331rxiyf7n4qk3zx2kvarq08s",
  "fetchSubmodules": true,
  "deepClone": false,
  "leaveDotGit": false
}
 '') ["date"]) ;

  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/daurnimator/ldbus";
    description = "A Lua library to access dbus.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
loadkit = buildLuarocksPackage {
  pname = "loadkit";
  version = "1.1.0-1";

  src = fetchurl {
    url    = mirror://luarocks/loadkit-1.1.0-1.src.rock;
    sha256 = "1jxwzsjdhiahv6qdkl076h8xf0lmypibh71bz6slqckqiaq1qqva";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/leafo/loadkit";
    description = "Loadkit allows you to load arbitrary files within the Lua package path";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
lua-ev = buildLuarocksPackage {
  pname = "lua-ev";
  version = "v1.5-1";

  knownRockspec = (fetchurl {
    url    = mirror://luarocks/lua-ev-v1.5-1.rockspec;
    sha256 = "0yi9gfran0d0qvjaypf066ihmz3wksw1s9q99hpaw798gnpg60rr";
  }).outPath;

  src = fetchgit ( removeAttrs (builtins.fromJSON ''{
  "url": "git://github.com/brimworks/lua-ev",
  "rev": "efe00a8dea89231099f550af6c8e0f6b42e7a145",
  "date": "2020-05-05T09:08:31-07:00",
  "path": "/nix/store/xk1k37000j3dkf2xknwrvnxgcaphx717-lua-ev",
  "sha256": "0kib7fn46ss7xb6aiwgcmwywmd4qlvvdhvpvpj7brkfk4iq6cakf",
  "fetchSubmodules": true,
  "deepClone": false,
  "leaveDotGit": false
}
 '') ["date"]) ;

  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "http://github.com/brimworks/lua-ev";
    description = "Lua integration with libev";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
lua-testmore = buildLuarocksPackage {
  pname = "lua-testmore";
  version = "0.3.5-2";

  src = fetchurl {
    url    = mirror://luarocks/lua-testmore-0.3.5-2.src.rock;
    sha256 = "1ibisc86hwh2l0za0hqh97dv80p3rg05hdmws3yi6fv824v10xa8";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "http://fperrad.frama.io/lua-TestMore/";
    description = "an Unit Testing Framework";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
luagraph = buildLuarocksPackage {
  pname = "luagraph";
  version = "2.0.1-1";

  src = fetchurl {
    url    = mirror://luarocks/luagraph-2.0.1-1.src.rock;
    sha256 = "16az0bw2w7w019nwbj5nf6zkw7vc5idvrh63dvynx1446n6wl813";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "http://github.com/hleuwer/luagraph";
    description = "A binding to the graphviz graph library";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
lunix = buildLuarocksPackage {
  pname = "lunix";
  version = "20170920-1";

  src = fetchurl {
    url    = mirror://luarocks/lunix-20170920-1.src.rock;
    sha256 = "1mjy3sprpskykjwsb3xzsy1add78hjjrwcfhx4c4x25fjjrhfh2a";
  };

  meta = with stdenv.lib; {
    homepage = "http://25thandclement.com/~william/projects/lunix.html";
    description = "Lua Unix Module.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
lub = buildLuarocksPackage {
  pname = "lub";
  version = "1.1.0-1";

  src = fetchurl {
    url    = mirror://luarocks/lub-1.1.0-1.src.rock;
    sha256 = "01ngd6ckbvp7cn11pwp651wjdk7mqnqx99asif5lvairb08hwhpz";
  };
  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua luafilesystem ];

  meta = with stdenv.lib; {
    homepage = "http://doc.lubyk.org/lub.html";
    description = "Lubyk base module.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
mobdebug = buildLuarocksPackage {
  pname = "mobdebug";
  version = "0.70-1";

  knownRockspec = (fetchurl {
    url    = mirror://luarocks/mobdebug-0.70-1.rockspec;
    sha256 = "1jmhvjv2j5jnwa4nhxhc97gallhdbic4f9gz04bnn6id529pv6ph";
  }).outPath;

  src = fetchgit ( removeAttrs (builtins.fromJSON ''{
  "url": "git://github.com/pkulchenko/MobDebug.git",
  "rev": "7acfc6f9af339e486ae2390e66185367bbf6a0cd",
  "date": "2018-07-19T21:05:56-07:00",
  "path": "/nix/store/ah5sr2689rd28h3pjvq7w92qhc8z4pvk-MobDebug",
  "sha256": "0hsq9micb7ic84f8v575drz49vv7w05pc9yrq4i57gyag820p2kl",
  "fetchSubmodules": true,
  "deepClone": false,
  "leaveDotGit": false
}
 '') ["date"]) ;

  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua luasocket ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkulchenko/MobDebug";
    description = "MobDebug is a remote debugger for the Lua programming language";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
moonpick = buildLuarocksPackage {
  pname = "moonpick";
  version = "0.8-1";

  src = fetchurl {
    url    = mirror://luarocks/moonpick-0.8-1.src.rock;
    sha256 = "1w4pdlsn5sy72n6aprf2rkqck9drf3hbhhg63wi94ycv2jlj7xzq";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua moonscript ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/nilnor/moonpick";
    description = "An alternative moonscript linter.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
moonscript = buildLuarocksPackage {
  pname = "moonscript";
  version = "0.5.0-1";

  src = fetchurl {
    url    = mirror://luarocks/moonscript-0.5.0-1.src.rock;
    sha256 = "09vv3ayzg94bjnzv5fw50r683ma0x3lb7sym297145zig9aqb9q9";
  };
  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua lpeg alt-getopt luafilesystem ];

  meta = with stdenv.lib; {
    homepage = "http://moonscript.org";
    description = "A programmer friendly language that compiles to Lua";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
moor = buildLuarocksPackage {
  pname = "moor";
  version = "v5.0-1";

  src = fetchurl {
    url    = mirror://luarocks/moor-v5.0-1.src.rock;
    sha256 = "1g0dhl4lv6bnrsy7yxwgvy0h60lqnaicmrzi53f3hycmrgglaqh6";
  };
  propagatedBuildInputs = [ moonscript inspect linenoise ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/Nymphium/moor";
    description = "MoonScript REPL";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
optparse = buildLuarocksPackage {
  pname = "optparse";
  version = "1.4-1";

  src = fetchurl {
    url    = mirror://luarocks/optparse-1.4-1.src.rock;
    sha256 = "06pad2r1a8n6g5g3ik3ikp16x68cwif57cxajydgwc6s5b6alrib";
  };
  disabled = (luaOlder "5.1") || (luaAtLeast "5.5");
  propagatedBuildInputs = [ lua ];

  meta = with stdenv.lib; {
    homepage = "http://gvvaughan.github.io/optparse";
    description = "Parse and process command-line options";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
pegdebug = buildLuarocksPackage {
  pname = "pegdebug";
  version = "0.41-1";

  knownRockspec = (fetchurl {
    url    = mirror://luarocks/pegdebug-0.41-1.rockspec;
    sha256 = "0jj4jal0bdbs2zmfzbbzxfmcb8bhqv5dnfai824m16h8sdh6cms2";
  }).outPath;

  src = fetchgit ( removeAttrs (builtins.fromJSON ''{
  "url": "git://github.com/pkulchenko/PegDebug.git",
  "rev": "4f72126520da725687cde0aaecdd5b1f7b3701d5",
  "date": "2019-09-19T09:25:45-07:00",
  "path": "/nix/store/kjwdszj21xwl97wcc7rm5g0x8m4v1hax-PegDebug",
  "sha256": "1gm4l71l9rcg71gz8k8i52lvn6qnhbvhb798g5v1kb8k99a3lz0a",
  "fetchSubmodules": true,
  "deepClone": false,
  "leaveDotGit": false
}
 '') ["date"]) ;

  disabled = (luaOlder "5.1");
  propagatedBuildInputs = [ lua lpeg ];

  meta = with stdenv.lib; {
    homepage = "http://github.com/pkulchenko/PegDebug";
    description = "PegDebug is a trace debugger for LPeg rules and captures.";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT/X11";
  };
};
spawn = buildLuarocksPackage {
  pname = "spawn";
  version = "0.1-0";

  src = fetchurl {
    url    = mirror://luarocks/spawn-0.1-0.src.rock;
    sha256 = "1wrpc4cwkg9piafjmgv5rppdq2gix6gvy5bkphig8s8946nlsy5l";
  };
  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua lunix ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/daurnimator/lua-spawn";
    description = "A lua library to spawn programs";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};
yaml = buildLuarocksPackage {
  pname = "yaml";
  version = "1.1.2-1";

  src = fetchurl {
    url    = mirror://luarocks/yaml-1.1.2-1.src.rock;
    sha256 = "0zl364inmcdk3592sbyswvp71gb7wnbw2asmf91r8yc8kysfjqqg";
  };
  disabled = (luaOlder "5.1") || (luaAtLeast "5.4");
  propagatedBuildInputs = [ lua lub ];

  meta = with stdenv.lib; {
    homepage = "http://doc.lubyk.org/yaml.html";
    description = "Very fast yaml parser based on libYAML by Kirill Simonov";
    maintainers = with maintainers; [ arobyn ];
    license.fullName = "MIT";
  };
};

}
/* GENERATED */

