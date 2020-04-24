{ makeWrapper, stdenv, writeScript, fetchurl, buildBowerComponents, mylibs, which, python36, gst_all_1, automake, autoconf, nodejs, nodePackages }:
let
  overridePython = let
    packageOverrides = self: super: {
      pybcrypt = super.buildPythonPackage rec {
        pname = "pybcrypt";
        version = "0.4";

        src = self.fetchPypi {
          inherit pname version;
          sha256 = "5fa13bce551468350d66c4883694850570f3da28d6866bb638ba44fe5eabda78";
        };
      };
      celery = super.celery.overridePythonAttrs(old: rec {
        version = "3.1.26.post2";
        src = self.fetchPypi {
          inherit version;
          inherit (old) pname;
          sha256 = "5493e172ae817b81ba7d09443ada114886765a8ce02f16a56e6fac68d953a9b2";
        };
        patches = [];
        doCheck = false;
      });
      billiard = super.billiard.overridePythonAttrs(old: rec {
        version = "3.3.0.23";
        src = self.fetchPypi {
          inherit version;
          inherit (old) pname;
          sha256 = "02wxsc6bhqvzh8j6w758kvgqbnj14l796mvmrcms8fgfamd2lak9";
        };
        doCheck = false;
        doInstallCheck = false;
      });
      amqp = super.amqp.overridePythonAttrs(old: rec {
        version = "1.4.9";
        src = self.fetchPypi {
          inherit version;
          inherit (old) pname;
          sha256 = "2dea4d16d073c902c3b89d9b96620fb6729ac0f7a923bbc777cb4ad827c0c61a";
        };
      });
      kombu = super.kombu.overridePythonAttrs(old: rec {
        version = "3.0.37";
        src = self.fetchPypi {
          inherit version;
          inherit (old) pname;
          sha256 = "e064a00c66b4d1058cd2b0523fb8d98c82c18450244177b6c0f7913016642650";
        };
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.anyjson ];
        doCheck = false;
      });
      sqlalchemy = super.sqlalchemy.overridePythonAttrs(old: rec {
        version = "1.1.18";
        src = self.fetchPypi {
          inherit version;
          inherit (old) pname;
          sha256 = "8b0ec71af9291191ba83a91c03d157b19ab3e7119e27da97932a4773a3f664a9";
        };
        doCheck = false;
      });
      tempita_5_3_dev = super.buildPythonPackage (mylibs.fetchedGithub ./tempita.json // rec {
        buildInputs = with self; [ nose ];
        disabled = false;
      });
      sqlalchemy_migrate = super.sqlalchemy_migrate.overridePythonAttrs(old: rec {
        propagatedBuildInputs = with self; [ pbr tempita_5_3_dev decorator sqlalchemy six sqlparse ];
      });
      pasteScript = super.pasteScript.overridePythonAttrs(old: rec {
        version = "2.0.2";
        name = "PasteScript-${version}";
        src = fetchurl {
          url = "mirror://pypi/P/PasteScript/${name}.tar.gz";
          sha256 = "1h3nnhn45kf4pbcv669ik4faw04j58k8vbj1hwrc532k0nc28gy0";
        };
        propagatedBuildInputs = with self; [ six paste PasteDeploy ];
      });
    };
    in
      python36.override { inherit packageOverrides; };
  pythonEnv = python-pkgs: with python-pkgs; [
    waitress alembic dateutil wtforms pybcrypt
    pytest pytest_xdist werkzeug celery
    kombu jinja2 Babel webtest configobj markdown
    sqlalchemy itsdangerous pytz sphinx six
    oauthlib unidecode jsonschema PasteDeploy
    requests PyLD exifread
    typing pasteScript lxml
    # For images plugin
    pillow
    # For video plugin
    gst-python
    # migrations
    sqlalchemy_migrate
    # authentication
    ldap3
    redis
    psycopg2
  ];
  python = overridePython.withPackages pythonEnv;
  gmg = writeScript "gmg" ''
    #!${python}/bin/python
    __requires__ = 'mediagoblin'
    import sys
    from pkg_resources import load_entry_point

    if __name__ == '__main__':
        sys.exit(
            load_entry_point('mediagoblin', 'console_scripts', 'gmg')()
        )
    '';
  bowerComponents = buildBowerComponents {
    name = "mediagoblin-bower-components";
    generated = ./bower-packages.nix;
    src = (mylibs.fetchedGit ./mediagoblin.json).src;
  };
  withPlugins = plugins: package.overrideAttrs(old: {
    name = "${old.name}-with-plugins";
    postBuild = old.postBuild + (
      builtins.concatStringsSep "\n" (
        map (value: "ln -s ${value} mediagoblin/plugins/${value.pluginName}") plugins
        )
      );
    passthru = old.passthru // {
      inherit plugins;
      withPlugins = morePlugins: old.withPlugins (morePlugins ++ plugins);
    };
  });
  package = stdenv.mkDerivation (mylibs.fetchedGit ./mediagoblin.json // rec {
    preConfigure = ''
      # ./bootstrap.sh
      aclocal -I m4 --install
      autoreconf -fvi
      # end
      export HOME=$PWD
      '';
    configureFlags = [ "--with-python3" "--without-virtualenv" ];
    postBuild = ''
      cp -a ${bowerComponents}/bower_components/* extlib
      chmod -R u+w extlib
      make extlib
      '';
    installPhase = let
      libpaths = with gst_all_1; [
        python
        gstreamer
        gst-plugins-base
        gst-libav
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
      ];
      plugin_paths = builtins.concatStringsSep ":" (map (x: "${x}/lib") libpaths);
      typelib_paths = with gst_all_1; "${gstreamer}/lib/girepository-1.0:${gst-plugins-base}/lib/girepository-1.0";
    in ''
      sed -i "s/registry.has_key(current_theme_name)/current_theme_name in registry/" mediagoblin/tools/theme.py
      sed -i -e "s@\[DEFAULT\]@[DEFAULT]\nhere = $out@" mediagoblin/config_spec.ini
      sed -i -e "/from gi.repository import GstPbutils/s/^/gi.require_version('GstPbutils', '1.0')\n/" mediagoblin/media_types/video/transcoders.py
      cp ${./ldap_fix.py} mediagoblin/plugins/ldap/tools.py
      find . -name '*.pyc' -delete
      find . -type f -exec sed -i "s|$PWD|$out|g" {} \;
      python setup.py build
      cp -a . $out
      mkdir $out/bin
      makeWrapper ${gmg} $out/bin/gmg --prefix PYTHONPATH : "$out:$PYTHONPATH" \
        --prefix GST_PLUGIN_SYSTEM_PATH : ${plugin_paths} \
        --prefix GI_TYPELIB_PATH : ${typelib_paths}
      makeWrapper ${python}/bin/paster $out/bin/paster --prefix PYTHONPATH : "$out:$PYTHONPATH" \
        --prefix GST_PLUGIN_SYSTEM_PATH : ${plugin_paths} \
        --prefix GI_TYPELIB_PATH : ${typelib_paths}
      makeWrapper ${python}/bin/celery $out/bin/celery --prefix PYTHONPATH : "$out:$PYTHONPATH" \
        --prefix GST_PLUGIN_SYSTEM_PATH : ${plugin_paths} \
        --prefix GI_TYPELIB_PATH : ${typelib_paths}
      '';
    buildInputs = [ makeWrapper automake autoconf which nodePackages.bower nodejs python ];
    propagatedBuildInputs = with gst_all_1; [ python gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly gstreamer ];
    passthru = {
      plugins = [];
      inherit withPlugins;
    };
  });
in package
