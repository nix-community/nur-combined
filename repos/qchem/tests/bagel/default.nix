{ lib, batsTest, bagel, openssh } :

let
  files = [
    "benzene_sto3g_asd-ras_stack.json"
    "benzene_sto3g_asd_stack.json"
    "benzene_sto3g_asd_T.json"
    "benzene_sto3g_pml.json"
    "benzene_svp_mp2_aux.json"
    "benzene_svp_mp2.json"
    "ch2_sto3g_meci_opt.json"
    "cuh2_ecp_hf.json"
    "h2o_sto3g_ras_full.json"
    "h2o_sto3g_ras_restricted.json"
    "h2o_svp_cas.json"
    "h2o_svp_fmm.json"
    "h2o_svp_fmm_restart.json"
    "h2o_svp_nevpt2.json"
    "hbr_ecp_sohf.json"
    "hcl_svp_common_coulomb.json"
    "hcl_svp_common_gaunt.json"
    "hcl_svp_dfhf.json"
    "hcl_svp_dfhf_opt.json"
    "hcl_svp_london_coulomb.json"
    "hc_svp_rohf.json"
    "hc_svp_rohf_opt.json"
    "he3_svp_asd-dmrg.json"
    "he_tzvpp_second_coulomb.json"
    "hf_mix2_dfhf.json"
    "hf_mix_dfhf_finite.json"
    "hf_mix_dfhf.json"
    "hf_mix_dfhf_opt.json"
    "hf_new_dfhf.json"
    "hf_sto3g_fci_dist.json"
    "hf_sto3g_fci_hz.json"
    "hf_sto3g_fci_kh.json"
    "hf_sto3g_fci_restart.json"
    "hf_sto3g_relfci_breit.json"
    "hf_sto3g_relfci_coulomb.json"
    "hf_sto3g_relfci_gaunt.json"
    "hf_svp_b3lyp.json"
    "hf_svp_b3lyp_opt.json"
    "hf_svp_breit.json"
    "hf_svp_cas_opt.json"
    "hf_svp_cis.json"
    "hf_svp_common_dfhf.json"
    "hf_svp_coulomb.json"
    "hf_svp_coulomb_opt.json"
    "hf_svp_dfhf_cart.json"
    "hf_svp_dfhf_charge.json"
    "hf_svp_dfhf_dkh_grad.json"
    "hf_svp_dfhf_dkh.json"
    "hf_svp_dfhf_ext.json"
    "hf_svp_dfhf_grad.json"
    "hf_svp_dfhf.json"
    "hf_svp_dfhf_opt_cart.json"
    "hf_svp_dfhf_opt.json"
    "hf_svp_dfhf_restart.json"
    "hf_svp_gaunt.json"
    "hf_svp_hf.json"
    "hf_svp_london_coulomb.json"
    "hf_svp_london_dfhf.json"
    "hf_svp_london_gaunt.json"
    "hf_svp_london_hf.json"
    "hf_svp_mp2_aux_finite.json"
    "hf_svp_mp2_aux_opt.json"
    "hf_svp_mp2_opt.json"
    "hf_svp_sacas_opt.json"
    "hf_svp_second_coulomb.json"
    "hf_tzvpp_zcasscf_saveref.json"
    "hf_write_mol_cart.json"
    "hf_write_mol_sph.json"
    "hhe_svp_fci2_trip.json"
    "hhe_svp_fci_hz_trip.json"
    "hhe_svp_fci_kh_trip.json"
    "hhe_svp_ras_full.json"
    "hhe_svp_ras_restricted.json"
    "li2_svp_caspt2_grad.json"
    "li2_svp_caspt2_shift.json"
    "li2_tzvpp_cas43.json"
    "lif_svp_cas22.json"
    "lif_svp_cas_nacme.json"
    "lif_svp_mscaspt2_grad.json"
    "lif_svp_xmscaspt2_finite.json"
    "lif_svp_xmscaspt2_grad_imag.json"
    "lif_svp_xmscaspt2_grad.json"
    "lif_svp_xmscaspt2_nacme.json"
    "lih_tzvpp_cas22.json"
    "nh_svp_triplet_gaunt.json"
    "o2_321g_zcasscf_pseudospin.json"
    "o2_svp_triplet_breit.json"
    "oh_svp_uhf.json"
    "oh_svp_uhf_opt.json"
    "watertrimer_sto3g_pml_region.json"
    "watertrimer_sto3g_rl.json"
  ];

in batsTest {
  name = "bagel";

  auxFiles = [ ./bagel.inp ];

  outFiles = [ "*.out" ];

  nativeBuildInputs = [ bagel openssh ];

  testScript = lib.concatStringsSep "\n" ( map ( x: ''
    @test "${x}" {
      if [ ${x} == "he_tzvpp_second_coulomb.json" ]; then
         skip "${x} is broken (memory leak)"
      fi

      ${bagel}/bin/bagel -np $TEST_NUM_CPUS ${bagel}/share/tests/${x} > ${x}.out
    }
  '') files) + ''

    @test "Run-Bagel" {
      ${bagel}/bin/bagel -np $TEST_NUM_CPUS ./bagel.inp > bagel.out
    }
  '';

  teardownScript = ''
    for f in *.archive *.molden *.log asd_*; do
      rm -f $f
    done
  '';
}
