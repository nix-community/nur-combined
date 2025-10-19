/*
  pkgs/development/lua-modules/generated-packages.nix is an auto-generated file -- DO NOT EDIT!
  Regenerate it with: nix run nixpkgs#luarocks-packages-updater
  You can customize the generated packages in pkgs/development/lua-modules/overrides.nix
*/

{
  stdenv,
  lib,
  fetchurl,
  fetchgit,
  callPackage,
  ...
}:
final: prev: {
  cmark = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
    }:
    buildLuarocksPackage {
      pname = "cmark";
      version = "0.31.1-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/cmark-0.31.1-1.rockspec";
          sha256 = "00wdbvx3gmh7f08d2a5kvpa687rc922n5zgzxxqrip3xhll9hzwm";
        }).outPath;
      src = fetchFromGitHub {
        owner = "jgm";
        repo = "cmark-lua";
        rev = "0.31.1";
        hash = "sha256-elI+BYPTlFezkoWLjJyPBsAt2Pq2DRe/+YPmtG27ABY=";
      };

      meta = {
        homepage = "https://github.com/jgm/cmark-lua";
        description = "Lua wrapper for libcmark, CommonMark Markdown parsing\
      and rendering library";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "BSD2";
      };
    }
  ) { };

  copas = callPackage (
    {
      binaryheap,
      buildLuarocksPackage,
      coxpcall,
      fetchFromGitHub,
      fetchurl,
      luaAtLeast,
      luaOlder,
      luasocket,
      timerwheel,
    }:
    buildLuarocksPackage {
      pname = "copas";
      version = "4.7.1-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/copas-4.7.1-1.rockspec";
          sha256 = "1jfhqiqk3l4bx1h9v2ss4p07r8mhc01llf7vnjw0c7hpfqpc3s1r";
        }).outPath;
      src = fetchFromGitHub {
        owner = "lunarmodules";
        repo = "copas";
        rev = "4.7.1";
        hash = "sha256-eW3dUXpAaP8TrymjyxQPA35klIAYaYanhcOSOrXq0u8=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";
      propagatedBuildInputs = [
        binaryheap
        coxpcall
        luasocket
        timerwheel
      ];

      meta = {
        homepage = "https://github.com/lunarmodules/copas";
        description = "Coroutine Oriented Portable Asynchronous Services";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  etlua = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "etlua";
      version = "1.3.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/etlua-1.3.0-1.rockspec";
          sha256 = "1g98ibp7n2p4js39din2balncjnxxdbaq6msw92z072s2cccx9cf";
        }).outPath;
      src = fetchFromGitHub {
        owner = "leafo";
        repo = "etlua";
        rev = "v1.3.0";
        hash = "sha256-CVCNeivP6tefUMseoZjiO5wMYBEPNWMy2+0KnmEIuT0=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/leafo/etlua";
        description = "Embedded templates for Lua";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  inotify = callPackage (
    {
      buildLuarocksPackage,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "inotify";
      version = "0.5-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/inotify-0.5-1.rockspec";
          sha256 = "0mwzzhhlwpk7gsbvv23ln486ay27z3l849nga2mh3vli6dc1l0m2";
        }).outPath;
      src = fetchurl {
        url = "https://github.com/hoelzro/linotify/archive/0.5.tar.gz";
        sha256 = "0f73fh1gqjs6vvaii1r2y2266vbicyi18z9sj62plfa3c3qhbl11";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "http://hoelz.ro/projects/linotify";
        description = "Inotify bindings for Lua";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  jsonschema = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      lrexlib-pcre,
      net-url,
    }:
    buildLuarocksPackage {
      pname = "jsonschema";
      version = "0.9.9-0";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/jsonschema-0.9.9-0.rockspec";
          sha256 = "1mzlnplcxfv08md0z6hbvsj0bz9ag4q3vlkxxna5g70rxaaja8pc";
        }).outPath;
      src = fetchFromGitHub {
        owner = "iresty";
        repo = "jsonschema";
        rev = "v0.9.9";
        hash = "sha256-BRb65w5q4UL7pCId/gXpN/2ROfczIekFWQ8n2/oP2Qk=";
      };

      propagatedBuildInputs = [
        lrexlib-pcre
        net-url
      ];

      meta = {
        homepage = "https://github.com/iresty/jsonschema";
        description = "JSON Schema data validator";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "Apache License 2.0";
      };
    }
  ) { };

  lcmark = callPackage (
    {
      buildLuarocksPackage,
      cmark,
      fetchFromGitHub,
      fetchurl,
      lpeg,
      luaOlder,
      optparse,
    }:
    buildLuarocksPackage {
      pname = "lcmark";
      version = "0.30.2-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lcmark-0.30.2-1.rockspec";
          sha256 = "11lrw0jfyci3j4hysn5zw2anjcgdgapkagr5q4a07921yqyi7cx9";
        }).outPath;
      src = fetchFromGitHub {
        owner = "jgm";
        repo = "lcmark";
        rev = "0.30.2-1";
        hash = "sha256-Sgv2eX+Zy0eDOV5Yx9kiWGRASQJ+hWH9s9YRsX4rElE=";
      };

      disabled = luaOlder "5.1";
      propagatedBuildInputs = [
        cmark
        lpeg
        optparse
      ];

      meta = {
        homepage = "https://github.com/jgm/lcmark";
        description = "A command-line CommonMark converter with flexible\
      features, and a lua module that exposes these features.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "BSD2";
      };
    }
  ) { };

  loadkit = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "loadkit";
      version = "1.1.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/loadkit-1.1.0-1.rockspec";
          sha256 = "08fx0xh90r2zvjlfjkyrnw2p95xk1a0qgvlnq4siwdb2mm6fq12l";
        }).outPath;
      src = fetchFromGitHub {
        owner = "leafo";
        repo = "loadkit";
        rev = "v1.1.0";
        hash = "sha256-fw+aoP9+yDpme4qXupE07cV1QGZjb2aU7IOHapG+ihU=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/leafo/loadkit";
        description = "Loadkit allows you to load arbitrary files within the Lua package path";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  lrexlib-pcre = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lrexlib-pcre";
      version = "2.9.2-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lrexlib-pcre-2.9.2-1.rockspec";
          sha256 = "1214ssm6apgprryqvijjjn82ikb27ylq94yijqf7qjyiy6pz7dc1";
        }).outPath;
      src = fetchFromGitHub {
        owner = "rrthomas";
        repo = "lrexlib";
        rev = "rel-2-9-2";
        hash = "sha256-DzNDve+xeKb+kAcW+o7GK/RsoDhaDAVAWAhgjISCyZc=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/rrthomas/lrexlib";
        description = "Regular expression library binding (PCRE flavour).";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  lua-ev = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-ev";
      version = "v1.5-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lua-ev-v1.5-1.rockspec";
          sha256 = "0yi9gfran0d0qvjaypf066ihmz3wksw1s9q99hpaw798gnpg60rr";
        }).outPath;
      src = fetchFromGitHub {
        owner = "brimworks";
        repo = "lua-ev";
        rev = "v1.5";
        hash = "sha256-y7vsdVxgydCU2roZ0eMDLJXV1BwC7MnjvH10E85QzUI=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "http://github.com/brimworks/lua-ev";
        description = "Lua integration with libev";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  lua-filesize = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-filesize";
      version = "0.1.1-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lua-filesize-0.1.1-1.rockspec";
          sha256 = "17k0vin1ckbfv8cw58zr4y410879dvmv8i838m6y2w7vwryxjygl";
        }).outPath;
      src = fetchFromGitHub {
        owner = "starius";
        repo = "lua-filesize";
        rev = "0.1.1";
        hash = "sha256-R0fQOmPTE5a8e8iq8YriE1IEhbXoiNHcj10aOGBJUoI=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/starius/lua-filesize";
        description = "Generate a human readable string describing the file size";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  lua-testmore = callPackage (
    {
      buildLuarocksPackage,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "lua-testmore";
      version = "0.3.7-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lua-testmore-0.3.7-1.rockspec";
          sha256 = "1lklaiyxji8fqrm4i3nyp3cgp43xqa0i6ym7hndh2r9fy975lx77";
        }).outPath;
      src = fetchurl {
        url = "https://framagit.org/fperrad/lua-TestMore/raw/releases/lua-testmore-0.3.7.tar.gz";
        sha256 = "1xr41jzxl6qy2kb19l3q8n95gq2zl08zm0h7c91q68wl4p2n1fvk";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://fperrad.frama.io/lua-TestMore/";
        description = "an Unit Testing Framework";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  luachild = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "luachild";
      version = "0.1-2";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/luachild-0.1-2.rockspec";
          sha256 = "08s1bqyzhmixrylnm9rll1336bgg8sln7yf3yrzzgabg5flw3bpr";
        }).outPath;
      src = fetchFromGitHub {
        owner = "pocomane";
        repo = "luachild";
        rev = "abebff21860f6101bb9a274fb9fef5dfda6d3a2a";
        hash = "sha256-lIm4jhDyvCrj3dD3LJlFeBa36lLNxS2/SqsS8G8HGso=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/pocomane/luachild";
        description = "Spawn sub-processes and communicate with them through pipes.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  lub = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaAtLeast,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "lub";
      version = "1.1.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lub-1.1.0-1.rockspec";
          sha256 = "1gkb79jsxx3kxd7n2gkvycfmysg3zxb1qyjhwzfdqn9yq2s39rp8";
        }).outPath;
      src = fetchFromGitHub {
        owner = "lubyk";
        repo = "lub";
        rev = "REL-1.1.0";
        hash = "sha256-hinFRPFzVC+XXEFyPi0rPQ4IPiIneIEJ54dcoPq9DPA=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";
      propagatedBuildInputs = [ luafilesystem ];

      meta = {
        homepage = "http://doc.lubyk.org/lub.html";
        description = "Lubyk base module.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  lunix = callPackage (
    { buildLuarocksPackage, fetchurl }:
    buildLuarocksPackage {
      pname = "lunix";
      version = "20220331-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/lunix-20220331-1.rockspec";
          sha256 = "17lc2kfmz3r1vr2cicgjcz8achvfps943390axl8fbgylp5jlfm8";
        }).outPath;
      src = fetchurl {
        url = "https://github.com/wahern/lunix/archive/rel-20220331.tar.gz";
        sha256 = "02rznnbf4a1pd261rpi537bim7v91h1f1kwid1pmnsf8ivqci743";
      };

      meta = {
        homepage = "http://25thandclement.com/~william/projects/lunix.html";
        description = "Lua Unix Module.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  mobdebug = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaAtLeast,
      luaOlder,
      luasocket,
    }:
    buildLuarocksPackage {
      pname = "mobdebug";
      version = "0.80-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/mobdebug-0.80-1.rockspec";
          sha256 = "1y9id20v02fa26f6nl4fym8cy0fwj72y48pry4j5m6q3fjr6f6qp";
        }).outPath;
      src = fetchFromGitHub {
        owner = "pkulchenko";
        repo = "MobDebug";
        rev = "0.80";
        hash = "sha256-Z3OoDXK5t1MQUHx8Muvp9Fl43yqDgxnWBuAQxEUYwrk=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";
      propagatedBuildInputs = [ luasocket ];

      meta = {
        homepage = "https://github.com/pkulchenko/MobDebug";
        description = "MobDebug is a remote debugger for the Lua programming language";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  moonpick = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
      moonscript,
    }:
    buildLuarocksPackage {
      pname = "moonpick";
      version = "0.8-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/moonpick-0.8-1.rockspec";
          sha256 = "1y3xgp9alvc4rhcf871dk4877x0nxr3m7g6344dxr004j34gi0kf";
        }).outPath;
      src = fetchFromGitHub {
        owner = "nilnor";
        repo = "moonpick";
        rev = "v0.8";
        hash = "sha256-R3NAFu/cyko2k4k/9z9ttiuk7By33nH8tsX+0tnOyoY=";
      };

      disabled = luaOlder "5.1";
      propagatedBuildInputs = [ moonscript ];

      meta = {
        homepage = "https://github.com/nilnor/moonpick";
        description = "An alternative moonscript linter.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  moonscript = callPackage (
    {
      alt-getopt,
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      lpeg,
      luaOlder,
      luafilesystem,
    }:
    buildLuarocksPackage {
      pname = "moonscript";
      version = "0.5.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/moonscript-0.5.0-1.rockspec";
          sha256 = "06ykvmzndkcmbwn85a4l1cl8v8jw38g0isdyhwwbgv0m5a306j6d";
        }).outPath;
      src = fetchFromGitHub {
        owner = "leafo";
        repo = "moonscript";
        rev = "v0.5.0";
        hash = "sha256-zZFZPrR7vyKbLuxxOKd32XqQ8q5Zyx9UiVIUFFnspi8=";
      };

      disabled = luaOlder "5.1";
      propagatedBuildInputs = [
        alt-getopt
        lpeg
        luafilesystem
      ];

      meta = {
        homepage = "http://moonscript.org";
        description = "A programmer friendly language that compiles to Lua";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  moor = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      inspect,
      linenoise,
      moonscript,
    }:
    buildLuarocksPackage {
      pname = "moor";
      version = "v5.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/moor-v5.0-1.rockspec";
          sha256 = "0hmmqz0p56m6aaqkck0g5cfnfmyqlmf3kwj46p8m0kxlnm2davhv";
        }).outPath;
      src = fetchFromGitHub {
        owner = "nymphium";
        repo = "moor";
        rev = "v5.0";
        hash = "sha256-cuc0cyTuWixjPeh3ko4ykS/iEjKnBXVEA5nQA6j1nlQ=";
      };

      propagatedBuildInputs = [
        inspect
        linenoise
        moonscript
      ];

      meta = {
        homepage = "https://github.com/Nymphium/moor";
        description = "MoonScript REPL";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  net-url = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "net-url";
      version = "1.1-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/net-url-1.1-1.rockspec";
          sha256 = "0jwwmgr7ppdkxgzk0k0c530r9sac8463nxwl1yz25sbck10zr50i";
        }).outPath;
      src = fetchFromGitHub {
        owner = "golgote";
        repo = "neturl";
        rev = "v1.1-1";
        hash = "sha256-OWw5S82Qztal30FWoap2j7BIws3IpnZHQ/X2ETT/9UA=";
      };

      disabled = luaOlder "5.1";

      meta = {
        homepage = "https://github.com/golgote/neturl";
        description = "URL and Query string parser, builder, normalizer for Lua.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  optparse = callPackage (
    {
      buildLuarocksPackage,
      fetchurl,
      fetchzip,
      luaAtLeast,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "optparse";
      version = "1.5-2";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/optparse-1.5-2.rockspec";
          sha256 = "12hijk3wrhr6cc173qisgagd7sfdnbrfxyi7ksq4wcdrcazly0j8";
        }).outPath;
      src = fetchzip {
        url = "http://github.com/gvvaughan/optparse/archive/v1.5.zip";
        sha256 = "1kkpx21f4cqldlvwp9n5r5vmqi341absvxcidc7wd48ragfm1byq";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.5";

      meta = {
        homepage = "http://gvvaughan.github.io/optparse";
        description = "Parse and process command-line options";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  pegdebug = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      lpeg,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "pegdebug";
      version = "0.41-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/pegdebug-0.41-1.rockspec";
          sha256 = "0jj4jal0bdbs2zmfzbbzxfmcb8bhqv5dnfai824m16h8sdh6cms2";
        }).outPath;
      src = fetchFromGitHub {
        owner = "pkulchenko";
        repo = "PegDebug";
        rev = "0.41";
        hash = "sha256-Cnw6VEoTrRl2eSidBfeCFhu7qSgRTfRfOI/lRMOhpL4=";
      };

      disabled = luaOlder "5.1";
      propagatedBuildInputs = [ lpeg ];

      meta = {
        homepage = "http://github.com/pkulchenko/PegDebug";
        description = "PegDebug is a trace debugger for LPeg rules and captures.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT/X11";
      };
    }
  ) { };

  spawn = callPackage (
    {
      buildLuarocksPackage,
      fetchurl,
      fetchzip,
      luaAtLeast,
      luaOlder,
      lunix,
    }:
    buildLuarocksPackage {
      pname = "spawn";
      version = "0.1-0";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/spawn-0.1-0.rockspec";
          sha256 = "0yic1caj2fn0g4klnks8qkyqbvjiycdisgni98k2p3zlnb0r58v6";
        }).outPath;
      src = fetchzip {
        url = "https://github.com/daurnimator/lua-spawn/archive/v0.1.zip";
        sha256 = "094z2gjkigcj6afd8pq6dz6aa1lnlczj4k1g03sqhyv2kz5b05sv";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";
      propagatedBuildInputs = [ lunix ];

      meta = {
        homepage = "https://github.com/daurnimator/lua-spawn";
        description = "A lua library to spawn programs";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  yaml = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      fetchurl,
      luaAtLeast,
      luaOlder,
      lub,
    }:
    buildLuarocksPackage {
      pname = "yaml";
      version = "1.1.2-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/yaml-1.1.2-1.rockspec";
          sha256 = "0s5q69a7qwif5n3lv5fp93c4c17vxb7qf6nqny76gsa8ihpl7z8x";
        }).outPath;
      src = fetchFromGitHub {
        owner = "lubyk";
        repo = "yaml";
        rev = "REL-1.1.2";
        hash = "sha256-0KJnQPAfW/YnH+zOBpBFhXcM9HHTWDr3QTw5WnJGyFg=";
      };

      disabled = luaOlder "5.1" || luaAtLeast "5.4";
      propagatedBuildInputs = [ lub ];

      meta = {
        homepage = "http://doc.lubyk.org/yaml.html";
        description = "Very fast yaml parser based on libYAML by Kirill Simonov";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  yuecheck-vim = callPackage (
    {
      buildLuarocksPackage,
      fetchFromGitHub,
      luaOlder,
      luacheck,
      lunix,
      yuescript,
    }:
    buildLuarocksPackage {
      pname = "yuecheck-vim";
      version = "scm-1";

      src = fetchFromGitHub {
        owner = "Shados";
        repo = "yuecheck-vim";
        rev = "master";
        hash = "sha256-gZWYoMHHhxNuRK8HKII3v99An+cHHzIINRjE+/U3inc=";
      };

      disabled = luaOlder "5.1";
      nativeBuildInputs = [ yuescript ];
      propagatedBuildInputs = [
        luacheck
        lunix
        yuescript
      ];

      meta = {
        homepage = "https://github.com/Shados/yuecheck-vim";
        description = "A wrapper around luacheck to allow it to handle Yuescript, integrated into vim via ALE";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

  yuescript = callPackage (
    {
      buildLuarocksPackage,
      cmake,
      fetchFromGitHub,
      fetchurl,
      luaOlder,
    }:
    buildLuarocksPackage {
      pname = "yuescript";
      version = "0.26.0-1";
      knownRockspec =
        (fetchurl {
          url = "mirror://luarocks/yuescript-0.26.0-1.rockspec";
          sha256 = "0i0i2khw2fbvmi8ircjv4cg29bbx6waxvv7bk4q7nb4ll2z15i0l";
        }).outPath;
      src = fetchFromGitHub {
        owner = "pigpigyyy";
        repo = "yuescript";
        rev = "8a3d78c4d5bfe2ba39173e91146025278bf0deb2";
        hash = "sha256-cRnvx39be5NFLs2haycoma8NGFzRPCiTsxbUmxBs5hQ=";
      };

      disabled = luaOlder "5.1";
      nativeBuildInputs = [ cmake ];

      meta = {
        homepage = "https://github.com/pigpigyyy/yuescript";
        description = "Yuescript is a Moonscript dialect.";
        maintainers = with lib.maintainers; [ arobyn ];
        license.fullName = "MIT";
      };
    }
  ) { };

}
# GENERATED - do not edit this file
