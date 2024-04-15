
final: prev: rec {

  # talloc for proot
  talloc = prev.talloc.overrideAttrs (innerFinal: innerPrev: {
    wafConfigureFlags = innerPrev.wafConfigureFlags or [] ++ [ "--disable-python" ];
    patches = innerPrev.patches or [] ++ [ ./patches/talloc-satic.patch ];
    /*
    postBuild = ''
      # talloc's Waf setup doesn't build static libraries, so we do it manually
      # from: https://git.alpinelinux.org/aports/tree/main/talloc/APKBUILD
      ar qf libtalloc.a bin/default/talloc.c*.o
    '';
    postInstall = ''
      mkdir -p $out/lib/
      install -Dm644 libtalloc.a "$out"/lib/libtalloc.a
    '';
    */
  });

  # docutils for proot
  docutils = prev.docutils.overrideAttrs (innerFinal: innerPrev: {
    postInstall = "echo hiiiiiiiiiiiiiiiiiiiiiiiiiii; function setuptoolsCheckPhase(){ echo '#ILoveChecks'; };";
  });

  # proot
  proot = prev.proot.overrideAttrs (innerFinal: innerPrev: {
    #nativeBuildInputs = innerPrev.buildInputs or [] ++ [ prev.pkg-config final.docutils final.python311Packages.unicodedata2 ];
    #nativeBuildInputs = innerPrev.nativebuildInputs or [] ++ [ final.pkg-config final.docutils ];
    nativeBuildInputs = [ final.pkg-config ];
    postBuild = "";
    postInstall = "";

    # so i was wondering, why the static proot had so many dependencies in it's closure
    # because a static binary should have none
    # found: https://github.com/NixOS/nixpkgs/issues/83667
    # and: https://github.com/NixOS/nixpkgs/pull/83793
    # so adding a dev outpt, where the nix-support/propagated-build-inputs should end up
    outputs = [ "out" "dev" ];
  });


  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev: {
        tomli = python-prev.tomli.overrideAttrs (innerFinal: innerPrev: {
          postInstall = "echo hiiiiiiiiiiiiiiiiiiiiiiiiiii tooooooooooooooooooooooooooooooooooooooooooooooooooo; function unittestCheckPhase(){ echo '#ILoveChecks'; };";
        });
      }
    )
  ];





  python311Packages-tomli = prev.python311Packages.tomli.overrideAttrs (innerFinal: innerPrev: {
    #doCheck = false;
    postInstall = "echo hiiiiiiiiiiiiiiiiiiiiiiiiiii; function unittestCheckPhase(){ echo '#ILoveChecks'; };";
    installCheckPhase = "";
    setuptoolsCheckPhase = "";
  });

  #python311Packages = prev.python311Packages // { tomli = python311Packages-tomli; lxml = python311Packages-lxml; };

  #pythonPackagesOverlays = prev.pythonPackagesOverlays ++ [



  # for static builds
  duktape = prev.duktape.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/duktape.patch
    ];
    #unpackPhase = "echo hiiiiiiiiiiiiiiiiiiiiiiiiiii";
    #buildPhase = "echo hiiiiiiiiiiiiiiiiiiiiiiiiii";

    buildPhase = ''
      make -f dist-files/Makefile.staticlibrary
      make -f Makefile.cmdline
    '';
    installPhase = ''
      install -d $out/bin
      install -m755 duk $out/bin/
      install -d $out/lib/pkgconfig
      install -d $out/include
      make -f dist-files/Makefile.staticlibrary install INSTALL_PREFIX=$out
      substituteAll ${prev}/pkgs/development/interpreters/duktape/duktape.pc.in $out/lib/pkgconfig/duktape.pc
    '';
  });

  dconf = prev.dconf.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/dconf.patch
    ];
  });

  at-spi2-core = prev.at-spi2-core.overrideAttrs (innerFinal: innerPrev: {
    mesonFlags = innerPrev.mesonFlags or [] ++ [
      "-Dintrospection=disabled"
      "-Ddbus_broker=default"
      "-Dgtk2_atk_adaptor=false"
    ];
  });

  cdparanoia = prev.cdparanoia.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/cdparanoia.patch
    ];
  });


  # this is a mess....
  #pkgsStatic = prev.pkgsStatic // {gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };};
  #gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };
  #buildPackges = prev.buildPackges // {gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };};
  # .... gobject-introspection is just not made for dyn linking

  python311Packages-lxml = prev.python311Packages.lxml.overrideAttrs (innerFinal: innerPrev: 
    let
      libxmlSrc = prev.fetchurl {
        url = "mirror://gnome/sources/libxml2/${prev.lib.versions.majorMinor "2.12.4"}/libxml2-2.12.4.tar.xz";
        sha256 = "sha256-SXNg5CPPC9merNt8YhXeqS5tbonulAOTwrrg53y5t9A=";
      };
      zlibSrc = let version = "1.3.1"; in prev.fetchurl  {
        urls = [
          # This URL works for 1.2.13 only; hopefully also for future releases.
          "https://github.com/madler/zlib/releases/download/v${version}/zlib-${version}.tar.gz"
          # Stable archive path, but captcha can be encountered, causing hash mismatch.
          "https://www.zlib.net/fossils/zlib-${version}.tar.gz"
        ];
        hash = "sha256-mpOyt9/ax3zrpaVYpYDnRmfdb+3kWFuR7vtg8Dty3yM=";
      };
      libiconvSrc = prev.fetchurl {
        url = "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz";
        hash = "sha256-j3QhO1YjjIWlClMp934GGYdx5w3Zpzl3n0wC9l2XExM=";
      };
      libxsltSrc = let version = "1.1.37"; pname = "libxslt"; in prev.fetchurl {
        url = "mirror://gnome/sources/${pname}/${prev.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
        sha256 = "Oksn3IAnzNYUZyWVAzbx7FIJKPMg8UTrX6eZCuYSOrQ=";
      };
    in
    {
      setupPyBuildFlags = [
        "--libxml2-version=2.12.4"
        "--libxslt-version=1.1.37"
        "--zlib-version=1.3.1"
        "--libiconv-version=1.17"
        "--without-cython"
      ];
      patches = [
        ./static/python311Packages-lxml.patch
        # built without any extensions ... hardcoded with a patch
      ];

      STATICBUILD = true;
      preConfigure = ''
        mkdir -p ./libs
        cp ${zlibSrc} ./libs/${zlibSrc.name}
        cp ${libiconvSrc} ./libs/${libiconvSrc.name}
        cp ${libxmlSrc} ./libs/${libxmlSrc.name}
        cp ${libxsltSrc} ./libs/${libxsltSrc.name}

        ls ./libs
      '';
        #cat ${libxsltSrc} | xz -d | gzip > ./libs/${libxsltSrc.name}
        #cat ${libxmlSrc} | xz -d | gzip > ./libs/${libxmlSrc.name}
        #mv ./libs/libxslt-1.1.37.tar.xz ./libs/libxslt-1.1.37.tar.gz
        #mv ./libs/libxml2-2.10.4.tar.xz ./libs/libxml2-2.10.4.tar.gz
    });

  pkgsStatic = prev.pkgsStatic // {
    libglvnd = prev.libglvnd;
    gonme2.libIDL = prev.gnome2.libIDL;
    libjpeg-turbe = prev.libjpeg-turbo;
  };
}


