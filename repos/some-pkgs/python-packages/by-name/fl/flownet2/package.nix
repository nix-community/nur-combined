{ lib
, buildPythonPackage
, callPackage
, colorama
, fetchFromGitHub
, h5py
, imageio
, jupyterlab
, matplotlib
, networkx
, pandas
, pillow
, plotly
, protobuf
, python
, requests
, runUnderPdb ? false
, scikit-image
, scikit-learn
, seaborn
, setproctitle
, some-datasets
, stdenv
, tensorboardx
, torch
, torch-kernel-generic
, tqdm
}:

let
  flownet2 =
    buildPythonPackage rec {
      pname = "flownet2";
      version = "unstable-2020-04-01";
      format = "other";

      src = fetchFromGitHub {
        owner = "NVIDIA";
        repo = "flownet2-pytorch";
        rev = "2e9e010c98931bc7cef3eb063b195f1e0ab470ba";
        hash = "sha256-V1rNosdmJmVrK66YgrRnEdvvO7YzlNOLhQdOPW7lTxA=";
      };

      postPatch = ''
        find -iname '*.py' -exec \
          sed -i \
            -e 's/^import \(models\|losses\|datasets\)/from flownet2 import \1/' \
            -e 's/^import utils/import flownet2.utils/' \
            -e 's/^from utils/from flownet2.utils/' \
            -e '/from scipy.misc import \(imread, \)\?imresize/a from skimage.transform import resize as imresize' \
            -e 's/^from scipy.misc import imread\(, imresize\)\?/from imageio import imread/' \
            -e 's/inspect.getargspec/inspect.getfullargspec/'${"" /* https://github.com/NVIDIA/flownet2-pytorch/issues/265 */ } \
            -e 's/time.clock()/time.monotonic()/' \
            -e '/os.chdir/d' \
            '{}' '+'

        sed -i \
          -e 's/subprocess.*(.*git.*rev-parse.*HEAD.*)/"${src.rev}"/' \${
          lib.optionalString runUnderPdb ''
          -e '1a import pdb' \
          -e 's/if __name__ == .__main__./def main()/' \
          -e '$a pdb.run("main()")' \''}
          main.py

        mkdir flownet2/
        mv models.py losses.py datasets.py utils/ networks/ flownet2/

        mkdir bin/
        mv main.py "bin/${meta.mainProgram}"
        mv convert.py "bin/${pname}-convert"
        mv run_a_pair.py "bin/${pname}-run-a-pair"
        mv download_caffe_models.sh "bin/${pname}-download-caffe-models"
        mv run-caffe2pytorch.sh "bin/${pname}-run-caffe2pytorch"
      '';

      propagatedBuildInputs = [
        colorama
        h5py
        imageio
        jupyterlab
        matplotlib
        networkx
        pandas
        pillow
        plotly
        protobuf
        requests
        scikit-image
        scikit-learn
        seaborn
        setproctitle
        tensorboardx
        torch
        tqdm

        channelnorm
        correlation
        resample2d
      ];

      installPhase = ''
        mkdir -p $out/bin/ $out/${python.sitePackages}

        install bin/* -t $out/bin/
        cp -r flownet2 $out/${python.sitePackages}/
      '';

      pythonImportsCheck = [
        "flownet2.models"
        "flownet2.datasets"
        "flownet2.losses"
      ];

      installCheckPhase = ''
        $out/bin/${meta.mainProgram} --help
      '';

      passthru = rec {
        inherit resample2d correlation channelnorm;
        datasetsMerged = some-datasets.extendModules {
          modules = [{
            models.flownet2 = { inherit weights; };
          }];
        };
        # License: https://drive.google.com/file/d/1TVv0BnNFh3rpHZvD-easMb9jYrPE2Eqd/view?usp=sharing
        # CIDs are included for naming and equality-comparison purposes.
        weights = {
          FlowNet2 = {
            urls = [ ];
            hash = "sha256-QwVZYQqiCqCc+EbDTQAjQC7BIhJRLl31bTio6kfjFBw=";
            cid = "QmWAsrdgQt9J7eDxswiujVQCjkNY1FLj98g8nY5vcmcdgd";
          };
          FlowNet2-C = {
            urls = [ ];
            # FIXME: just an sha256sum run on the file, not the recursive thing...
            hash = "sha256-NolgSnbGbHePFqmKx1aknCC9uSJPRs/H7udpVSZqQn0=";
            cid = "QmaR7UJvNhiEu5zF2jLpZEY4GurarjcMReV1jkx7sosXvw";
          };
          FlowNet2-CSS = {
            urls = [ ];
            hash = "sha256-kNwNMqfhBE1Ipfqy3qOOCBQ4IcXoMWK7RuU0N4q6ozs=";
            cid = "QmU3vAEPQxPdbDXhVCwp9AgwjqwFT3Vcb2KD4TWirwG3KK";
          };
          FlowNet2-CSS-ft-sd = {
            urls = [ ];
            hash = "sha256-BdWohreHltpNHQTaiDw9PfrvuD7cJHtboeOoO4Xd50M=";
            cid = "QmakYwRpxQumwftTPs43DpYw6AC26gWUk5UwhT44GK8jKh";
          };
        };
      };

      meta = with lib; {
        description = "Pytorch implementation of NVidia's FlowNet 2.0: Evolution of Optical Flow Estimation with Deep Networks";
        homepage = "https://github.com/NVIDIA/flownet2-pytorch/";
        license = licenses.asl20;
        maintainers = with maintainers; [ SomeoneSerge ];
        mainProgram = "flownet2-pytorch";
        platforms = platforms.all;
      };
    };
  kernelArgs.postPatch = ''
    sed -i '/cxx_args =/{ x; a cxx_args = [ "-std=c++14" ]
      }' setup.py
  '';
  resample2d =
    torch-kernel-generic
      {
        inherit (flownet2) version;
        inherit (kernelArgs) postPatch;
        pname = "flownet2-resample2d";
        src = "${flownet2.src}/networks/resample2d_package";
        meta = flownet2.meta // { description = "FlowNet 2.0's resample2d package"; };
      };
  correlation =
    torch-kernel-generic
      {
        inherit (flownet2) version;
        inherit (kernelArgs) postPatch;
        pname = "flownet2-correlation";
        src = "${flownet2.src}/networks/correlation_package";
        meta = flownet2.meta // { description = "FlowNet 2.0's correlation package"; };
      };
  channelnorm =
    torch-kernel-generic
      {
        inherit (flownet2) version;
        inherit (kernelArgs) postPatch;
        pname = "flownet2-channelnorm";
        src = "${flownet2.src}/networks/channelnorm_package";
        meta = flownet2.meta // { description = "FlowNet 2.0's channelnorm package"; };
      };
in
flownet2
