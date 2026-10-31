new: old: {
  pythonPackagesExtensions = old.pythonPackagesExtensions ++ [
    (newpy: oldpy: {
      # pillow 13 rejects an explicit "I;16" mode in fromarray
      pillow-jpls = oldpy.pillow-jpls.overridePythonAttrs (oldAttrs: {
        postPatch = oldAttrs.postPatch + ''
          substituteInPlace test/test_image_formats.py \
            --replace-fail 'Image.fromarray(data, mode)' 'Image.fromarray(data, None if mode == "I;16" else mode)'
        '';
      });
    })
  ];
}
