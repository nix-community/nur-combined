{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  boost,
  ogre_13,
  mygui,
  ois,
  SDL2,
  libX11,
  libvorbis,
  pkg-config,
  makeWrapper,
  enet,
  libXcursor,
  bullet,
  openal,
  tinyxml,
  tinyxml-2,
}:

let
  stuntrally_ogre = ogre_13.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DOGRE_NODELESS_POSITIONING=ON"
      "-DOGRE_RESOURCEMANAGER_STRICT=0"
    ];
  });
  stuntrally_mygui = mygui.override {
    withOgre = true;
    ogre = stuntrally_ogre;
  };
in

stdenv.mkDerivation rec {
  pname = "stuntrally";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "stuntrally";
    repo = "stuntrally";
    rev = version;
    hash = "sha256-0Eh9ilIHSh/Uz8TuPnXxLQfy7KF7qqNXUgBXQUCz9ys=";
  };
  tracks = fetchFromGitHub {
    owner = "stuntrally";
    repo = "tracks";
    rev = version;
    hash = "sha256-fglm1FetFGHM/qGTtpxDb8+k2iAREn5DQR5GPujuLms=";
  };

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  postPatch = ''
    substituteInPlace config/*-default.cfg \
      --replace-fail "screenshot_png = off" "screenshot_png = on"
    substituteInPlace source/*/BaseApp_Create.cpp \
      --replace-fail "Codec_FreeImage" "Codec_STBI" \
      --replace-fail "imgSet->getIndexInfo(0,0).texture" "std::string(imgSet->getIndexInfo(0,0).texture)"
    substituteInPlace source/shiny/Main/ShaderSet.cpp \
      --replace-fail "branch_path()" "parent_path()"
    substituteInPlace source/ogre/common/MessageBox/BaseLayout.h \
      --replace-fail "T::getClassTypeName()" "std::string(T::getClassTypeName())"
    substituteInPlace source/ogre/common/Def_Str.h \
      --replace-fail "#define s2r(s)  Ogre::StringConverter::parseReal(s)" "#define s2r(s)  Ogre::StringConverter::parseReal(std::string(s))" \
      --replace-fail "#define s2i(s)  Ogre::StringConverter::parseInt(s)" "#define s2i(s)  Ogre::StringConverter::parseInt(std::string(s))"
    substituteInPlace source/ogre/common/GuiCom_Util.cpp \
      --replace-fail 'wp->getUserString("tip")' 'std::string(wp->getUserString("tip"))' \
      --replace-fail 'wp->getUserString("RelativeTo")' 'std::string(wp->getUserString("RelativeTo"))'
    substituteInPlace source/ogre/common/PointerFix.cpp \
      --replace-fail 'info->findAttribute("key")' 'std::string(info->findAttribute("key"))' \
      --replace-fail 'info->findAttribute("value")' 'std::string(info->findAttribute("value"))'

    # Fix ABI/vtable issues with MyGUI 3.4
    substituteInPlace source/ogre/common/MultiList2.h \
      --replace-fail "MultiList2();" "MultiList2(); 
      virtual MyGUI::ILayerItem* getLayerItemByPoint(int _left, int _top) const override { return MyGUI::Widget::getLayerItemByPoint(_left, _top); } 
      virtual const MyGUI::IntCoord& getLayerItemCoord() const override { return MyGUI::Widget::getLayerItemCoord(); } 
      virtual void resizeLayerItemView(const MyGUI::IntSize& _oldView, const MyGUI::IntSize& _newView) override { }"
    
    substituteInPlace source/ogre/common/Slider.h \
      --replace-fail "Slider();" "Slider(); 
      virtual MyGUI::ILayerItem* getLayerItemByPoint(int _left, int _top) const override { return MyGUI::Widget::getLayerItemByPoint(_left, _top); } 
      virtual const MyGUI::IntCoord& getLayerItemCoord() const override { return MyGUI::Widget::getLayerItemCoord(); } 
      virtual void resizeLayerItemView(const MyGUI::IntSize& _oldView, const MyGUI::IntSize& _newView) override { }"
  '';

  preConfigure = ''
    rmdir data/tracks
    ln -s ${tracks}/ data/tracks
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    boost
    stuntrally_ogre
    stuntrally_mygui
    ois
    SDL2
    libX11
    libvorbis
    enet
    libXcursor
    bullet
    openal
    tinyxml
    tinyxml-2
  ];

  meta = {
    description = "Stunt Rally game with Track Editor, based on VDrift and OGRE";
    homepage = "http://stuntrally.tuxfamily.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
}
