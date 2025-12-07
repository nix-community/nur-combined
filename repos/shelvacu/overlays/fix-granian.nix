new: old: {
  pythonPackagesExtensions = old.pythonPackagesExtensions ++ [
    (newpy: oldpy: {
      granian = oldpy.granian.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ (new.fetchpatch {
          url = "https://github.com/emmett-framework/granian/commit/189f1bed2effb4a8a9cba07b2c5004e599a6a890.diff";
          hash = "sha256-OkbeZjGzsZQFe98hPooUVyaNrxUiKzeFGPpwm6+sVMs=";
        })];
      });
    })
  ];
}
