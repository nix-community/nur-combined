new: old: {
  pythonPackagesExtensions = old.pythonPackagesExtensions ++ [
    (newpy: oldpy: {
      vacu-dnspython = oldpy.dnspython.overrideAttrs (oldAttrs: {
        src = new.dnspython-src;

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ newpy.uv-build ];
      });
    })
  ];
}
