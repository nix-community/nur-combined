{ lib, fetchFromGitHub, llama-cpp, maintainers }: let
    toshllm-version = "0.87.17";
    toshllm-hash = "sha256-b0FN9KrcOsHMOREvsfgeviPnZE2bDgLAd7aMUsHGURg=";
    llama-cpp-rev = "d81235049384534c167caea52b85a694f6103d14";
    llama-cpp-hash = "sha256-r/9cBgKB6P1XxNGv41Q/+ePgtM5X5uC++MR4+LCm1kY=";
    llama-cpp-npmDepsHash = "sha256-a17M+L3nLdRnN6WMB6imPFmwqG2g8uv+gwN0XTAUrf8=";
    
    toshllmSrc = fetchFromGitHub {
        owner = "engeldlgado";
        repo = "toshllm";
        tag = "v${toshllm-version}";
        sparseCheckout = [
            "scripts/build-engines.sh"
            "patches/llama"
        ];
        nonConeMode = true;
        hash = toshllm-hash;
    };
    llama-cpp' = llama-cpp.override {
        metalSupport = true;
        vulkanSupport = false;
    };
    llama-cpp'' = llama-cpp'.overrideAttrs (finalAttrs: old: {
        pname = "${lib.getName llama-cpp}-toshllm";
        version = toshllm-version;
        src = old.src.override {
            rev = llama-cpp-rev;
            tag = null;
            hash = llama-cpp-hash;
        };
        npmDepsHash = llama-cpp-npmDepsHash;
        inherit toshllmSrc;
        prePatch = (old.prePatch or "") + ''
            patches+=" $(find "$toshllmSrc/patches/llama" -name '*.patch' -print | \
                awk -F/ '{print $NF"\t"$0}' | sort | cut -f2-)"
        '';
        cmakeFlags = builtins.map (flag: if lib.hasInfix "LLAMA_BUILD_NUMBER" flag then
            lib.cmakeFeature "LLAMA_BUILD_NUMBER" "0"
        else flag) (old.cmakeFlags or []);
        passthru = (old.passthru or {}) // {
            updateScript = ./update.sh;
            _pkgForUpdater = finalAttrs.finalPackage // {
                src = finalAttrs.toshllmSrc;
                llama-cpp-src = finalAttrs.src;
            };
        };
    });
    llama-cpp''' = lib.addMetaAttrs {
        description = lib.replaceStrings [") ("] ["; "] "${llama-cpp.meta.description or "llama-cpp"} (ToshLLM patched version, tuned for Intel Macs with AMD GPUs)";
        homepage = "https://toshllm.com/";
        license = lib.licenses.gpl3Plus; # ? Not sure if this applies to the engine patches, or just the GUI app, but should be a safe guess
        platforms = ["x86_64-darwin"];
        maintainers = [maintainers.Rhys-T];
    } llama-cpp'';
in llama-cpp'''
