# Licence evidence for exact store paths, never inferred from cache availability
# or a package-name prefix. The publication gate checks the actual built closure
# against these entries and fails closed on unknown or nonredistributable paths.
{ kernel, pkgs }:
let
  inherit (pkgs) lib;
  policy = import ../ci-policy.nix;
  dependencies =
    p:
    builtins.filter lib.isDerivation (
      (p.buildInputs or [ ])
      ++ (p.nativeBuildInputs or [ ])
      ++ (p.propagatedBuildInputs or [ ])
      ++ (p.propagatedNativeBuildInputs or [ ])
      ++ (p.depsBuildBuild or [ ])
      ++ (p.initialPath or [ ])
      ++ map (name: p.${name} or null) [
        "stdenv"
        "cc"
        "bintools"
        "libc"
        "expand-response-params"
      ]
    );
  # libc/libcurl runtime dependencies are not all exposed through buildInputs.
  # Explicit candidates are evaluated from the same repository nixpkgs as the kernel;
  # their metadata is not permission to publish anything outside exact outputs.
  runtimeCandidates = map (name: pkgs.${name}) [
    "curl"
    "libidn2"
    "libpsl"
    "nghttp2"
    "nghttp3"
    "ngtcp2"
    "libssh2"
    "openssl"
    "zlib"
    "zstd"
    "xz"
    "bzip2"
    "glibc"
    "acl"
    "attr"
    "keyutils"
    "krb5"
    "publicsuffix-list"
    "libunistring"
    "libxcrypt"
    "gmp"
    "gmpxx"
    "mpfr"
    "libmpc"
    "pcre2"
    "json_c"
    "isl"
    "linuxHeaders"
    # Runtime references added by newer nixpkgs: python3 -> mailcap, gnutls -> dns-root-data.
    "mailcap"
    "dns-root-data"
  ];
  nodes = builtins.genericClosure {
    startSet = map (value: {
      key = value.drvPath;
      inherit value;
    }) ([ kernel ] ++ runtimeCandidates);
    operator =
      entry:
      map (value: {
        key = value.drvPath;
        inherit value;
      }) (dependencies entry.value);
  };
  # Newer nixpkgs represents dual licensing as compound AND/OR objects and
  # licence exceptions as WITH objects.
  # Conservatively require every branch to permit redistribution, even for OR.
  # Explicit permission/restriction flags still win; malformed nodes fail closed.
  normalize =
    license:
    if builtins.isList license then
      lib.concatMap normalize license
    else if
      builtins.isAttrs license
      && !(license ? redistributable)
      && !(license ? free)
      && (license.licenseType or null) == "compound"
      && builtins.elem (license.operator or null) [
        "AND"
        "OR"
      ]
      && builtins.isList (license.licenses or null)
      && license.licenses != [ ]
    then
      lib.concatMap normalize license.licenses
    # "<license> WITH <exception>" (e.g. Apache-2.0 WITH LLVM-exception): both parts
    # must permit redistribution on their own.
    else if
      builtins.isAttrs license
      && !(license ? redistributable)
      && !(license ? free)
      && (license.licenseType or null) == "exception"
      && (license.operator or null) == "WITH"
      && builtins.isAttrs (license.license or null)
      && builtins.isAttrs (license.exception or null)
    then
      normalize license.license ++ normalize license.exception
    else
      [ license ];
  labels =
    licenses:
    map (
      license:
      if builtins.isAttrs license then
        license.spdxId or (license.shortName or (license.fullName or "unknown"))
      else if builtins.isString license then
        license
      else
        "unknown"
    ) (lib.toList licenses);
  record = name: license: path: {
    inherit path name;
    redistributable = policy.redistributable (normalize license);
    licenses = labels (normalize license);
  };
  packageEntries = lib.concatMap (
    entry:
    map (
      output:
      record (entry.value.name or "unnamed") (entry.value.meta.license or [ ]
      ) entry.value.${output}.outPath
    ) (entry.value.outputs or [ ])
  ) nodes;
  # Two generated outputs lack independent nixpkgs metadata. Their provenance is
  # explicit: kernel.configfile is generated Linux configuration (GPL-2.0-only);
  # rust-lib-src.nix extracts library/ from rustc.src, retaining Rust's licence.
  # Do not alter either derivation just to add meta: that would change cache hashes.
  generatedEntries = [
    (record "generated Linux kernel configuration" kernel.meta.license (toString kernel.configfile))
    (record "Rust standard-library sources (rustc.src/library)" pkgs.rustc.meta.license (
      toString pkgs.rustPlatform.rustLibSrc
    ))
  ];
in
{
  roots = map (output: kernel.${output}.outPath) kernel.outputs;
  entries = packageEntries ++ generatedEntries;
}
