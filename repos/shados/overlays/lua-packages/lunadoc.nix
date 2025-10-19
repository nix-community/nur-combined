{
  lib,
  stdenv,
  lua,
  buildLuarocksPackage,
  fetchgit,
  writeText,
  luarocks,
  shim-getpw,
  moonscript,
  etlua,
  loadkit,
  luafilesystem,
  lua-discount,
}:
let
  rockspecName = "lunadoc-scm-1.rockspec";
  rockspec = writeText rockspecName ''
    package = "lunadoc"
    version = "scm-1"

    source = {
      url = "git://github.com/cuddlyrobot/lunadoc.git",
      tag = "master"
    }

    description = {
      summary = "A better documentation generator for Moonscript",
      detailed = [[
         Generate documentation for your Moonscript projects.
      ]],
      homepage = "http://github.com/cuddlyrobot/lunadoc",
      license = "MIT/X11"
    }

    dependencies = {
      "lua ~> 5.1",
      -- "discount",
      -- "moonscript",
      -- "etlua",
      -- "loadkit",
      -- "luafilesystem",
    }

    build = {
      type = "command",
      build_command = "moonc .",
      modules = {
        ["lunadoc.init"] = "modules/lunadoc/init.lua",
        ["lunadoc.indent"] = "modules/lunadoc/indent.lua",
        ["lunadoc.gsplit"] = "modules/lunadoc/gsplit.lua",
        ["lunadoc.doc_moon"] = "modules/lunadoc/doc_moon.lua"
      },

      install = { 
        bin = { "lunadoc" },
        lua = {
          ["lunadoc.init"] = "modules/lunadoc/init.lua",
          ["lunadoc.indent"] = "modules/lunadoc/indent.lua",
          ["lunadoc.gsplit"] = "modules/lunadoc/gsplit.lua",
          ["lunadoc.doc_moon"] = "modules/lunadoc/doc_moon.lua",
          ["lunadoc.templates.hljs"] = "modules/lunadoc/templates/hljs.js",
          ["lunadoc.templates.html"] = "modules/lunadoc/templates/html.elua",
          ["lunadoc.templates.style"] = "modules/lunadoc/templates/style.css",
          ["lunadoc.templates.hlstyles.agate"] = "modules/lunadoc/templates/hlstyles/agate.css",
          ["lunadoc.templates.hlstyles.androidstudio"] = "modules/lunadoc/templates/hlstyles/androidstudio.css",
          ["lunadoc.templates.hlstyles.arduino-light"] = "modules/lunadoc/templates/hlstyles/arduino-light.css",
          ["lunadoc.templates.hlstyles.arta"] = "modules/lunadoc/templates/hlstyles/arta.css",
          ["lunadoc.templates.hlstyles.ascetic"] = "modules/lunadoc/templates/hlstyles/ascetic.css",
          ["lunadoc.templates.hlstyles.atelier-cave-dark"] = "modules/lunadoc/templates/hlstyles/atelier-cave-dark.css",
          ["lunadoc.templates.hlstyles.atelier-cave-light"] = "modules/lunadoc/templates/hlstyles/atelier-cave-light.css",
          ["lunadoc.templates.hlstyles.atelier-dune-dark"] = "modules/lunadoc/templates/hlstyles/atelier-dune-dark.css",
          ["lunadoc.templates.hlstyles.atelier-dune-light"] = "modules/lunadoc/templates/hlstyles/atelier-dune-light.css",
          ["lunadoc.templates.hlstyles.atelier-estuary-dark"] = "modules/lunadoc/templates/hlstyles/atelier-estuary-dark.css",
          ["lunadoc.templates.hlstyles.atelier-estuary-light"] = "modules/lunadoc/templates/hlstyles/atelier-estuary-light.css",
          ["lunadoc.templates.hlstyles.atelier-forest-dark"] = "modules/lunadoc/templates/hlstyles/atelier-forest-dark.css",
          ["lunadoc.templates.hlstyles.atelier-forest-light"] = "modules/lunadoc/templates/hlstyles/atelier-forest-light.css",
          ["lunadoc.templates.hlstyles.atelier-heath-dark"] = "modules/lunadoc/templates/hlstyles/atelier-heath-dark.css",
          ["lunadoc.templates.hlstyles.atelier-heath-light"] = "modules/lunadoc/templates/hlstyles/atelier-heath-light.css",
          ["lunadoc.templates.hlstyles.atelier-lakeside-dark"] = "modules/lunadoc/templates/hlstyles/atelier-lakeside-dark.css",
          ["lunadoc.templates.hlstyles.atelier-lakeside-light"] = "modules/lunadoc/templates/hlstyles/atelier-lakeside-light.css",
          ["lunadoc.templates.hlstyles.atelier-plateau-dark"] = "modules/lunadoc/templates/hlstyles/atelier-plateau-dark.css",
          ["lunadoc.templates.hlstyles.atelier-plateau-light"] = "modules/lunadoc/templates/hlstyles/atelier-plateau-light.css",
          ["lunadoc.templates.hlstyles.atelier-savanna-dark"] = "modules/lunadoc/templates/hlstyles/atelier-savanna-dark.css",
          ["lunadoc.templates.hlstyles.atelier-savanna-light"] = "modules/lunadoc/templates/hlstyles/atelier-savanna-light.css",
          ["lunadoc.templates.hlstyles.atelier-seaside-dark"] = "modules/lunadoc/templates/hlstyles/atelier-seaside-dark.css",
          ["lunadoc.templates.hlstyles.atelier-seaside-light"] = "modules/lunadoc/templates/hlstyles/atelier-seaside-light.css",
          ["lunadoc.templates.hlstyles.atelier-sulphurpool-dark"] = "modules/lunadoc/templates/hlstyles/atelier-sulphurpool-dark.css",
          ["lunadoc.templates.hlstyles.atelier-sulphurpool-light"] = "modules/lunadoc/templates/hlstyles/atelier-sulphurpool-light.css",
          ["lunadoc.templates.hlstyles.atom-one-dark"] = "modules/lunadoc/templates/hlstyles/atom-one-dark.css",
          ["lunadoc.templates.hlstyles.atom-one-light"] = "modules/lunadoc/templates/hlstyles/atom-one-light.css",
          ["lunadoc.templates.hlstyles.codepen-embed"] = "modules/lunadoc/templates/hlstyles/codepen-embed.css",
          ["lunadoc.templates.hlstyles.color-brewer"] = "modules/lunadoc/templates/hlstyles/color-brewer.css",
          ["lunadoc.templates.hlstyles.darcula"] = "modules/lunadoc/templates/hlstyles/darcula.css",
          ["lunadoc.templates.hlstyles.dark"] = "modules/lunadoc/templates/hlstyles/dark.css",
          ["lunadoc.templates.hlstyles.darkula"] = "modules/lunadoc/templates/hlstyles/darkula.css",
          ["lunadoc.templates.hlstyles.default"] = "modules/lunadoc/templates/hlstyles/default.css",
          ["lunadoc.templates.hlstyles.docco"] = "modules/lunadoc/templates/hlstyles/docco.css",
          ["lunadoc.templates.hlstyles.dracula"] = "modules/lunadoc/templates/hlstyles/dracula.css",
          ["lunadoc.templates.hlstyles.far"] = "modules/lunadoc/templates/hlstyles/far.css",
          ["lunadoc.templates.hlstyles.foundation"] = "modules/lunadoc/templates/hlstyles/foundation.css",
          ["lunadoc.templates.hlstyles.github"] = "modules/lunadoc/templates/hlstyles/github.css",
          ["lunadoc.templates.hlstyles.github-gist"] = "modules/lunadoc/templates/hlstyles/github-gist.css",
          ["lunadoc.templates.hlstyles.googlecode"] = "modules/lunadoc/templates/hlstyles/googlecode.css",
          ["lunadoc.templates.hlstyles.grayscale"] = "modules/lunadoc/templates/hlstyles/grayscale.css",
          ["lunadoc.templates.hlstyles.gruvbox-dark"] = "modules/lunadoc/templates/hlstyles/gruvbox-dark.css",
          ["lunadoc.templates.hlstyles.gruvbox-light"] = "modules/lunadoc/templates/hlstyles/gruvbox-light.css",
          ["lunadoc.templates.hlstyles.hopscotch"] = "modules/lunadoc/templates/hlstyles/hopscotch.css",
          ["lunadoc.templates.hlstyles.hybrid"] = "modules/lunadoc/templates/hlstyles/hybrid.css",
          ["lunadoc.templates.hlstyles.idea"] = "modules/lunadoc/templates/hlstyles/idea.css",
          ["lunadoc.templates.hlstyles.ir-black"] = "modules/lunadoc/templates/hlstyles/ir-black.css",
          ["lunadoc.templates.hlstyles.kimbie.dark"] = "modules/lunadoc/templates/hlstyles/kimbie.dark.css",
          ["lunadoc.templates.hlstyles.kimbie.light"] = "modules/lunadoc/templates/hlstyles/kimbie.light.css",
          ["lunadoc.templates.hlstyles.magula"] = "modules/lunadoc/templates/hlstyles/magula.css",
          ["lunadoc.templates.hlstyles.mono-blue"] = "modules/lunadoc/templates/hlstyles/mono-blue.css",
          ["lunadoc.templates.hlstyles.monokai"] = "modules/lunadoc/templates/hlstyles/monokai.css",
          ["lunadoc.templates.hlstyles.monokai-sublime"] = "modules/lunadoc/templates/hlstyles/monokai-sublime.css",
          ["lunadoc.templates.hlstyles.obsidian"] = "modules/lunadoc/templates/hlstyles/obsidian.css",
          ["lunadoc.templates.hlstyles.ocean"] = "modules/lunadoc/templates/hlstyles/ocean.css",
          ["lunadoc.templates.hlstyles.paraiso-dark"] = "modules/lunadoc/templates/hlstyles/paraiso-dark.css",
          ["lunadoc.templates.hlstyles.paraiso-light"] = "modules/lunadoc/templates/hlstyles/paraiso-light.css",
          ["lunadoc.templates.hlstyles.purebasic"] = "modules/lunadoc/templates/hlstyles/purebasic.css",
          ["lunadoc.templates.hlstyles.qtcreator_dark"] = "modules/lunadoc/templates/hlstyles/qtcreator_dark.css",
          ["lunadoc.templates.hlstyles.qtcreator_light"] = "modules/lunadoc/templates/hlstyles/qtcreator_light.css",
          ["lunadoc.templates.hlstyles.railscasts"] = "modules/lunadoc/templates/hlstyles/railscasts.css",
          ["lunadoc.templates.hlstyles.rainbow"] = "modules/lunadoc/templates/hlstyles/rainbow.css",
          ["lunadoc.templates.hlstyles.routeros"] = "modules/lunadoc/templates/hlstyles/routeros.css",
          ["lunadoc.templates.hlstyles.solarized-dark"] = "modules/lunadoc/templates/hlstyles/solarized-dark.css",
          ["lunadoc.templates.hlstyles.solarized-light"] = "modules/lunadoc/templates/hlstyles/solarized-light.css",
          ["lunadoc.templates.hlstyles.sunburst"] = "modules/lunadoc/templates/hlstyles/sunburst.css",
          ["lunadoc.templates.hlstyles.tomorrow"] = "modules/lunadoc/templates/hlstyles/tomorrow.css",
          ["lunadoc.templates.hlstyles.tomorrow-night-blue"] = "modules/lunadoc/templates/hlstyles/tomorrow-night-blue.css",
          ["lunadoc.templates.hlstyles.tomorrow-night-bright"] = "modules/lunadoc/templates/hlstyles/tomorrow-night-bright.css",
          ["lunadoc.templates.hlstyles.tomorrow-night"] = "modules/lunadoc/templates/hlstyles/tomorrow-night.css",
          ["lunadoc.templates.hlstyles.tomorrow-night-eighties"] = "modules/lunadoc/templates/hlstyles/tomorrow-night-eighties.css",
          ["lunadoc.templates.hlstyles.vs2015"] = "modules/lunadoc/templates/hlstyles/vs2015.css",
          ["lunadoc.templates.hlstyles.vs"] = "modules/lunadoc/templates/hlstyles/vs.css",
          ["lunadoc.templates.hlstyles.xcode"] = "modules/lunadoc/templates/hlstyles/xcode.css",
          ["lunadoc.templates.hlstyles.xt256"] = "modules/lunadoc/templates/hlstyles/xt256.css",
          ["lunadoc.templates.hlstyles.zenburn"] = "modules/lunadoc/templates/hlstyles/zenburn.css"
        }
      }
    }
  '';
in
buildLuarocksPackage rec {
  name = "${pname}-${version}";
  pname = "lunadoc";
  version = "unstable-2018-04-10";

  src = fetchgit {
    url = "https://gitlab.com/nonchip/${pname}";
    rev = "24d29cbd0e53cdf6b636ee1c92cd6aa1ff703721";
    sha256 = "0mykvwwbi666zzaalddrbhsq4pjy1ns6d3dhfdfakg2kn6r5ygin";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    luarocks
  ];
  propagatedBuildInputs = [
    lua-discount
    etlua
    loadkit
    moonscript
    luafilesystem
  ];

  buildPhase =
    let
      getpw-preload = "${shim-getpw}/lib/libshim-getpw.so";
    in
    ''
      # Configure shim-getpw to prevent spurious luarocks warning, and point it to
      # the right home directory
      export LD_PRELOAD="${getpw-preload}''${LD_PRELOAD:+ ''${LD_PRELOAD}}"
      export HOME=$(pwd)
      export SHIM_HOME=$HOME
      export USER=$(id -un)
      export SHIM_USER=$USER
      export SHIM_UID=$UID
    '';
  installPhase = ''
    cp ${rockspec} ${rockspecName}
    # Tell luarocks to install to $out
    luarocks --tree $out make ${rockspecName}
  '';

  meta = with lib; {
    description = "A better documentation generator for Moonscript";
    homepage = "https://gitlab.com/nonchip/lunadoc";
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.isc;
  };
}
