{ fetchFromGitHub, lib, python3Packages }: with python3Packages; let
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "54de7f94750ee217907c3ce427430043fec27514";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = version;
      sha256 = "0g82mqvkr7hp4j5nn330linszsbh8b7sx7l7554x9j5i40m93vsm";
    };

    postPatch = ''
      sed -i -e '/alembic>/d' setup.py
    '';

    propagatedBuildInputs = [
      aiohttp
      sqlalchemy
      ruamel_yaml
      python_magic
      hangups
      mautrix-python
      setuptools
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
