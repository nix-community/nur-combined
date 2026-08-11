{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, fetchurl
, pythonOlder
, substituteAll

# build
, setuptools

# patched in
, geos
, gdal
, withGdal ? false

# propagates
, asgiref
, platformdirs
, sqlparse

# extras
, argon2-cffi
, bcrypt

# tests
, aiosmtpd
, docutils
, geoip2
, jinja2
, numpy
, pillow
, pylibmc
, pymemcache
, python
, pywatchman
, pyyaml
, pytz
, redis
, selenium
, tblib
, tzdata
}:

buildPythonPackage rec {
  pname = "Django";
  version = "5.0.1";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jIZZZlvG46RP7+GrCikeWj+zl5+agjC+Kd6XXlfo+FQ=";
  };

  # fix: 1 out of 1 hunk FAILED -- saving rejects to file setup.cfg.rej
  # convert tab-indent to space-indent
  # https://github.com/pypa/setuptools/issues/3672

  prePatch = ''
    sed -i 's/\t/    /g' setup.cfg
  '';

  patches = [
    (substituteAll {
      src = ./django_5_set_zoneinfo_dir.patch;
      zoneinfo = tzdata + "/share/zoneinfo";
    })
    # prevent tests from messing with our pythonpath
    ./django_5_tests_pythonpath.patch
    # disable test that excpects timezone issues
    ./django_5_disable_failing_tests.patch
    # https://github.com/django/django/pull/17815
    # fix: django.db.utils.OperationalError: no such column: django_migrations.id
    (fetchurl {
      url = "https://github.com/milahu/django/commit/d765cd349e6371a2d1e3277e1b8db550776a681b.patch";
      hash = "sha256-oad4HKiKKAe5By0En2W7TCH6e/wt7roMlOhBUXOKFy4=";
    })
    # https://github.com/django/django/pull/17816
    # fix: PermissionError: Permission denied: site-packages
    (fetchurl {
      url = "https://github.com/milahu/django/commit/8eab1178f218b8dc3f4ce9c498811a37617a2365.patch";
      hash = "sha256-C6rW2pKvtJEt9FkxolS3W9kpuOkSGKoZrJPzJrDwml0=";
    })
  ] ++ lib.optionals withGdal [
    (substituteAll {
      src = ./django_5_set_geos_gdal_lib.patch;
      geos = geos;
      gdal = gdal;
      extension = stdenv.hostPlatform.extensions.sharedLibrary;
    })
  ];

  postPatch = ''
    substituteInPlace tests/utils_tests/test_autoreload.py \
      --replace "/usr/bin/python" "${python.interpreter}"
  '';

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    asgiref
    platformdirs
    sqlparse
  ];

  passthru.optional-dependencies = {
    argon2 = [
      argon2-cffi
    ];
    bcrypt = [
      bcrypt
    ];
  };

  nativeCheckInputs = [
    # tests/requirements/py3.txt
    aiosmtpd
    docutils
    geoip2
    jinja2
    numpy
    pillow
    pylibmc
    pymemcache
    pywatchman
    pyyaml
    pytz
    redis
    selenium
    tblib
    tzdata
  ] ++ lib.flatten (lib.attrValues passthru.optional-dependencies);

  doCheck = !stdenv.isDarwin;

  preCheck = ''
    # make sure the installed library gets imported
    rm -rf django

    # provide timezone data, works only on linux
    export TZDIR=${tzdata}/${python.sitePackages}/tzdata/zoneinfo
  '';

  checkPhase = ''
    runHook preCheck

    pushd tests
    ${python.interpreter} runtests.py --settings=test_sqlite
    popd

    runHook postCheck
  '';

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    changelog = "https://docs.djangoproject.com/en/${lib.versions.majorMinor version}/releases/${version}/";
    description = "A high-level Python Web framework that encourages rapid development and clean, pragmatic design.";
    homepage = "https://www.djangoproject.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [ hexa ];
  };
}
