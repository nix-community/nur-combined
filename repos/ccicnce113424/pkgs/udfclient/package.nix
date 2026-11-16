{
  lib,
  stdenv,
  fetchzip,
  bmake,
  installShellFiles,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "udfclient";
  version = "0.8.21";

  src = fetchzip {
    url = "http://www.13thmonkey.org/udfclient/releases/UDFclient.${finalAttrs.version}.tgz";
    hash = "sha256-1/QyFylUiEhP5VlaDt1OkwPg2gBfnSpuGqj5nY2yGDQ=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    bmake
    installShellFiles
  ];

  strictDeps = true;
  __structuredAttrs = true;

  enableParallelBuilding = true;

  postInstall = ''
    installManPage mmc_format.8 newfs_udf.8
  '';

  meta = {
    description = "Userland tools for reading and writing UDF filesystems";
    homepage = "http://www.13thmonkey.org/udfclient/";
    license = lib.licenses.clArtistic;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "udfclient";
    platforms = lib.platforms.unix;
  };
})
