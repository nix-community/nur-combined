{ lib, fetchFromGitHub, llama-cpp, avx2Support ? true, maintainers }: let
    toshllm-version = "0.87.20";
    toshllm-hash = "sha256-Nlh2BaS4HN0hlp1EKmYiLP6tX/qJbM78bzPKLNtXHB8=";
    llama-cpp-rev = "d81235049384534c167caea52b85a694f6103d14";
    llama-cpp-hash = "sha256-l6l6JIlIVTaVC6xh5M4fRHFtXsweQuugtkNTWHcZZF4=";
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
        src = fetchFromGitHub {
            owner = "ggml-org";
            repo = "llama.cpp";
            rev = llama-cpp-rev;
            hash = llama-cpp-hash;
        };
        npmDepsHash = llama-cpp-npmDepsHash;
        inherit toshllmSrc;
        prePatch = (old.prePatch or "") + ''
            patches+=" $(find "$toshllmSrc/patches/llama" -name '*.patch' -print | \
                awk -F/ '{print $NF"\t"$0}' | sort | cut -f2-)"
        '';
        cmakeFlags = builtins.filter (flag: !(lib.hasInfix "LLAMA_BUILD_NUMBER" flag || lib.hasInfix "LLAMA_BUILD_COMMIT" flag)) (old.cmakeFlags or []) ++ [
            (lib.cmakeFeature "LLAMA_BUILD_NUMBER" "0")
            (lib.cmakeFeature "LLAMA_BUILD_COMMIT" (builtins.substring 0 7 llama-cpp-rev))
            # Match ISA_FLAGS in `scripts/build-engines.sh`:
            (lib.cmakeBool "GGML_SSE42" avx2Support)
            (lib.cmakeBool "GGML_AVX" avx2Support)
            (lib.cmakeBool "GGML_AVX2" avx2Support)
            (lib.cmakeBool "GGML_FMA" avx2Support)
            (lib.cmakeBool "GGML_F16C" avx2Support)
            (lib.cmakeBool "GGML_BMI2" avx2Support)
            (lib.cmakeBool "GGML_AVX_VNNI" false)
            (lib.cmakeBool "GGML_AVX512" false)
        ];
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
