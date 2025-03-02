{
  callPackage,
  source,
  src ? source.src,
  pname ? source.pname,
  version ? source.version,
  otherArgs ? { },
  transform ? (x: x),
  addIFDAsBuildInput ? true,
}:
let
  originPkg = transform (callPackage src otherArgs);
in
originPkg.overrideAttrs {
  name = "${pname}-${version}";
  inherit pname version;
  # make src besome a build input of result package, so that src would not be garbage collected when `keep-outputs` is set
  buildInputs =
    if addIFDAsBuildInput then
      (originPkg.buildInputs or [ ])
      ++ [
        src
      ]
    else
      [ ];
}
