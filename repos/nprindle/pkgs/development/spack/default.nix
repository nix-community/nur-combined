{ stdenv, fetchFromGitHub, makeWrapper
, python
}:

stdenv.mkDerivation rec {
  pname = "spack";
  version = "0.15.3";
  src = fetchFromGitHub {
    owner = "spack";
    repo = "spack";
    rev = "v${version}";
    sha256 = "02vddqfrl40x2lqwqi1gqrv2fmj31ig1dypc45w44xykkng63jjl";
  };

  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ python ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp -r lib "$out"
    cp -r share "$out"
    cp -r var "$out"

    # The original spack bilingual shell/python file
    cp bin/spack "$out/bin/.spack-base"

    # Wrap it to avoid the bilingual nonsense
    makeWrapper \
      "${python}/bin/python" \
      "$out/bin/.spack-python-wrapper" \
      --add-flags "$out/bin/.spack-base"

    # Copy spack() wrapper function from setup-env.sh to separate file
    cp "${./spack_wrapper.sh}" "$out/bin/spack"

    # Substitute in path to python-wrapped spack executable
    substituteInPlace "$out/bin/spack" \
      --subst-var-by spack "$out/bin/.spack-python-wrapper"

    wrapProgram \
      "$out/bin/spack" \
      --set SPACK_ROOT "$out" \
      --set _sp_prefix "$out" \
      --set _sp_share_dir "$out/share/spack" \
      --set _sp_tcl_roots "$out/share/spack/modules" \
      --set _sp_lmod_roots "$out/share/spack/lmod"
  '';

  meta = with stdenv.lib; {
    description = "A flexible package manager that supports multiple versions, configurations, platforms, and compilers";
    homepage = "https://github.com/spack/spack";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
