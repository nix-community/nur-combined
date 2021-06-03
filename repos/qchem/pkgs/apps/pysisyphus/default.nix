{ fetchPypi, fetchFromGitHub, buildPythonPackage, lib, writeTextFile, writeScript, makeWrapper,
 # Python dependencies
 autograd, dask, distributed, h5py, jinja2, matplotlib, numpy, natsort, pytest, pyyaml, rmsd, scipy,
 sympy, scikitlearn, qcengine, ase, xtb-python, openbabel-bindings,
 # Runtime dependencies
 runtimeShell, jmol, multiwfn, xtb, openmolcas, pyscf, psi4, wfoverlap, nwchem, orca ? null ,
 turbomole ? null, gaussian ? null, gamess-us ? null, cfour ? null, molpro ? null,
 # Test dependencies
 openssh,
 # Configuration
 fullTest ? false
}:
let
  psi4Wrapper = writeScript "psi4.sh" ''
    #!${runtimeShell}
    ${psi4}/bin/psi4 -o stdout $1
  '';
  pysisrc =
    let
      gaussian16Conf = {
        cmd = "${gaussian}/bin/g16";
        formchk_cmd = "${gaussian}/bin/formchk";
        unfchk_cmd = "${gaussian}/bin/unfchk";
      };
      text = with lib.lists; lib.generators.toINI {} (builtins.listToAttrs ([
        { name = "openmolcas"; value.cmd = "${openmolcas}/bin/pymolcas"; }
        { name = "psi4"; value.cmd = "${psi4Wrapper}"; }
        { name = "wfoverlap"; value.cmd = "${wfoverlap}/bin/wfoverlap.x"; }
        { name = "multiwfn"; value.cmd = "${multiwfn}/bin/Multiwfn"; }
        { name = "jmol"; value.cmd = "${jmol}/bin/jmol"; }
        { name = "xtb"; value.cmd = "${xtb}/bin/xtb"; }
      ] ++ optional (gaussian != null) { name = "gaussian16"; value = gaussian16Conf; }
        ++ optional (orca != null) { name = "orca"; value.cmd = "${orca}/bin/orca"; }
      ));
    in
      writeTextFile {
        inherit text;
        name = "pysisrc";
      };

  binSearchPath = with lib; makeSearchPath "bin" ([
    jmol
    multiwfn
    xtb
    openmolcas
    pyscf
    psi4
    wfoverlap
    nwchem
  ] ++ lists.optional (orca != null) orca
    ++ lists.optional (turbomole != null) turbomole
    ++ lists.optional (gaussian != null) gaussian
    ++ lists.optional (cfour != null) cfour
    ++ lists.optional (molpro != null) molpro
  );

in
  buildPythonPackage rec {
    pname = "pysisyphus";
    version = "0.7rc1";

    nativeBuildInputs = [ makeWrapper ];

    propagatedBuildInputs = with lib; [
      autograd
      dask
      distributed
      h5py
      jinja2
      matplotlib
      numpy
      natsort
      pyyaml
      rmsd
      scipy
      sympy
      scikitlearn
      qcengine
      ase
      xtb-python
      openbabel-bindings
      pytest # Also required for normal execution
      # Syscalls
      jmol
      multiwfn
      xtb
      openmolcas
      pyscf
      psi4
      wfoverlap
      nwchem
    ] ++ lists.optional (orca != null) orca
      ++ lists.optional (turbomole != null) turbomole
      ++ lists.optional (gaussian != null) gaussian
      ++ lists.optional (cfour != null) cfour
      ++ lists.optional (molpro != null) molpro
    ;

    src = fetchFromGitHub {
      owner = "eljost";
      repo = pname;
      rev = version;
      sha256 = "19jwn2hprawz652z0q4d716z2gyb2l3vhjkxn4rjr0dhz5ps4nw2";
    };

    doCheck = true;

    checkInputs = [ pytest openssh ];

    checkPhase = ''
      export PYSISRC=${pysisrc}
      export PATH=$PATH:${binSearchPath}
      export OMPI_MCA_rmaps_base_oversubscribe=1

      echo $PYSISRC

      ${if fullTest
          then "pytest -v tests --disable-warnings"
          else "pytest -v --pyargs pysisyphus.tests --disable-warnings"
      }
    '';

    postInstall = ''
      mkdir -p $out/share/pysisyphus
      cp ${pysisrc} $out/share/pysisyphus/pysisrc
      for exe in $out/bin/*; do
        wrapProgram $exe \
          --prefix PATH : ${binSearchPath} \
          --set-default "PYSISRC" "$out/share/pysisyphus/pysisrc"
      done
    '';

    meta = with lib; {
      description = "Python suite for optimization of stationary points on ground- and excited states PES and determination of reaction paths";
      homepage = "https://github.com/eljost/pysisyphus";
      license = licenses.gpl3;
      platforms = platforms.linux;
      maintainers = [ maintainers.sheepforce ];
    };
  }
