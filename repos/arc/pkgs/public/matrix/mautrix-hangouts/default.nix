{ fetchFromGitHub, fetchpatch, lib, python3Packages, e2be ? true }: with python3Packages; let
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "0.1.1";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = "v${version}";
      sha256 = "0xj5ykfixy58dsqyky6ds8fh84chbywlnq8khmwkz4m9bx2vr2fy";
    };

    patches = [ (fetchpatch {
      url = "https://github.com/tulir/mautrix-hangouts/commit/184937965ee28dd8b8a823015f48e6fc3ec341ee.patch";
      sha256 = "1fbg7ykchf4akkb62f0ngwayzvvihww4hqddfbc574qm49r8rc4h";
    }) ];

    postPatch = ''
      sed -i -e '/alembic>/d' requirements.txt
    '';

    propagatedBuildInputs = [
      aiohttp
      sqlalchemy
      ruamel_yaml
      CommonMark
      python_magic
      hangups
      mautrix-python
      setuptools
    ] ++ lib.optionals e2be [
      asyncpg
      olm
      pycryptodome
      unpaddedbase64
    ];

    doCheck = false;
  };
in lib.drvPassthru (drv: {
  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-telegram`
  # in its environment to create a database schema from all models.
  alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ drv ];
  });
}) drv
