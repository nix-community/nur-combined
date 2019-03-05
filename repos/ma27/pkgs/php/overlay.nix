self: super:

let

  extraConfig = self.writeText "custom-extensions.ini" ''
    extension=${self.php72Packages.apcu}/lib/php/extensions/apcu.so
    extension=${self.php72Packages.imagick}/lib/php/extensions/imagick.so
    zend_extension=${self.php72Packages.xdebug}/lib/php/extensions/xdebug.so
  '';

  # `php` doesn't have override capabilities and is expected to be
  # modified using nixpkgs config args. This is hacky and makes defining
  # jobsets harder. Thus we simply patch the configure flags.
  php' = super.php72.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      "--with-xsl=${self.libxslt.dev}"
      "--with-tidy=${self.html-tidy}"
    ];
  });

in

  {
    php = self.symlinkJoin {
      name = "php-custom";
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
