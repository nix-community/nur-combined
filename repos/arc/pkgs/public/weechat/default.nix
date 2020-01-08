{
  weechat-matrix-contrib = { python3Packages, lib }: python3Packages.buildPythonApplication rec {
    pname = "weechat-matrix-contrib";
    inherit (python3Packages.weechat-matrix) version src;

    propagatedBuildInputs = with python3Packages; [ python_magic requests matrix-nio ];

    format = "other";

    postPatch = ''
      substituteInPlace contrib/matrix_upload \
        --replace "env -S " ""
    '';

    buildPhase = "true";
    installPhase = ''
      install -Dm0755 -t $out/bin contrib/matrix_{upload,decrypt}
    '';
    meta.broken = lib.isNixpkgsStable;
  };
}
