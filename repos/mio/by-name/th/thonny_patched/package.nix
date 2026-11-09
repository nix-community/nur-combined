{
  thonny,
}:

thonny.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace pyproject.toml \
      --replace-fail '<0.13.0' '<0.14.0'
  '';
})
