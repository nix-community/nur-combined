{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fontforge,
  installFonts,
  nerd-font-patcher,
  nix-update-script,
  python3Packages,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "paper-mono";
  version = "0.300-unstable-2026-07-02";
  __structuredAttrs = true;

  outputs = [
    "out"
    "webfont"
  ];

  src = fetchFromGitHub {
    owner = "paper-design";
    repo = "paper-mono";
    rev = "b14a9274d854ac17b6225aa3456e9119a28926dc";
    hash = "sha256-fPfGrUBD6tNSEbJZaGDhPJwj/GCX7V6sGNVzb8osMok=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    fontforge
    installFonts
    nerd-font-patcher
    python3Packages.brotli
    python3Packages.fonttools
  ];

  # Keep the zero and ss04 features while making their alternates conventional defaults.
  buildPhase = ''
    runHook preBuild

    python - \
      fonts/otf/*.otf \
      fonts/ttf/*.ttf \
      fonts/variable/*.ttf \
      fonts/webfonts/*.woff2 <<'PY'
    from copy import deepcopy
    from pathlib import Path
    import os
    import sys

    from fontTools.ttLib import TTFont
    from fontTools.ttLib.tables import otTables


    def expose_coding_ligatures(font, path):
        if "GSUB" not in font:
            raise RuntimeError(f"missing GSUB table: {path}")

        gsub = font["GSUB"].table
        if any(
            getattr(gsub, name, None) is None
            for name in ("ScriptList", "FeatureList", "LookupList")
        ):
            raise RuntimeError(f"incomplete GSUB table: {path}")

        feature_list = gsub.FeatureList
        records = feature_list.FeatureRecord
        if feature_list.FeatureCount != len(records):
            raise RuntimeError(f"invalid GSUB feature count: {path}")

        ss04_indices = [
            index
            for index, record in enumerate(records)
            if record.FeatureTag == "ss04"
        ]
        calt_indices = [
            index
            for index, record in enumerate(records)
            if record.FeatureTag == "calt"
        ]
        if len(ss04_indices) != 1:
            raise RuntimeError(f"expected exactly one GSUB ss04 feature: {path}")
        if len(calt_indices) > 1:
            raise RuntimeError(f"expected at most one GSUB calt feature: {path}")

        ss04_index = ss04_indices[0]
        ss04_feature = records[ss04_index].Feature
        ss04_lookups = ss04_feature.LookupListIndex
        lookup_count = gsub.LookupList.LookupCount
        if (
            not ss04_lookups
            or ss04_feature.LookupCount != len(ss04_lookups)
            or ss04_lookups != sorted(set(ss04_lookups))
            or any(not 0 <= index < lookup_count for index in ss04_lookups)
        ):
            raise RuntimeError(f"invalid GSUB ss04 lookups: {path}")

        if calt_indices:
            calt_index = calt_indices[0]
            calt_feature = records[calt_index].Feature
            calt_lookups = calt_feature.LookupListIndex
            if calt_feature.LookupCount != len(calt_lookups) or any(
                not 0 <= index < lookup_count for index in calt_lookups
            ):
                raise RuntimeError(f"invalid GSUB calt lookups: {path}")
            calt_feature.LookupListIndex = sorted(set(calt_lookups + ss04_lookups))
            calt_feature.LookupCount = len(calt_feature.LookupListIndex)
            indexed_records = list(enumerate(records))
        else:
            calt_record = otTables.FeatureRecord()
            calt_record.FeatureTag = "calt"
            calt_record.Feature = otTables.Feature()
            calt_record.Feature.FeatureParams = None
            calt_record.Feature.LookupListIndex = list(ss04_lookups)
            calt_record.Feature.LookupCount = len(ss04_lookups)
            indexed_records = [*enumerate(records), (None, calt_record)]

        indexed_records.sort(key=lambda item: item[1].FeatureTag)
        feature_list.FeatureRecord = [record for _, record in indexed_records]
        feature_list.FeatureCount = len(feature_list.FeatureRecord)
        old_to_new = {
            old_index: new_index
            for new_index, (old_index, _) in enumerate(indexed_records)
            if old_index is not None
        }
        ss04_new_index = old_to_new[ss04_index]
        calt_new_index = next(
            index
            for index, record in enumerate(feature_list.FeatureRecord)
            if record.FeatureTag == "calt"
        )

        ss04_is_used = False
        for script_record in gsub.ScriptList.ScriptRecord:
            lang_systems = []
            if script_record.Script.DefaultLangSys is not None:
                lang_systems.append(script_record.Script.DefaultLangSys)
            lang_systems.extend(
                record.LangSys for record in script_record.Script.LangSysRecord
            )
            for lang_sys in lang_systems:
                old_indices = lang_sys.FeatureIndex
                if (
                    lang_sys.FeatureCount != len(old_indices)
                    or len(old_indices) != len(set(old_indices))
                    or any(index not in old_to_new for index in old_indices)
                ):
                    raise RuntimeError(f"invalid GSUB LangSys features: {path}")

                required_index = lang_sys.ReqFeatureIndex
                if required_index != 0xFFFF and required_index not in old_to_new:
                    raise RuntimeError(f"invalid GSUB required feature: {path}")

                uses_ss04 = (
                    ss04_index in old_indices or required_index == ss04_index
                )
                new_indices = [old_to_new[index] for index in old_indices]
                if uses_ss04 and calt_new_index not in new_indices:
                    if ss04_new_index in new_indices:
                        position = new_indices.index(ss04_new_index)
                    else:
                        position = len(new_indices)
                    new_indices.insert(position, calt_new_index)
                lang_sys.FeatureIndex = new_indices
                lang_sys.FeatureCount = len(new_indices)

                if required_index != 0xFFFF:
                    lang_sys.ReqFeatureIndex = old_to_new[required_index]
                ss04_is_used |= uses_ss04

        if not ss04_is_used:
            raise RuntimeError(f"GSUB ss04 is not referenced by any LangSys: {path}")

        feature_variations = getattr(gsub, "FeatureVariations", None)
        if feature_variations is not None:
            for variation in feature_variations.FeatureVariationRecord:
                substitution = variation.FeatureTableSubstitution
                records = substitution.SubstitutionRecord
                if substitution.SubstitutionCount != len(records):
                    raise RuntimeError(f"invalid GSUB feature variations: {path}")
                for record in records:
                    if record.FeatureIndex not in old_to_new:
                        raise RuntimeError(f"invalid GSUB variation feature: {path}")
                    record.FeatureIndex = old_to_new[record.FeatureIndex]
                records.sort(key=lambda record: record.FeatureIndex)

    for path_string in sys.argv[1:]:
        path = Path(path_string)
        font = TTFont(path)

        expose_coding_ligatures(font, path)

        if "glyf" in font:
            font["glyf"]["zero"] = deepcopy(font["glyf"]["zero.zero"])
            if "gvar" in font:
                font["gvar"].variations["zero"] = deepcopy(
                    font["gvar"].variations["zero.zero"]
                )
        elif "CFF " in font:
            char_strings = font["CFF "].cff.topDictIndex[0].CharStrings
            source = char_strings["zero.zero"]
            target = char_strings["zero"]
            source.decompile()
            target.decompile()
            target.program = deepcopy(source.program)
        else:
            raise RuntimeError(f"unsupported font outlines: {path}")

        font["hmtx"].metrics["zero"] = font["hmtx"].metrics["zero.zero"]

        temporary = path.with_name(f".{path.name}.tmp")
        font.save(temporary)
        font.close()
        os.replace(temporary, path)
    PY

    mkdir patched
    for font in fonts/ttf/*.ttf; do
      nerd-font-patcher --complete --mono --quiet --outputdir patched "$font"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=coding-ligatures" ];
  };

  meta = {
    description = "Beautiful monospace font for design and code by Paper";
    homepage = "https://github.com/paper-design/paper-mono";
    changelog = "https://github.com/paper-design/paper-mono/commits/coding-ligatures";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.all;
  };
})
