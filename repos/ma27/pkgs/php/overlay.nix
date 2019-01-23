self: super:

let

  extraConfig = self.writeText "apcu-and-xdebug.ini" ''
    extension=${self.php71Packages.apcu}/lib/php/extensions/apcu.so
    zend_extension=${self.php71Packages.xdebug}/lib/php/extensions/xdebug.so
  '';

  # `php` doesn't have override capabilities and is expected to be
  # modified using nixpkgs config args. This is hacky and makes defining
  # jobsets harder. Thus we simply patch the configure flags.
  php' = super.php71.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [ "--with-xsl=${self.libxslt.dev}" ];
  });

in

  {
    php = self.symlinkJoin {
      name = "php-with-apcu-and-xdebug";
      paths = [ php' ];
      nativeBuildInputs = [ self.makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/php --add-flags "-c ${extraConfig}"
      '';
    };

    phpPackages = self.recurseIntoAttrs
      (self.callPackage
        (builtins.toPath "${self.path}/pkgs/top-level/php-packages.nix")
        ({ php = self.php; }));
  }
