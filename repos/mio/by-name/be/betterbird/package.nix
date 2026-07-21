{
  betterbird-unwrapped,
  wrapThunderbird,
  extraPolicies ? { },
  extraPoliciesFiles ? [ ],
}:
wrapThunderbird betterbird-unwrapped {
  applicationName = "betterbird";
  libName = "betterbird";
  inherit extraPolicies extraPoliciesFiles;
}
