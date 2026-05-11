{
  buildLakePackage,
  source,
}:
buildLakePackage {
  pname = "lean4-${source.pname}";
  inherit (source) src version;
  leanPackageName = source.pname;

  doCheck = true;
  checkPhase = ''
    lake test
  '';
}
