{ lib
, buildPythonPackage
, isPy27
, fetchFromGitHub
# C/build dependencies
, cmake
, openblas
, libcint
, libxc
, xcfun
# Python dependencies
, h5py
, numba
, numpy
, scipy
  # Check Inputs
, nose
, nose-exclude
}:

buildPythonPackage rec {
  pname = "pyscf";
  version = "1.7.5";

  # must download from GitHub to get the Cmake & C source files
  src = fetchFromGitHub {
    owner = "pyscf";
    repo = pname;
    rev = "v${version}";
    sha256 = "10275pxkz76xl3bxgxy445s03xn8grik7djsn4qlh00dp8f6sdf6";
  };

  disabled = isPy27;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libcint
    libxc
    openblas
    xcfun
  ];

  postPatch = ''
    mkdir -p ./pyscf/lib/deps/include ./pyscf/lib/deps/lib
    ln -s ${lib.getDev xcfun}/include/xc.h ./pyscf/lib/deps/include/xcfun.h
    ln -s ${lib.getLib xcfun}/lib/libxc.so ./pyscf/lib/deps/lib/libxcfun.so
    substituteInPlace pyscf/rt/__init__.py --replace "from tdscf import *" "from pyscf.tdscf import *"
    substituteInPlace setup.py --replace "scipy<1.5" "scipy"
  '';

  cmakeFlags = [
    # disable rebuilding/downloading the required libraries
    "-DBUILD_LIBCINT=0"
    "-DBUILD_LIBXC=0"
    "-DBUILD_XCFUN=0"
    "-DENABLE_XCFUN=1"
  ];
  # Configure CMake to build C files in pyscf/lib. Python build expects files in ./pyscf/lib/build
  preConfigure = "pushd pyscf/lib";
  postConfigure = "popd";

  # Build C dependencies, then build python package.
  preBuild = ''
    pushd pyscf/lib/build
    export LD_LIBRARY_PATH=$(pwd)/lib/deps/include:$LD_LIBRARY_PATH
    make
    popd
  '';

  propagatedBuildInputs = [
    h5py
    numba
    numpy
    scipy
  ];

  # add libcint, libxc, xcfun headers to include path.
  PYSCF_INC_DIR = lib.makeSearchPath "include" (map lib.getDev [
    libcint
    libxc
    xcfun
  ]);

  pythonImportsCheck = [ "pyscf" ];

  checkInputs = [ nose nose-exclude ];

  # from source/.travis.yml, mostly
  # Tests take about 150 mins to run
  # dftd3 disabled (requires additional library). If you want to enable it, look at pyscf #532
  # Can't get excluded tests working properly, so just disabling.
  doCheck = false;
  preCheck = ''
    # Set config used by tests to ensure reproducibility
    echo 'pbc_tools_pbc_fft_engine = "NUMPY"' > pyscf/pyscf_config.py
    export OMP_NUM_THREADS=1
    export PYSCF_CONFIG_FILE=$(pwd)/pyscf/pyscf_config.py
  '';
  checkPhase = ''
    runHook preCheck

    nosetests -v -x \
      --where=pyscf \
      --detailed-errors

    runHook postCheck
  '';
  NOSE_EXCLUDE = [
    "test_bz"
    "h2o_vdz"
    "test_mc2step_4o4e"
    "test_ks_noimport"
    "test_jk_single_kpt"
    "test_jk_hermi0"
    "test_j_kpts"
    "test_k_kpts"
    "high_cost"
    "skip"
    "call_in_background"
    "libxc_cam_beta_bug"
    "test_finite_diff_rks_eph"
    "test_finite_diff_uks_eph"
    "test_range_separated"
    # Slow tests, disabled for faster CI
    "test_nr_gks_rsh"
    "b3lypg_direct"
    "test_uks_hess"
    # TODO: CCSD iterations, CCSD lambda iterations
    "test_denisty_fit_interface"
    "test_h2o_non_hf_orbital_high_cost"
    "test_eomee1"
    "test_t3p2_intermediates_against_so"
    "test_h2o_star"
    "test_df_eeccsd"
    "test_ea_adc2*"
    "test_ea_adc3"
    "test_ip_adc2"
    "test_ip_adc3"
    "test_nr_uks_rsh"
    "test_finite_diff"
    "test_fix_spin_high_cost"
    "test_state_average"
    "test_state_specific"
    "test_mc1step"
    "test_mc2step"
    "test_hybrid_grad"
    "test_j_kpts"
    "test_k_kpts"
    "test_assign_cderi"
    "test_n3"
    "high_cost"
    "test_gga_grad"
    "test_casci_from_uhf1"
    "test_jk_hermi0"
    "test_jk_single_kpt"
    "test_lda_grad"
    "test_nr_symm"
    "test_with_qmmm_scanner"
    "test_he_131_diag"
    "test_casscf"
    "test_natorb"
    "test_nonorth_get_j_kpts"
    "test_orth_get_j_kpts"
    "test_uks_hess"
    "test_dipoles_casscfbasis"
    "test_raw_response"
    "test_ub3lyp_tda"
    "test_newton_casscf"
    "test_he_131_ip_diag"
    "test_state_specific"
    "test_casscf_grad"
    "test_init_guess_by_vsap"
    "test_with_x2c_scanner"
    "test_rccsd_t_hf_against_so"
    "test_he_131_ea_diag"
    "test_tddft_b3lyp"
    "test_lambda_sd"
    "test_aft_get_nuc"
    "test_b3lyp_tda"
    "test_aft_get_pp"
    "test_uccsd_grad"
    "test_finite_diff_wb97x_hess"
    "test_eomea_matvec"
    "test_rccsd_t_non_hf_against_so"
    "test_with_ci_init_guess"
    "test_211_n3"
    "test_trust_region"
    "test_t3p2_intermediates_against_so"
    "test_aft_bands"
    "test_nr_kuks_lda"
    "test_rhf"
    "test_frozenselect"
    "test_ccsd_t_hf_frozen"
    "test_iter_sd"
    "test_rdm1"
    "test_ghf_exx_ewald"
    "test_uks_b3lypg"
    "test_state_specific_scanner"
    "test_symmetrize"
    "test_nr_kuks_gga"
    "test_he_112_diag"
    "test_with_x2c_scanner"
    "test_rsh_aft_high_cost"
    "test_ulda_tda"
    "test_ft_aoao_pxp"
    "test_wfnsym"
    "test_contract_ss"
    "test_nr_krohf"
    "test_ccsd_t_non_hf"
    "test_nr_kuhf"
    "test_ccsd_t"
    "test_nr_krks_lda"
    "test_tddft_b3lyp"
    "test_nr_krhf"
    "test_cas_natorb"
    "test_cache_xc_kernel"
    "test_race_condition_skip"
  ];
  NOSE_IGNORE_FILES = [
    ".*_slow.*.py"
    ".*_kproxy_.*.py"
    "test_proxy.py"
    "test_krhf_slow_gamma.py"
    "test_krhf_slow.py"
    "test_krhf_slow_supercell.py"
    "test_ddcosmo_grad.py"
    "test_kuccsd_supercell_vs_kpts.py"
    "test_kccsd_ghf.py"
    "test_h_.*.py"
    "test_P_uadc_ip.py"
    "test_P_uadc_ea.py"
    "test_ksproxy_ks.py"
    "test_kproxy_ks.py"
    "test_kproxy_hf.py"
    "test_kgw_slow.py"
  ];
  NOSE_EXCLUDE_DIRS = [
    "pyscf/geomopt"
    "pyscf/dmrgscf"
    "pyscf/fciqmcscf"
    "pyscf/icmpspt"
    "pyscf/shciscf"
    "pyscf/nao"
    "pyscf/cornell_shci"
    "pyscf/pbc/grad"
    "pyscf/xianci"
    "pyscf/dftd3"
  ];
  NOSE_EXCLUDE_TESTS = [
    "pbc.tdscf.test.test_kproxy_hf.DiamondTestSupercell3"
    "pbc.tdscf.test.test_kproxy_ks.DiamondTestSupercell3"
    "pbc.tdscf.test.test_kproxy_supercell_hf.DiamondTestSupercell3"
    "pbc.tdscf.test.test_kproxy_supercell_ks.DiamondTestSupercell3"
  ];

  meta = with lib; {
    description = "Python-based Simulations of Chemistry Framework";
    longDescription = ''
      PySCF is an open-source collection of electronic structure modules powered by Python.
      The package aims to provide a simple, lightweight, and efficient platform
      for quantum chemistry calculations and methodology development.
    '';
    homepage = "http://www.pyscf.org/";
    downloadPage = "https://github.com/pyscf/pyscf/releases";
    changelog = "https://github.com/pyscf/pyscf/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
