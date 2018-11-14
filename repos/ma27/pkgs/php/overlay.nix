self: super:

let

  extraConfig = self.writeText "apcu.ini" ''
    extension=${self.php71Packages.apcu}/lib/php/extensions/apcu.so
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
      name = "php-with-apcu";
      paths = [ php' ];
      nativeBuildInputs = [ self.makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/php --add-flags "-c ${extraConfig}"
      '';
    };
  }
