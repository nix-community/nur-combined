/*

run a local hypothesis server

status: work in progress

python dependencies should be satisfied



working

  nix-shell /path/to/this/shell.nix
  git clone --depth 1 https://github.com/hypothesis/h
  cd h
  # support new API pyparsing.ParserElement.enablePackrat
  curl https://github.com/hypothesis/h/pull/7285.diff | patch -p1
  ./bin/hypothesis --help
  ./bin/hypothesis shell
  ./bin/hypothesis --app-url / --dev shell



broken

  make dev
    requires pyenv, pip, ...
    TODO how does "make dev" start the webserver on localhost:5000?



upstream bugs

  https://github.com/hypothesis/h/pull/7285



https://h.readthedocs.io/en/stable/developing/install/website/

Installing the services

  h requires the following external services:

  PostgreSQL 9.4+
  Elasticsearch v1.0+, with the Elasticsearch ICU Analysis plugin
  RabbitMQ v3.5+
  Redis v2.4+



Running h

  Start a development server:

  make dev
  The first time you run make dev it might take a while to start
  because it’ll need to install the application dependencies and build the client assets.

  This will start the server on port 5000 (http://localhost:5000),
  reload the application whenever changes are made to the source code,
  and restart it should it crash for some reason.



TODO all zope packages: run tests with tox, not with pytest
    # WARNING: Testing via this command is deprecated and will be removed in a future version.
    # Users looking for a generic test entry point independent of test runner are encouraged to use tox.

NOTE pythonPackages.hypothesis exists, but is a different hypothesis https://github.com/NixOS/nixpkgs/pull/146339/files

*/

{
  pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) lib;

  fetchPypi = my-python.pkgs.fetchPypi;
  buildPythonPackage = my-python.pkgs.buildPythonPackage;
  fetchFromGitHub = pkgs.fetchFromGitHub;

  my-python = pkgs.python39;
  my-python-packages = (python-packages: with python-packages; [

    click
    pyramid
    sqlalchemy
    slugify
    bleach
    zope
    zope_sqlalchemy
    markdown
    pyramid_retry
    Cryptodome
    passlib
    celery
    alembic
    elasticsearch
    elasticsearch_dsl
    colander
    deform
    jsonschema
    newrelic
    jinja2
    tox
    ws4py
    h_pyramid_sentry
    pyramid_mailer
    importlib_resources
    pyramid_exclog
    pyramid_jinja2
    pyramid_services
    pyramid_tm
    h_assets
    psycopg2
    oauthlib
    itsdangerous
    h_api
    pyramid_sanity
  ]);

  python-with-my-packages = my-python.withPackages my-python-packages;



  # new packages ...

  zope_deferredimport = zope-deferredimport; # alias for consistency
  zope = Zope; # alias # import name is lowercase
  SQLAlchemy = sqlalchemy; # alias. SQLAlchemy = import name
  WebOb = my-python.pkgs.webob; # alias
  Cryptodome = pycryptodomex; # alias. Cryptodome is the import name / package name
  elasticsearch_dsl = elasticsearch-dsl; # alias. elasticsearch_dsl is the import name

  h_api = my-python.pkgs.buildPythonPackage rec {
    # "At the present time not only should you not use this package, our authentication will also prevent it."
    pname = "h_api";
    version = "1.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "lLoIA/0ibcoRZhQ6EWHoXJt7VO4uhEHd0YaHKibKcCk=";
    };
    buildInputs = (with my-python.pkgs; [
      importlib-resources
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      jsonschema
      h_matchers
    ]);
    checkInputs = with my-python.pkgs; [
    ];
    meta = with lib; {
      homepage = "https://github.com/hypothesis/h-api";
      description = "Tools and components for calling the Hypothesis API";
      license = licenses.bsdOriginal;
    };
  };

  pyramid_sanity = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_sanity";
    version = "1.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "gBp3/UmXDLRAE8J4mRQm17B6oK1x6UKd83zMuP9wcyI=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
    ]);
    checkInputs = with my-python.pkgs; [
      webtest
    ];
    meta = with lib; {
      homepage = "https://github.com/hypothesis/pyramid-sanity";
      description = "Pyramid extension that catches certain crashes caused by badly formed requests";
      license = licenses.bsdOriginal;
    };
  };

  pyramid_tm = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_tm";
    version = "2.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "X9bUrJGBpl7FTlsoAintbYs+1qj1oLz/BcVydR8IZTM=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
      transaction
    ]);
    checkInputs = with my-python.pkgs; [
      WebTest
    ];
    meta = with lib; {
      homepage = "https://github.com/Pylons/pyramid_tm";
      description = "A package which allows Pyramid requests to join the active transaction";
      license = licenses.bsdOriginal; # FIXME License: Repoze Public License (BSD-derived (http://www.repoze.org/LICENSE.txt))
    };
  };

  # FIXME bug in nixpkgs: AttributeError: 'Request' object has no attribute 'registry'
  # not released -> build from github
  # upstream https://github.com/Pylons/pyramid_exclog/issues/38
  pyramid_exclog = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_exclog";
    #version = "1.0";
    version = "2021-05-07";
    src = fetchFromGitHub {
      # https://github.com/Pylons/pyramid_exclog/
      repo = "pyramid_exclog";
      owner = "Pylons";
      rev = "14c5c7ad1fa2b295d7a57d5d0bfb8269c7778ac2";
      sha256 = "s1mop+BdBgs+ln1c9n18wsT7Et3zyuosP4ttqpC0aoA=";
    };
    /*
    src = fetchPypi {
      inherit pname version;
      sha256 = "11bi+F3U3iuom+CyHboqO77C6HGkKjoWcZJYoR+HUGs=";
    };
    */
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
    ]);
    meta = with lib; {
      homepage = "https://github.com/Pylons/pyramid_exclog";
      description = "Read resources from Python packages";
      license = licenses.asl20;
    };
  };

  importlib_resources = my-python.pkgs.buildPythonPackage rec {
    pname = "importlib_resources";
    version = "5.4.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "11bi+F3U3iuom+CyHboqO77C6HGkKjoWcZJYoR+HUGs=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zipp
    ]);
    meta = with lib; {
      homepage = "https://github.com/python/importlib_resources";
      description = "Read resources from Python packages";
      license = licenses.asl20;
    };
  };

  pyramid_services = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_services";
    version = "2.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "RZ9NoDUZhZK3dv6A9R5yQ5mE9Qq9Ty8XGVhNN6p2Njk=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
      wired
    ]);
    checkInputs = with my-python.pkgs; [
      webtest
      pytest-cov
    ];
    meta = with lib; {
      homepage = "https://github.com/mmerickel/pyramid_services";
      description = "A service layer abstraction for the Pyramid Web Framework";
      license = licenses.mit;
    };
  };

  wired = my-python.pkgs.buildPythonPackage rec {
    pname = "wired";
    version = "0.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "ESL/LfIK7Rjo/jGNq6E6/IBkC8gfS7DCSZxzxqHcTfA=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_interface
    ]);
    checkInputs = with my-python.pkgs; [
      pytest
      venusian
    ];
    meta = with lib; {
      homepage = "https://github.com/mmerickel/wired";
      description = "An inversion-of-control (IoC) container for building decoupled, configurable, pluggable applications";
      license = licenses.mit;
    };
  };

  repoze_sendmail = my-python.pkgs.buildPythonPackage rec {
    pname = "repoze.sendmail";
    version = "4.4.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "eo6jeRSl04utOAUqg+rB2Gexcf9MyLTUmU6JLAWw1CQ=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      transaction
    ]);
    checkInputs = with my-python.pkgs; [
      webtest
    ];
    meta = with lib; {
      homepage = "http://www.repoze.org/";
      description = "Repoze Sendmail";
      license = licenses.zpl21;
    };
  };

  pyramid_mailer = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_mailer";
    version = "0.15.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "7Ar/VNkXmyqiki/4LCAWpNyNHaXcNAjWWU8OIJZEb5s=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
      repoze_sendmail
      /*
      pyramid_retry
      sentry-sdk
      sqlalchemy
      celery
      h_matchers
      */
    ]);
    checkInputs = with my-python.pkgs; [
      webtest
    ];
    #doCheck = false; # FIXME Unknown command 'test'.Type 'newrelic-admin help' for usage.
    meta = with lib; {
      homepage = "https://github.com/Pylons/pyramid_mailer";
      description = "Sendmail package for Pyramid";
      license = licenses.bsdOriginal;
    };
  };




  h_assets = my-python.pkgs.buildPythonPackage rec {
    pname = "h_assets";
    version = "1.0.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "ChQpAAUGk6Et+3SRirnNqZSRndCTwP8T1WtIcOlsZ+g=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
    ]);
    checkInputs = with my-python.pkgs; [
    ];
    meta = with lib; {
      homepage = "https://github.com/hypothesis/h-assets";
      description = "Pyramid views for serving compiled static assets";
      license = licenses.bsdOriginal;
    };
  };

  h_pyramid_sentry = my-python.pkgs.buildPythonPackage rec {
    pname = "h_pyramid_sentry";
    version = "1.2.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "GakQ4E5JNhqENKBR6HWUlrUZJCxs19LDem6Nu5qhNT4=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
      pyramid_retry
      sentry-sdk
      sqlalchemy
      celery
      h_matchers
    ]);
    checkInputs = with my-python.pkgs; [
    ];
    meta = with lib; {
      homepage = "https://github.com/hypothesis/h-pyramid-sentry";
      description = "A Pyramid plugin for integrating Sentry error reporting";
      license = licenses.bsdOriginal;
    };
  };

  h_matchers = my-python.pkgs.buildPythonPackage rec {
    pname = "h_matchers";
    version = "1.2.12";
    src = fetchPypi {
      inherit pname version;
      sha256 = "K7yXIrGdiY6qhXqm8AL4OjX2mCcNi3tZ+ObywZeSFns=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pyramid
      requests
    ]);
    checkInputs = with my-python.pkgs; [
    ];
    #doCheck = false; # FIXME Unknown command 'test'.Type 'newrelic-admin help' for usage.
    meta = with lib; {
      homepage = "https://github.com/hypothesis/h-matchers";
      description = "Test objects which pass equality checks with other objects";
      license = licenses.bsdOriginal;
    };
  };

  newrelic = my-python.pkgs.buildPythonPackage rec {
    pname = "newrelic";
    version = "7.4.0.172";
    src = fetchPypi {
      inherit pname version;
      sha256 = "9Cx2Cq1kO3AMXRlgC699XBkooDZWHSxB7PgO97WEK6M=";
    };
    buildInputs = (with my-python.pkgs; [
      setuptools_scm
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
    ]);
    checkInputs = with my-python.pkgs; [
    ];
    doCheck = false; # FIXME Unknown command 'test'.Type 'newrelic-admin help' for usage.
    meta = with lib; {
      homepage = "http://github.com/zacharyvoase/slugify";
      description = "New Relic Python Agent for performance monitoring and performance analytics";
      license = licenses.asl20;
    };
  };

  pyramid_retry = my-python.pkgs.buildPythonPackage rec {
    pname = "pyramid_retry";
    version = "2.1.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "uqgnauaLq60J5fL5TvxPdCHzuPtSYVHfUiBS+M0+wMk=";
    };
    propagatedBuildInputs = [] ++ (with my-python.pkgs; [
      pyramid
    ]);
    checkInputs = with my-python.pkgs; [
      webtest
    ];
    meta = with lib; {
      homepage = "http://github.com/zacharyvoase/slugify";
      description = "An execution policy for Pyramid that supports retrying requests after certain failure exceptions";
      license = licenses.mit;
    };
  };

  slugify = my-python.pkgs.buildPythonPackage rec {
    pname = "slugify";
    version = "0.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "xXA8wRwaaUdTbzzouzBnZri7WoSlNxf1pwPODxgjXkw=";
    };
    meta = with lib; {
      homepage = "http://github.com/zacharyvoase/slugify";
      description = "A generic slugifier";
      #license = licenses.UNKNOWN;
    };
  };

  python-gettext = my-python.pkgs.buildPythonPackage rec {
    pname = "python-gettext";
    version = "4.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "YmtQGlGsiS/DRgz1UOYNyhIfVE6qRutpyQzkaC/H7AI=";
    };
    meta = with lib; {
      homepage = "https://pypi.org/project/python-gettext/";
      description = "Python Gettext po to mo file compiler";
      license = licenses.bsdOriginal;
    };
  };

  multipart = my-python.pkgs.buildPythonPackage rec {
    pname = "multipart";
    version = "0.2.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "BrogU2C8cJb+/mGOTx6bLNuJC08hVwU6gfOGkSolIss=";
    };
    meta = with lib; {
      homepage = "https://pypi.org/project/python-gettext/";
      description = "Parser for multipart/form-data";
      license = licenses.mit;
    };
  };

  zope_tal = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.tal";
    version = "4.5";
    src = fetchPypi {
      inherit pname version;
      sha256 = "pD+dwCnSADJHsFnkZIDfmX1QGO9jiMXiWnJyms6sjQs=";
    };
    checkInputs = [  ] ++ (with my-python.pkgs; [
      zope_testrunner
    ]);
    doCheck = false; # ModuleNotFoundError: No module named 'zope.testrunner'
    propagatedBuildInputs = [ python-gettext ] ++ (with my-python.pkgs; [
      zope_i18nmessageid
      zope_interface
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.tal";
      description = "Zope tal";
      license = licenses.zpl21;
    };
  };

  zope_tales = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.tales";
    version = "5.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "VxHAxfGF+8SqKLWi3tWXxsWJKuintfoOUxZGKekf7v4=";
    };
    checkInputs = [  ] ++ (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = [ python-gettext ] ++ (with my-python.pkgs; [
      zope_interface
      six
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.browser";
      description = "Zope browser";
      license = licenses.zpl21;
    };
  };

  zope_browser = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.browser";
    version = "2.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "p1WAGTfYJTGn7BUlM5/JqH9YzWQqAEK1GygKwxoGcRM=";
    };
    doCheck = false; # ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = [ python-gettext ] ++ (with my-python.pkgs; [
      zope_interface
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.browser";
      description = "Zope browser";
      license = licenses.zpl21;
    };
  };

  zope_publisher = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.publisher";
    version = "6.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "u2HvrByh4Chd1STyIvX8uabk3CZ01yPBYdjTJTfvdag=";
    };
    checkInputs = [  ] ++ (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = [ python-gettext zope_browser multipart ] ++ (with my-python.pkgs; [
      zope_proxy
      zope_exceptions
      zope_location
      zope_configuration
      zope_contenttype
      zope_security
      zope_i18n
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.publisher";
      description = "Zope publisher";
      license = licenses.zpl21;
    };
  };

  zope_i18n = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.i18n";
    version = "4.9.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "3mgNVFRV5lW+lCzxa90DMLI4qlqBAlJeYEF04zDaxZE=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    doCheck = false; # FIXME infinite recursion: zope_i18n - zope_publisher
    propagatedBuildInputs = (with my-python.pkgs; [
      python-gettext
      zope_deprecation
      pytz
      zope_schema
      zope_i18nmessageid
      zope_component
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.i18n";
      description = "Zope i18n";
      license = licenses.zpl21;
    };
  };

  zope_browserresource = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.browserresource";
    version = "4.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "B9N4BqCwRir8NhwgiZVvjCSMGN4jOUoym+zGuvQA5hU=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.testrunner'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_traversing
      zope_component
      zope_location
      zope_contenttype
      zope_configuration
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.browserresource";
      description = "Zope browserresource";
      license = licenses.zpl21;
    };
  };

  zope_traversing = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.traversing";
    version = "4.4.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "My7+7byLj3mlvWMKB3juO9kfmS042WZ6d5yc9xiEf48=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      zope_tales
    ]);
    doCheck = false; # FIXME infinite recursion: zope_traversing - zope_browserresource
    propagatedBuildInputs = [
      zope_publisher
    ] ++ (with my-python.pkgs; [
      zope_proxy
      transaction
      zope_location
      zope_i18nmessageid
      zope_security
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.traversing";
      description = "Zope traversing";
      license = licenses.zpl21;
    };
  };

  zope_pagetemplate = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.pagetemplate";
    version = "4.6.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "j7qaBDfIl2kbRLboVj7roBpbZCZXiYzU1WzwsKWenmE=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_i18n
      zope_tales
      zope_tal
      zope_traversing
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.pagetemplate";
      description = "Zope pagetemplate";
      license = licenses.zpl21;
    };
  };

  zope_security = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.security";
    version = "5.1.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "ENRIn6iKJOZxY670T8SRDIu/WR9GFpa6cky/yI7hjoY=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      zope_configuration
      BTrees
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_proxy
      zope_schema
      zope_i18nmessageid
      zope_component
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.security";
      description = "Zope security";
      license = licenses.zpl21;
    };
  };

  zope_browsermenu = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.browsermenu";
    version = "4.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "mfXDvvn01D6dZf99LGs96XNS/J0t48u8xH/OYx9vvQo=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = [
      zope_pagetemplate
    ] ++ (with my-python.pkgs; [
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.browsermenu";
      description = "Zope browsermenu";
      license = licenses.zpl21;
    };
  };

  zExceptions = my-python.pkgs.buildPythonPackage rec {
    pname = "zExceptions";
    version = "4.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "vvM0ysUj5ngVkDXYBVx6/y/d5lgp8y6efNy8fZpuemU=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_publisher
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zExceptions";
      description = "Zope Exceptions";
      license = licenses.zpl21;
    };
  };

  zope_sequencesort = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.sequencesort";
    version = "4.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "4ce8RqUjEaoE7CqQnxZaq84xfCVxKQ84D8LzinV8x6k=";
    };
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.sequencesort";
      description = "Zope sequencesort";
      license = licenses.zpl21;
    };
  };

  zope_browserpage = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.browserpage";
    version = "4.4.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "WO1x6QzL1JFk9RzIVIjPEFhCDAlQVnXU38DoprsUCZs=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.testrunner'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_pagetemplate
      zope_browsermenu
      zope_component
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.browserpage";
      description = "Zope browserpage";
      license = licenses.zpl21;
    };
  };

  ZConfig = my-python.pkgs.buildPythonPackage rec {
    pname = "ZConfig";
    version = "3.6.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "oo6VoK4zV5V0fsytNbLLcI831Ex/Ml4qyyAemDMLFuU=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      manuel
      docutils
      pygments
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/ZConfig";
      description = "Structured Configuration Library";
      license = licenses.zpl21;
    };
  };

  ZODB = my-python.pkgs.buildPythonPackage rec {
    pname = "ZODB";
    version = "5.6.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "RlT7VDOTUzKRz7+K37TqJlj/OFhx1Lkm1yVQgULLB/4=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      manuel
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      ZConfig
      transaction
      persistent
      BTrees
      zc_lockfile
      zodbpickle
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/ZODB";
      description = "object-oriented database";
      license = licenses.zpl21;
    };
  };

  AuthEncoding = my-python.pkgs.buildPythonPackage rec {
    pname = "AuthEncoding";
    version = "4.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "UlbAQWQxVDnhPTBJQHCElZgY5KAbQYzun8dgaZob8IE=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      six
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/AuthEncoding";
      description = "Framework for handling LDAP style password hashes";
      license = licenses.zpl21;
    };
  };

  ExtensionClass = my-python.pkgs.buildPythonPackage rec {
    pname = "ExtensionClass";
    version = "4.6";
    src = fetchPypi {
      inherit pname version;
      sha256 = "Z6PseK7Ld/XTH5hOsW1VBViCCeWQurtx/pNKMaPXbZg=";
    };
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/ExtensionClass";
      description = "Metaclass for subclassable extension types";
      license = licenses.zpl21;
    };
  };

  Persistence = my-python.pkgs.buildPythonPackage rec {
    pname = "Persistence";
    version = "3.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "6EeX54ZG7CCFQ7K4qxWx/ZnHVILiTPKzU0UmyU7zw3A=";
    };
    propagatedBuildInputs = [
      ExtensionClass
    ] ++ (with my-python.pkgs; [
      persistent
      six
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/Persistence";
      description = "Persistent ExtensionClass";
      license = licenses.zpl21;
    };
  };

  DateTime = my-python.pkgs.buildPythonPackage rec {
    pname = "DateTime";
    version = "4.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "B0sMY9Qyj03jBmJ4b6Q2oFZxRbKrAvR75a9o9Yr8A+w=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      pytz
      zope_interface
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/DateTime";
      description = "DateTime data type for Zope API";
      license = licenses.zpl21;
    };
  };

  RestrictedPython = my-python.pkgs.buildPythonPackage rec {
    pname = "RestrictedPython";
    version = "5.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "Y02h9sXBIqJi9DOwg+49F6mgOfjxs3eFl++0dGHNNhs=";
    };
    checkInputs = (with my-python.pkgs; [
      pytest-mock
      pytest
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/RestrictedPython";
      description = "run untrusted Python code in a limited Python interpreter";
      license = licenses.zpl21;
    };
  };

  zope_cachedescriptors = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.cachedescriptors";
    version = "4.3.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "H00acC8uo9F3of+0BCNVUbuFVgEA7IjmyYaRc0sdGUo=";
    };
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.cachedescriptors";
      description = "Method and property caching decorators";
      license = licenses.zpl21;
    };
  };

  zope_annotation = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.annotation";
    version = "4.7.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "tAVnzySmWkIEsZrxyVcjqCCc3cKr2jpiYyxJU8d2sYU=";
    };
    doCheck = false; # FIXME AttributeError: module '__main__' has no attribute 'alltests'
    # WARNING: Testing via this command is deprecated and will be removed in a future version.
    # Users looking for a generic test entry point independent of test runner are encouraged to use tox.
    checkInputs = [
    ] ++ (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_proxy
      zope_location
      zope_component
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.annotation";
      description = "annotate objects";
      license = licenses.zpl21;
    };
  };

  zope_container = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.container";
    version = "4.5.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "6unwuK8d7pxEqhJjRg2Lc5rQqRHrRRCf1njDhysqnNs=";
    };
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_cachedescriptors
      zope_proxy
      persistent
      zope_dottedname
      zope_i18nmessageid
      zope_traversing
      zope_lifecycleevent
      zope_size
      BTrees
      zope_filerepresentation
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.site";
      description = "interfaces of container components for Zope";
      license = licenses.zpl21;
    };
  };

  zope_site = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.site";
    version = "4.5.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "9REuVXzvTA2A/Xpcxpb2AhyNBkaRlQbJfShRLISAsn4=";
    };
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_container
      zope_annotation
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.site";
      description = "Local registries for zope component architecture";
      license = licenses.zpl21;
    };
  };

  zope_contentprovider = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.contentprovider";
    version = "4.2.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "EqBTN1tjfJ9hq+egSwOZVlqKtvrUEOZQyj5NXDegf+I=";
    };
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_tales
      zope_publisher
      zope_event
      zope_interface
      zope_schema
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.contentprovider";
      description = "Content Provider Framework for Zope Templates";
      license = licenses.zpl21;
    };
  };

  zope_processlifetime = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.processlifetime";
    version = "2.3.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "059CCtUkgpEXLF3s6AGeUD4ift2d5Zdo6Zw0GVJFB88=";
    };
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_interface
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.processlifetime";
      description = "Zope process lifetime events";
      license = licenses.zpl21;
    };
  };

  Acquisition = my-python.pkgs.buildPythonPackage rec {
    pname = "Acquisition";
    version = "4.10";
    src = fetchPypi {
      inherit pname version;
      sha256 = "vzYzMXakZxtLl0qzq9b/Ufz5/Hr5FIRYFCavVFqxoIU=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      ExtensionClass
      zope_interface
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/Acquisition";
      description = "allow objects to discover their parent objects";
      license = licenses.zpl21;
    };
  };

  zope_viewlet = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.viewlet";
    version = "4.2.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "LYkq8xPXpg9/v1jiDmWE/5yJbde9/Le70M9BWGLXkOo=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      zope_component
      #manuel
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.component'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_event
      zope_interface
      zope_location
      zope_i18nmessageid
      zope_configuration
      zope_contentprovider
      zope_browserpage
      zope_size
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.viewlet";
      description = "framework for building pluggable user interfaces";
      license = licenses.zpl21;
    };
  };

  AccessControl = my-python.pkgs.buildPythonPackage rec {
    pname = "AccessControl";
    version = "5.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "aPer0XuRiEKdm+tl9Xkdx6GPf2XNUQX2ul9NReh3z/E=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zExceptions
      AuthEncoding
      Persistence
      DateTime
      RestrictedPython
      Acquisition
      zope_deferredimport
      transaction
      BTrees
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/AccessControl";
      description = "Security framework for Zope";
      license = licenses.zpl21;
    };
  };

  zope_datetime = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.datetime";
    version = "4.3.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "FKvt9lDA8JUYhR0ibYp4UAFn6XqENaHEsQGJVMHovPM=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      six
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.datetime";
      description = "parse and format date/time strings";
      license = licenses.zpl21;
    };
  };

  z3c_pt = my-python.pkgs.buildPythonPackage rec {
    pname = "z3c.pt";
    version = "3.3.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "I4vP20Y0PxFEfm+rofeAa46OQDAvdq5Dwm6ssohUZ28=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_i18n
      zope_contentprovider
      zope_traversing
      chameleon
      six
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/z3c.pt";
      description = "ZPT template engine for Zope 3 which uses Chameleon to compile templates to byte-code";
      license = licenses.zpl21;
    };
  };

  zope_ptresource = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.ptresource";
    version = "4.3.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "2wz49iT2Z110AgrCa0BrxiJlOAWNpVA+sAa+AgBX9Pg=";
    };
    checkInputs = [
    ] ++ (with my-python.pkgs; [
      zope_testrunner
      zope_component
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.component'
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_pagetemplate
      zope_browserresource
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.globalrequest";
      description = "Page template resource plugin for zope.browserresource";
      license = licenses.zpl21;
    };
  };

  zope_globalrequest = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.globalrequest";
    version = "1.5";
    src = fetchPypi {
      inherit pname version;
      sha256 = "EuoQZBD0rXb974YmYfakmn/u7TNf4MNz7cavzlZOWD4=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_publisher
      zope_traversing
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.globalrequest";
      description = "retrieve the currently active request object in a zope-based web framework";
      license = licenses.zpl21;
    };
  };

  MultiMapping = my-python.pkgs.buildPythonPackage rec {
    pname = "MultiMapping";
    version = "4.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "OBxMihkzqA/t+EOgDB+pEJSnzniXqheVUfjC0+xehcs=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      ExtensionClass
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/MultiMapping";
      description = "Special MultiMapping objects used in Zope";
      license = licenses.zpl21;
    };
  };

  WSGIProxy2 = my-python.pkgs.buildPythonPackage rec {
    pname = "WSGIProxy2";
    version = "0.5.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "DZ7LFB3nIOL9T3onWkqDqWH/62cXSD2UACH/ocRvZlw=";
    };
    checkInputs = (with my-python.pkgs; [
      webtest
      urllib3
      requests
    ]);
    propagatedBuildInputs = (with my-python.pkgs; [
      WebOb
    ]);
    meta = with lib; {
      homepage = "https://github.com/gawel/WSGIProxy2";
      description = "A WSGI Proxy with various http client backends";
      license = licenses.mit;
    };
  };

  WebTest = my-python.pkgs.buildPythonPackage rec {
    pname = "WebTest";
    version = "3.0.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "VL2WlyWDjZhhqfon+Nlx950nXZSuJV9cUB9Tu22ZKes=";
    };
    checkInputs = (with my-python.pkgs; [
      pytest-cov
      pyquery
    ]);
    propagatedBuildInputs = [
    ] ++ (with my-python.pkgs; [
      WebOb
      waitress
      beautifulsoup4
      WSGIProxy2
      PasteDeploy
    ]);
    meta = with lib; {
      homepage = "https://github.com/Pylons/webtest";
      description = "Helper to test WSGI applications";
      license = licenses.mit;
    };
  };

  zope_testbrowser = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.testbrowser";
    version = "5.6.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "A1v2PZ9yROiFeGwzJ0SKfZ//Uh26WWQpaYuEdJYbBec=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testrunner
      zope_interface
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface' -> tox
    propagatedBuildInputs = (with my-python.pkgs; [
      zope_cachedescriptors
      pytz
      zope_schema
      WSGIProxy2
      WebTest
      mock
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.testbrowser";
      description = "Programmable browser for functional black-box tests";
      license = licenses.zpl21;
    };
  };

  zope_sqlalchemy = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.sqlalchemy";
    version = "1.6";
    src = fetchPypi {
      inherit pname version;
      sha256 = "nFO+mlcnVWZZWtp5vf/NYkoS/PZDX25oB0FlQbkS9as=";
    };
    checkInputs = (with my-python.pkgs; [
      zope_testing
      zope_interface
    ]);
    doCheck = false; # FIXME ModuleNotFoundError: No module named 'zope.interface'
    propagatedBuildInputs = (with my-python.pkgs; [
      transaction
      SQLAlchemy
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.sqlalchemy";
      description = "Minimal Zope/SQLAlchemy transaction integration";
      license = licenses.zpl21;
    };
  };

  zope_structuredtext = my-python.pkgs.buildPythonPackage rec {
    pname = "zope.structuredtext";
    version = "4.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "WejKxz5NfjW5JBG7XRTP7wrGUfSVzr34PwY/OWq8op4=";
    };
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/zope.structuredtext";
      description = "StructuredText parser";
      license = licenses.zpl21;
    };
  };

  DocumentTemplate = my-python.pkgs.buildPythonPackage rec {
    pname = "DocumentTemplate";
    version = "4.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "68iX+JaFSlbl8OKigocBahaasaIKVroESiMiCq251dk=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      RestrictedPython
      roman
      AccessControl
      zope_sequencesort
      zope_structuredtext
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/DocumentTemplate";
      description = "Document Templating Markup Language (DTML)";
      license = licenses.zpl21;
    };
  };

  Zope = my-python.pkgs.buildPythonPackage rec {
    pname = "Zope";
    version = "5.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "wK+fB6gwRHR1S6KKHAPWJkBWfBfMVh5LWYMPgLlq9qI=";
    };
    propagatedBuildInputs = (with my-python.pkgs; [
      DocumentTemplate
      ZODB
      zope_browserpage
      zExceptions
      zope_sequencesort
      AccessControl
      zope_processlifetime
      zope_contentprovider
      zope_site
      zope_viewlet
      zope_datetime
      z3c_pt
      zope_browserresource
      zope_globalrequest
      zope_ptresource
      MultiMapping
      zope_testbrowser
    ]);
    meta = with lib; {
      homepage = "https://github.com/zopefoundation/Zope";
      description = "Zope application server / web framework";
      license = licenses.zpl21;
    };
  };
in

python-with-my-packages.env
