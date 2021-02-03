# GHC with some of the more common haskell packages, along with some hand-picked ones to taste
self: super: let
   pkgs = super.callNixPackage ({pkgs}: pkgs) {};
   haskellPackages = p: with p; [
      # from haskell.org
      OpenGL
      QuickCheck
      SDL
      aeson
      async
      attoparsec
      binary
      blaze-html
      bytestring
      cairo
      cereal
      conduit
      containers
      criterion
      directory
      dlist
      fsnotify
      glib
      gtk
      happstack
      hint
      hspec
      http-client
      monad-logger
      mwc-random
      network
      pandoc
      pango
      parsec
      persistent
      pipes
      process
      resource-pool
      scientific
      snap
      statistics
      stm
      syb
      tar
      template-haskell
      test-framework
      text
      text-icu
      time
      tls
      unix
      vector
      warp
      xml
      yaml
      yesod
      zip-archive
      zlib
      # own preference
      rio
      stack
      hnix
   ];
in
   { haskellPlatform = pkgs.ghcWithHoogle haskellPackages; }

