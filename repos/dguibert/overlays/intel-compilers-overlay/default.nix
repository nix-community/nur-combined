self: super:
let
    # Intel compiler
    intelPackages =
      { version
      , comp_url, comp_sha256 ? ""
      , mpi_url, mpi_sha256 ? ""
      , redist_url, redist_sha256 ? ""
      , gcc ? pkgs.gcc7
      , pkgs ? super
      }:
      let
      wrapCCWith = { cc
        , # This should be the only bintools runtime dep with this sort of logic. The
          # Others should instead delegate to the next stage's choice with
          # `targetPackages.stdenv.cc.bintools`. This one is different just to
          # provide the default choice, avoiding infinite recursion.
          bintools ? if pkgs.targetPlatform.isDarwin then pkgs.darwin.binutils else pkgs.binutils
        , libc ? bintools.libc or pkgs.stdenv.cc.libc
        , ...
        } @ extraArgs:
          pkgs.callPackage ./build-support/cc-wrapper (let self = {
        nativeTools = pkgs.targetPlatform == pkgs.hostPlatform && pkgs.stdenv.cc.nativeTools or false;
        nativeLibc = pkgs.targetPlatform == pkgs.hostPlatform && pkgs.stdenv.cc.nativeLibc or false;
        nativePrefix = pkgs.stdenv.cc.nativePrefix or "";
        noLibc = !self.nativeLibc && (self.libc == null);

        isGNU = cc.isGNU or false;
        isClang = cc.isClang or false;
        isIntel = true;

        inherit cc bintools libc;
      } // extraArgs; in self);


    in (if (comp_url != null) then rec {
      redist = pkgs.callPackage ./redist.nix { inherit version; url=redist_url; sha256=redist_sha256; };
      unwrapped = pkgs.callPackage ./compiler.nix { inherit version gcc; url=comp_url; sha256=comp_sha256; };

      compilers = wrapCCWith {
        cc = unwrapped;
        extraPackages = [ redist pkgs.which pkgs.binutils unwrapped ];
      };

      /* Return a modified stdenv that uses Intel compilers */
      stdenv = let stdenv_=pkgs.overrideCC pkgs.stdenv compilers; in stdenv_ // {
        mkDerivation = args: stdenv_.mkDerivation (args // {
          postFixup = "${args.postFixup or ""}" + ''
          set -x
          storeId=$(echo "${compilers}" | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")
          find $out -not -type d -print0 | xargs -0 sed -i -e  "s|$NIX_STORE/$storeId-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g"
          storeId=$(echo "${unwrapped}" | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")
          find $out -not -type d -print0 | xargs -0 sed -i -e  "s|$NIX_STORE/$storeId-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g"
          set +x
          '';
        });
      };
    } else {}) // {
      mpi = if (mpi_url!=null) then pkgs.callPackage ./mpi.nix { inherit version; url=mpi_url; sha256=mpi_sha256;} else null;
    };

in {
    # https://software.intel.com/en-us/articles/intel-compiler-and-composer-update-version-numbers-to-compiler-version-number-mapping

    #intelPackages_2016_0_109 = intelPackages "2016.0.109";
    # "2016.0.109"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/7997/parallel_studio_xe_2016.tgz
    #intelPackages_2016_1_150 = intelPackages "2016.1.150";
    # "2016.1.150"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/8365/parallel_studio_xe_2016_update1.tgz
    #intelPackages_2016_2_181 = intelPackages "2016.2.181";
    # "2016.2.181"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/8676/parallel_studio_xe_2016_update2.tgz
    #intelPackages_2016_3_210 = intelPackages "2016.3.210";
    # "2016.3.210" = null;
    #intelPackages_2016_3_223 = intelPackages "2016.3.223";
    # "2016.3.223"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9061/parallel_studio_xe_2016_update3.tgz
    ## # built from parallel_studio_xe_2016.3.068
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9278/l_mpi_p_5.1.3.223.tgz
    #intelPackages_2016_4_258 = intelPackages "2016.4.258";
    # "2016.4.258"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9781/parallel_studio_xe_2016_update4.tgz
    #intelPackages_2016 = self.intelPackages_2016_4_258;

    #intelPackages_2017_0_098 = intelPackages "2017.0.098";
    # "2017.0.098"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9651/parallel_studio_xe_2017.tgz
    #intelPackages_2017_1_132 = intelPackages "2017.1.132";
    # "2017.1.132"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/10973/parallel_studio_xe_2017_update1.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11014/l_mpi_2017.1.132.tgz
    #intelPackages_2017_2_174 = intelPackages "2017.2.174";
    # "2017.2.174"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11298/parallel_studio_xe_2017_update2.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11334/l_mpi_2017.2.174.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11460/parallel_studio_xe_2017_update3.tgz
    #intelPackages_2017_4_196 = intelPackages "2017.4.196";
    # "2017.3.196"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11537/parallel_studio_xe_2017_update4.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11595/l_mpi_2017.3.196.tgz
    #intelPackages_2017_5_239 = intelPackages "2017.5.239";
    # "2017.5.239"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12138/parallel_studio_xe_2017_update5.tgz
    #  mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12209/l_mpi_2017.4.239.tgz";
    #  mpi_sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d6";
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12534/parallel_studio_xe_2017_update6.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13709/parallel_studio_xe_2017_update8.tgz
    intelPackages_2017_5_239 = intelPackages {
      version = "2017.5.239";
      comp_url = null;
      redist_url = null;
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12209/l_mpi_2017.4.239.tgz";
      mpi_sha256 = "02si091w8gvq7nsclngiz1ckqjy9hcf4g2apnisvrs6whk94h42s";
      pkgs = super;
    };
    intelPackages_2017_7_259 = intelPackages {
      version = "2017.7.259";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12856/parallel_studio_xe_2017_update7.tgz";
      comp_sha256 = "0q331y0vlr4lrl8bwczhh8m4arqljw7sjf4r2i4gx921k2lklg0k";
      redist_url = "https://software.intel.com/sites/default/files/managed/e1/e4/l_comp_lib_2017.7.259_comp.for_redist.tgz";
      redist_sha256 = "06wq03l257ywklywrs6qnx7zqmx0m8f3xfqa5l8a10w9axbh8s39";
      mpi_url = null;
      pkgs = super;
    };
    intelPackages_2017 = self.intelPackages_2017_7_259;

    #intelPackages_2018_0_128 = intelPackages "2018.0.128";
    # "2018.0.128"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12062/parallel_studio_xe_2018_professional_edition.tgz
    #602c9ceb6934a3eadce5a834b066bf326ab12b9d7b448ae405c7bca09be485f0  software.intel.com_sites_default_files_managed_96_59_l_comp_lib_2018.0.128_comp.for_redist.tgz
    #  mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12120/l_mpi_2018.0.128.tgz";
    #  mpi_sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d5";
    #intelPackages_2018_1_163 = intelPackages "2018.1.163";
    # "2018.1.163"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12375/parallel_studio_xe_2018_update1_professional_edition.tgz
    #fe36b4de91666fdd6e8236f121105792f5f39b41e2bedf378f298e22c7e1fb8d  software.intel.com_sites_default_files_managed_aa_dc_l_comp_lib_2018.1.163_comp.for_redist.tgz
    #  mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12414/l_mpi_2018.1.163.tgz";
    #  mpi_sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d4";

    intelPackages_2018_2_199 = intelPackages {
      version = "2018.2.199";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12718/parallel_studio_xe_2018_update2_professional_edition.tgz";
      comp_sha256 = "";
      redist_url = "l_comp_lib_2018.2.199_comp.for_redist.tgz";
      redist_sha256 = "6d9e5383f81296edf702351826f1bc618cd8ca0cc7a692d272a922516e997604";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12748/l_mpi_2018.2.199.tgz";
      mpi_sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d3";
    };

    intelPackages_2018_3_222 = intelPackages {
      version = "2018.3.222";
      comp_url ="http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12999/parallel_studio_xe_2018_update3_professional_edition.tgz";
      comp_sha256 = "";
      redist_url = "l_comp_lib_2018.3.222_comp.for_redist.tgz";
      redist_sha256 = "b9eaf0ed8b8dac01b4d169165624aafc86776c4ae5ed73f564b04090a94a1be6";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13112/l_mpi_2018.3.222.tgz";
      mpi_sha256 = "16c94p7w12hyd9x5v28hhq2dg101sx9lsvhlkzl99isg6i5x28ah";
    };

    intelPackages_2018_5_274 = intelPackages {
      version = "2018.5.274";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13718/parallel_studio_xe_2018_update4_professional_edition.tgz";
      comp_sha256 = "08ykfwmka5lgma21a3by8rl10x91m8s7myln41h0i4c4v8h47asl";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13741/l_mpi_2018.4.274.tgz";
      mpi_sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d1";
      redist_url="https://software.intel.com/sites/default/files/managed/7a/1e/l_comp_lib_2018.5.274_comp.for_redist.tgz";
      redist_sha256="0i1h2dc7w3bhk5m7hkqvz1ffhrhgkx294b3r73hzs32hnjgbvqrg";
      gcc = super.gcc7;
    };
    intelPackages_2018 = self.intelPackages_2018_5_274;

    #https://software.intel.com/en-us/articles/redistributable-libraries-for-intel-c-and-fortran-2019-compilers-for-linux
    intelPackages_2019_0_117 = intelPackages {
      version = "2019.0.117";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13578/parallel_studio_xe_2019_professional_edition.tgz";
      comp_sha256 = "1qhicj98x60csr4a2hjb3krvw74iz3i3dclcsdc4yp1y6m773fcl";
      redist_url = "https://software.intel.com/sites/default/files/managed/05/23/l_comp_lib_2019.0.117_comp.for_redist.tgz";
      redist_sha256 = "6218ea4176373cd21c41465a1f406d133c28a2c1301590aa1661243dd68c28fc";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13584/l_mpi_2019.0.117.tgz";
      mpi_sha256 = "025ww7qa03mbbs35fb63g4x8qm67i49bflm9g8ripxhskks07d6z";
      gcc = super.gcc7;
    };

    intelPackages_2019_1_144 = intelPackages {
      version = "2019.1.144";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/14854/parallel_studio_xe_2019_update1_professional_edition.tgz";
      comp_sha256 = "1rhcfbig0qvkh622cvf8xjk758i3jh2vbr5ajdgms7jnwq99mii8";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/14879/l_mpi_2019.1.144.tgz";
      mpi_sha256 = "1kf3av1bzaa98p5h6wagc1ajjhvahlspbca26wqh6rdqnrfnmj6s";
      redist_url="https://software.intel.com/sites/default/files/managed/79/cd/l_comp_lib_2019.1.144_comp.for_redist.tgz";
      redist_sha256="05kd2lc2iyq3rgnbcalri86nf615n0c1ii21152yrfyxyhk60dxm";
      gcc = super.gcc7;
    };

    intelPackages_2019_2_187 = intelPackages {
      version = "2019.2.187";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15089/parallel_studio_xe_2019_update2_professional_edition.tgz";
      comp_sha256 = "1sk4dsq3n8p155m394nsikv1vqw1l3k687vz3753bl8j8vbjkdnd";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15040/l_mpi_2019.2.187.tgz";
      mpi_sha256 = "084bfw29swvpjm1lynl1pfj3y3v2j563k7lnvvvy7yay7f9hacva";
      redist_url="https://software.intel.com/sites/default/files/managed/95/e7/l_comp_lib_2019.2.187_comp.for_redist.tgz";
      redist_sha256="0sj0plax2bnid1qm1jqvijiflzfvs37vkfmg93mb7202g9fp7q77";
      gcc = super.gcc7;
    };

    intelPackages_2019_3_199 = intelPackages {
      version = "2019.3.199";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15269/parallel_studio_xe_2019_update3_professional_edition.tgz";
      comp_sha256 = "1y97gam3798nqpr89x5x2f5xfrywpizxj337ykng3gfh0s8qga4j";
      mpi_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15260/l_mpi_2019.3.199.tgz";
      mpi_sha256 = "143951k7c3pj4jqi627j5whwiky5a57v3vjhf9wxwr1zhrn3812k";
      redist_url="https://software.intel.com/sites/default/files/managed/7f/23/l_comp_lib_2019.3.199_comp.for_redist.tgz";
      redist_sha256="06c3w65ir481bqnwbmd9nqigrhcb3qyxbmx2ympckygjiparwh05";
      gcc = super.gcc7;
    };

    intelPackages_2019_4_227 = intelPackages {
      version = "2019.4.227";
      comp_url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15466/parallel_studio_xe_2019_update4_composer_edition.tgz";
      comp_sha256 = "0n7wjq789v7z0rqmymb4ly54yiixshjlyrz80x0pjpz2zn6zlmpw";
      mpi_url = null;
      mpi_sha256 = "";
      redist_url="http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15466/l_comp_lib_2019.4.227_comp.for_redist.tgz";
      redist_sha256="0f3lz0carshqi4nfpmdmi4kmndgml6prh9frf820sdg31w7khcbl";
      gcc = super.gcc7;
    };

    intelPackages_2019 = self.intelPackages_2019_4_227;

    stdenvIntel = self.intelPackages_2019.stdenv;

    helloIntel = super.hello.override { stdenv = self.stdenvIntel; };
    miniapp-ping-pongIntel = super.miniapp-ping-pong.override { stdenv = self.stdenvIntel;
      caliper = super.caliper.override { stdenv = self.stdenvIntel;
        mpi = self.intelPackages_2019.mpi;
      };
      mpi = self.intelPackages_2019.mpi;
    };

    hemocellIntel = super.hemocell.override {
      stdenv = self.stdenvIntel;
      hdf5 = (super.hdf5-mpi.override {
        stdenv = self.stdenvIntel;
        mpi = self.intelPackages_2019.mpi;
      }).overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [
          "CC=${self.intelPackages_2019.mpi}/bin/mpiicc"
        ];
      });
    };
}
