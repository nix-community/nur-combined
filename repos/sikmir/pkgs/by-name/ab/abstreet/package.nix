{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "abstreet";
  version = "0.3.49";

  src = fetchFromGitHub {
    owner = "a-b-street";
    repo = "abstreet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Gggio3/4QQXMoQoipIkb0rUaa+TarFmj+lJs1avFOE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "country-geocoder-0.1.0" = "sha256-s2Qg8zzL7hBMHofh785eVk+knd2DaKNEE+Ua2kcfyAQ=";
      "elevation-0.1.0" = "sha256-AHoA/NACWdguDiHGLjGvwDh37QjHc1vMk85ZLQugWmM=";
      "fast_paths-0.3.0-SNAPSHOT" = "sha256-Sq2uKuOncS4DgOGRx9zIOy24Db3X+kQxlfIIGrkXMrY=";
      "geom-0.1.0" = "sha256-qB2E/ta11GDOdMF69B7B61L/TMQwOkLJiGx0uLO2IDA=";
      "georaster-0.1.0" = "sha256-O+G2wfaoIhfoCGh3yWcQwWr11TmiVPquS2a0SAH71y4=";
      "glutin-0.28.0" = "sha256-0nsh/WzWStfTcwllJxcJhR6YY9xbMOEAf575eIT6hk8=";
      "http-range-client-0.6.0" = "sha256-mywyRRl/KYsSchRvLsuGYGnnH2uc8qrcr97wvO5/JXk=";
      "include_dir-0.6.1-alpha.0" = "sha256-WBqoxRjFF7DeskNMx1vDkSXQw9GZOMhfE1d6dcsikCw=";
      "osm-reader-0.1.0" = "sha256-7BcK7mDuNKnz8vvAFMtSZTJMZcKmttPb1PR90+I0j3s=";
      "osm2lanes-0.1.0" = "sha256-3iyORWj4l5cw9nezWkYddoB8pBC2zuPZlsMjuow7wQc=";
      "subprocess-0.2.8" = "sha256-imQZswGaE1MOTViaoSHBJDcPBvcTOYdyxoE88n4r0xg=";
      "tiff-0.9.0" = "sha256-EmAFa7gQeiZWtnQVQ/xtFhZ87Wj9OttiHuQFeL2DH0E=";
      "topojson-0.5.1" = "sha256-lsbj/StcTVmEjL+dCWFU4s2olzs/GeeVx2nThuod8Do=";
    };
  };

  nativeBuildInnputs = [
    rustPlatform.bindgenHook
  ];

  doCheck = false;

  meta = {
    description = "Transportation planning and traffic simulation software";
    homepage = "https://github.com/a-b-street/abstreet";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
})
