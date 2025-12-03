{ pkgs, ... }: {
  sane.programs.sops = {
    packageUnwrapped = pkgs.sops.overrideAttrs (upstream: {
      # sops default behavior is to pre-populate a file with a bunch of example text.
      # deleting that text for _every_ new secret is annoying.
      # not tunable by config, so patch out.
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace stores/dotenv/store.go --replace-fail \
          'stores.ExampleFlatTree.Branches' \
          'sops.TreeBranches{sops.TreeBranch{}}'
        substituteInPlace stores/ini/store.go --replace-fail \
          'stores.ExampleSimpleTree.Branches' \
          'sops.TreeBranches{}'
        substituteInPlace stores/json/store.go --replace-fail \
          'stores.ExampleComplexTree.Branches' \
          'sops.TreeBranches{sops.TreeBranch{}}'
        substituteInPlace stores/yaml/store.go --replace-fail \
          'stores.ExampleComplexTree.Branches' \
          'sops.TreeBranches{}'

        # substituteInPlace cmd/sops/edit.go \
        #   --replace-fail 'opts.InputStore.EmitExample()'  '[]byte("")'
      '';
    });
    sandbox.extraHomePaths = [
      ".config/nvim"
      ".config/sops"
      "nixos"
      # TODO: sops should only need access to knowledge/secrets,
      # except that i currently put its .sops.yaml config in the root of ~/knowledge
      "knowledge"
    ];
  };
}
