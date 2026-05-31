{
  lib,
  fetchFromGitHub,
  makeWrapper,
  writeShellScript,
  python3Packages,
  cogeo-mosaic,
  geojson-pydantic,
  rio-cogeo,
  rio-stac,
  starlette-cramjam,
}:
let
  pname = "titiler";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "titiler";
    tag = version;
    hash = "sha256-Jh5DLzZCe37FSVbtBqeaIGZfK6awF1ymtl3KB6am9bs=";
  };

  meta = {
    description = "A modern dynamic tile server built on top of FastAPI and Rasterio/GDAL";
    homepage = "https://developmentseed.org/titiler/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };

  titiler-core = python3Packages.buildPythonPackage (finalAttrs: {
    inherit version src meta;
    pname = "${pname}.core";
    sourceRoot = "${src.name}/src/titiler/core";
    pyproject = true;

    build-system = with python3Packages; [ hatchling ];

    pythonRelaxDeps = true;

    dependencies = with python3Packages; [
      fastapi
      geojson-pydantic
      jinja2
      numpy
      pydantic
      rasterio
      rio-tiler
      morecantile
      simplejson
      typing-extensions
    ];

    optional-dependencies = {
      telemetry = with python3Packages; [
        opentelemetry-api
        opentelemetry-sdk
        opentelemetry-instrumentation-fastapi
        opentelemetry-instrumentation-logging
        opentelemetry-exporter-otlp
      ];
    };

    nativeCheckInputs = [
      python3Packages.pytestCheckHook
    ]
    ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);
  });

  titiler-extensions = python3Packages.buildPythonPackage (finalAttrs: {
    inherit version src meta;
    pname = "${pname}.extensions";
    sourceRoot = "${src.name}/src/titiler/extensions";
    pyproject = true;

    build-system = with python3Packages; [ hatchling ];

    dependencies = [ titiler-core ];

    optional-dependencies = {
      cogeo = [ rio-cogeo ];
      stac = [ python3Packages.rio-stac ];
    };

    nativeCheckInputs =
      with python3Packages;
      [
        jsonschema
        owslib
        pytestCheckHook
      ]
      ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

    disabledTests = [
      "test_stacExtension" # requires network
    ];
  });

  titiler-mosaic = python3Packages.buildPythonPackage (finalAttrs: {
    inherit version src meta;
    pname = "${pname}.mosaic";
    sourceRoot = "${src.name}/src/titiler/mosaic";
    pyproject = true;

    build-system = with python3Packages; [ hatchling ];

    dependencies = [
      cogeo-mosaic
      titiler-core
    ];

    optional-dependencies = {
      mosaicjson = [ cogeo-mosaic ];
    };

    nativeCheckInputs =
      with python3Packages;
      [
        owslib
        pytestCheckHook
      ]
      ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);
  });

  titiler-xarray = python3Packages.buildPythonPackage (finalAttrs: {
    inherit version src meta;
    pname = "${pname}.xarray";
    sourceRoot = "${src.name}/src/titiler/xarray";
    pyproject = true;

    build-system = with python3Packages; [ hatchling ];

    dependencies = with python3Packages; [
      titiler-core
      xarray
      rioxarray
      obstore
      zarr
      starlette-cramjam
      pydantic-settings
    ];

    optional-dependencies = {
      fs = with python3Packages; [
        h5netcdf
        h5py
        fsspec
        s3fs
        aiohttp
        gcsfs
        requests
      ];
    };

    nativeCheckInputs =
      with python3Packages;
      [
        pytestCheckHook
      ]
      ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

    disabledTests = [
      "test_io_fs_open_dataset"
      "test_io_open_zarr"
    ];
  });
in
python3Packages.buildPythonPackage (finalAttrs: {
  inherit
    pname
    version
    src
    meta
    ;
  sourceRoot = "${src.name}/src/titiler/application";
  pyproject = true;

  build-system = with python3Packages; [ hatchling ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies = with python3Packages; [
    pydantic-settings
    starlette-cramjam
    titiler-core
    titiler-core.optional-dependencies.telemetry
    titiler-extensions
    titiler-extensions.optional-dependencies.cogeo
    titiler-extensions.optional-dependencies.stac
    titiler-mosaic
    titiler-mosaic.optional-dependencies.mosaicjson
    titiler-xarray
    titiler-xarray.optional-dependencies.fs
  ];

  nativeCheckInputs = with python3Packages; [
    boto3
    pytestCheckHook
  ];

  disabledTests = [
    "test_mosaic_auth_error" # requires network
  ];

  postInstall =
    let
      start_script = writeShellScript "titiler-serve" ''
        ${lib.getExe python3Packages.uvicorn} "$@" titiler.application.main:app;
      '';
    in
    ''
      makeWrapper ${start_script} $out/bin/titiler-serve \
        --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}" \
        --prefix PYTHONPATH : "${python3Packages.makePythonPath finalAttrs.passthru.dependencies}";
    '';
})
