# darktable AI models, bundled declaratively for offline use.
#
# darktable's AI features (denoise / raw denoise / upscale / object masking)
# normally download .dtmodel files at runtime from the darktable-org/darktable-ai
# GitHub repo, keyed by darktable's version. That auto-download fails for this
# fork because it reports 5.8.0 and the model index only lists up to 5.7.0. This
# derivation side-steps the downloader entirely: it fetches the .dtmodel assets
# (from the nightly-5.7.0 release, the newest, closest to the 5.8.0 dev tree) and
# unpacks them into the exact layout darktable scans.
#
# Each .dtmodel is a zip whose single top-level dir is the model id and holds
# config.json + the .onnx weights. darktable discovers a model by scanning its
# models dir for <id>/config.json (src/common/ai_models.c), so the output here is
# meant to be linked in as darktable's models dir:
#   ~/.local/share/darktable/models  ($XDG_DATA_HOME/darktable/models)
# It's read-only (Nix store); darktable only reads it, so bundled models Just
# Work. Downloading *more* models from the UI would fail (read-only) — add the id
# to `hashes`/`models` here instead.
#
# spektrafilm itself does NOT use any of these; they are for darktable's own AI
# modules. See darktable-spektrafilm.nix (withAi) which enables that code path.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,

  # darktable-ai release tag the assets come from. Must be a version darktable's
  # model index maps to (5.5.0/5.6.0/5.7.0 at time of writing).
  release ? "nightly-5.7.0",

  # model id -> fetchurl hash. Add an entry (with its hash) to make a model
  # available to `models` below. Full asset list + sizes:
  #   https://github.com/darktable-org/darktable-ai/releases/tag/nightly-5.7.0
  # NB: named `modelHashes` (not `hashes`) to avoid colliding with nixpkgs'
  # own `pkgs.hashes`, which callPackage would otherwise inject here.
  modelHashes ? {
    "denoise-nind" = "sha256-+SCHGBMedEmspdUDrKipD/sw6Kxs9kdWoVQQUNQTrwM=";
    "rawdenoise-nind" = "sha256-uQDYeJx/trzX9N9K8OBIe2Pkrlb/EAzyO9lhWLBodDQ=";
    "upscale-realplksr" = "sha256-7O2OxZ2Zi0r6ZFit0vu6CUGUgjWM0jLdekKLoTjlBfA=";
    "mask-object-sam21-small" = "sha256-hCxdoDJgXEn2VKTbczsuI1304zLZEvz2vY+jTiBYvIw=";
  },

  # which of the models above to bundle (default: all pinned)
  models ? builtins.attrNames modelHashes,
}:

let
  fetchModel = id: fetchurl {
    name = "${id}.dtmodel";
    url = "https://github.com/darktable-org/darktable-ai/releases/download/${release}/${id}.dtmodel";
    hash = modelHashes.${id};
  };
in
stdenvNoCC.mkDerivation {
  pname = "darktable-ai-models";
  version = release;

  dontUnpack = true;
  nativeBuildInputs = [ unzip ];

  # Each .dtmodel unzips to $out/<id>/{config.json,*.onnx}; ids are distinct so
  # there are no collisions.
  buildCommand = ''
    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n"
      (id: ''
        echo "unpacking ${id}"
        unzip -q ${fetchModel id} -d "$out"
      '')
      models}
  '';

  meta = {
    description = "darktable AI models (denoise/upscale/object-masking) bundled for offline use";
    homepage = "https://github.com/darktable-org/darktable-ai";
    # License intentionally unset: this is a redistributable bundle of upstream
    # model weights with mixed per-model terms. Asserting unfreeRedistributable
    # here would fail eval because this flake instantiates nixpkgs without
    # allowUnfree.
    platforms = lib.platforms.linux;
  };
}
