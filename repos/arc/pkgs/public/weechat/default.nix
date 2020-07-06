{
  weechat-matrix-contrib = { python3Packages, lib }: python3Packages.buildPythonApplication rec {
    pname = "weechat-matrix-contrib";
    inherit (python3Packages.weechat-matrix) version src;

    propagatedBuildInputs = with python3Packages; [ python_magic requests matrix-nio aiohttp ];

    format = "other";

    postPatch = ''
      substituteInPlace contrib/matrix_upload.py \
        --replace "env -S " ""
      substituteInPlace contrib/matrix_sso_helper.py \
        --replace "env -S " ""
    '';

    buildPhase = "true";
    installPhase = ''
      install -Dm0755 contrib/matrix_upload.py $out/bin/matrix_upload
      install -Dm0755 contrib/matrix_decrypt.py $out/bin/matrix_decrypt
      install -Dm0755 contrib/matrix_sso_helper.py $out/bin/matrix_sso_helper
    '';
    meta.broken = lib.isNixpkgsStable;
  };
}
