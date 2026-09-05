{
  lib,
  peazip,
  _7zz-rar,
}:

(peazip.override {
  _7zz = _7zz-rar;
}).overrideAttrs
  (old: {
    pname = "peazip-rar";

    postInstall = (old.postInstall or "") + ''
      ln -s ${lib.getExe _7zz-rar} $out/bin/7z
    '';

    meta = old.meta // {
      description = "File and archive manager with RAR extraction support";
      license = [
        old.meta.license
        lib.licenses.unfreeRedistributable
      ];
    };
  })
