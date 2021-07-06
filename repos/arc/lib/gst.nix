{ lib }: with lib; let
  shorthandSyntax = key: input: assert length (attrNames input.${key}) == 1; {
    # { key.name = value; } into { type = key; key = name; options = value; }
    type = key;
    ${key} = head (attrNames input.${key});
    options = head (attrValues input.${key});
  };
  pipelineNormalize = input:
  if isAttrs input.element or null then shorthandSyntax "element" input
  else if isAttrs input.caps or null then shorthandSyntax "caps" input
  else if input ? element then {
    type = "element";
  } // input else if input ? pipeline then {
    type = "pipeline";
  } // input else if input ? pipelines then {
    type = "pipelines";
  } // input else if input ? caps then {
    type = "caps";
  } // input else if isList input && length input > 0 && (pipelineNormalize (head input)).type == "pipeline" then {
    type = "pipelines";
    pipelines = input;
  } else if isList input then {
    type = "pipeline";
    pipeline = input;
  } else if isString input then {
    type = "element";
    element = input;
  } else throw "unsupported pipeline element";
  pipelineValue = input:
    if input == true then "true"
    else if input == false then "false"
    else toString input;
  pipelineKeyValue = k: v: "${k}=${pipelineValue v}";
  pipelineElementOptions = element: mapAttrsToList pipelineKeyValue element.options or { };
  pipelineStrings = input: let
    item = pipelineNormalize input;
  in {
    element = singleton item.element ++ pipelineElementOptions item;
    caps = singleton (concatStringsSep "," (singleton item.caps ++ pipelineElementOptions item));
    pipeline = concatLists (imap0 (i: e: optional (i > 0) "!" ++ pipelineStrings e) item.pipeline);
    pipelines = concatMap pipelineStrings item.pipelines;
  }.${item.type};
  pipelineString = p: concatStringsSep " " (pipelineStrings p);
  pipelineShellString = p: escapeShellArgs (pipelineStrings p);
  # TODO: are there scenarios where pipelines should be surrounded in ( brackets )?
  searchVarName = "GST_PLUGIN_SYSTEM_PATH_1_0";
  makeSearchVar = makeSearchPath "lib/gstreamer-1.0";
in {
  inherit pipelineNormalize pipelineKeyValue pipelineValue pipelineElementOptions
    pipelineStrings pipelineString pipelineShellString
    searchVarName makeSearchVar;
}
