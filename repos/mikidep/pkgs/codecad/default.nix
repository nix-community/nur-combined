{
  fetchFromGitHub,
  lib,
  stdenv,
  #
  imgui,
  lua5_4,
  opencascade-occt,
  tcl,
  tk,
  glm,
  cmake,
  libGL,
  xorg,
  libxrandr,
  libxinerama,
  libxcursor,
  libxi,
  fontconfig,
  sol2,
  nlohmann_json,
  glfw,
  cli11,
  gtest,
}: let
  lua = lua5_4;
  luaEnv = lua;
  imgui_ = imgui.overrideAttrs rec {
    version = "1.92.2b-docking";
    src = fetchFromGitHub {
      owner = "ocornut";
      repo = "imgui";
      tag = "v${version}";
      hash = "sha256-RmfmhuEgWmnSNJ+M1up2KCpi5FgA97GF3VZAIMmNtZk=";
    };
  };
  ghrev = "7ce7335";
in
  stdenv.mkDerivation {
    pname = "codecad";
    version = "github-${ghrev}";
    src = fetchFromGitHub {
      owner = "breiting";
      repo = "codecad";
      rev = ghrev;
      hash = "sha256-9/+DeYJIcurJXhBP2s45o7FZ44zTVg3qHKTMQnVcLMQ=";
    };
    buildInputs = [
      opencascade-occt
      luaEnv
      tcl
      tk
    ];
    nativeBuildInputs = [
      glm
      cmake
      libGL
      xorg.libX11.dev
      libxrandr
      libxinerama
      libxcursor
      libxi
      fontconfig
    ];
    cmakeFlags = let
      makeFlags = lib.mapAttrsToList (
        k: pkg: "-DFETCHCONTENT_SOURCE_DIR_${lib.toUpper k}=${pkg.src}"
      );
    in
      makeFlags {
        glm = glm;
        sol2 = sol2;
        json = nlohmann_json;
        glfw = glfw;
        imgui = imgui_;
        cli11 = cli11;
        googletest = gtest;
      };

    LUA_CPATH = "${luaEnv}/lib/lua/${lua.luaversion}/?.so";
    LUA_PATH = "${luaEnv}/share/lua/${lua.luaversion}/?.lua;;";
  }
