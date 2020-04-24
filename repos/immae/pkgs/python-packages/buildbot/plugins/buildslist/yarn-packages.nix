{fetchurl, linkFarm}: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [

    {
      name = "_types_babel_types___babel_types_7.0.7.tgz";
      path = fetchurl {
        name = "_types_babel_types___babel_types_7.0.7.tgz";
        url  = "https://registry.yarnpkg.com/@types/babel-types/-/babel-types-7.0.7.tgz";
        sha1 = "667eb1640e8039436028055737d2b9986ee336e3";
      };
    }

    {
      name = "_types_babylon___babylon_6.16.5.tgz";
      path = fetchurl {
        name = "_types_babylon___babylon_6.16.5.tgz";
        url  = "https://registry.yarnpkg.com/@types/babylon/-/babylon-6.16.5.tgz";
        sha1 = "1c5641db69eb8cdf378edd25b4be7754beeb48b4";
      };
    }

    {
      name = "_types_color_name___color_name_1.1.1.tgz";
      path = fetchurl {
        name = "_types_color_name___color_name_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/@types/color-name/-/color-name-1.1.1.tgz";
        sha1 = "1c1261bbeaa10a8055bbc5d8ab84b7b2afc846a0";
      };
    }

    {
      name = "Base64___Base64_0.2.1.tgz";
      path = fetchurl {
        name = "Base64___Base64_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/Base64/-/Base64-0.2.1.tgz";
        sha1 = "ba3a4230708e186705065e66babdd4c35cf60028";
      };
    }

    {
      name = "JSONStream___JSONStream_0.6.4.tgz";
      path = fetchurl {
        name = "JSONStream___JSONStream_0.6.4.tgz";
        url  = "https://registry.yarnpkg.com/JSONStream/-/JSONStream-0.6.4.tgz";
        sha1 = "4b2c8063f8f512787b2375f7ee9db69208fa2dcb";
      };
    }

    {
      name = "JSONStream___JSONStream_0.7.4.tgz";
      path = fetchurl {
        name = "JSONStream___JSONStream_0.7.4.tgz";
        url  = "https://registry.yarnpkg.com/JSONStream/-/JSONStream-0.7.4.tgz";
        sha1 = "734290e41511eea7c2cfe151fbf9a563a97b9786";
      };
    }

    {
      name = "abbrev___abbrev_1.1.1.tgz";
      path = fetchurl {
        name = "abbrev___abbrev_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/abbrev/-/abbrev-1.1.1.tgz";
        sha1 = "f8f2c887ad10bf67f634f005b6987fed3179aac8";
      };
    }

    {
      name = "abbrev___abbrev_1.0.9.tgz";
      path = fetchurl {
        name = "abbrev___abbrev_1.0.9.tgz";
        url  = "https://registry.yarnpkg.com/abbrev/-/abbrev-1.0.9.tgz";
        sha1 = "91b4792588a7738c25f35dd6f63752a2f8776135";
      };
    }

    {
      name = "accepts___accepts_1.3.3.tgz";
      path = fetchurl {
        name = "accepts___accepts_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/accepts/-/accepts-1.3.3.tgz";
        sha1 = "c3ca7434938648c3e0d9c1e328dd68b622c284ca";
      };
    }

    {
      name = "acorn_globals___acorn_globals_3.1.0.tgz";
      path = fetchurl {
        name = "acorn_globals___acorn_globals_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/acorn-globals/-/acorn-globals-3.1.0.tgz";
        sha1 = "fd8270f71fbb4996b004fa880ee5d46573a731bf";
      };
    }

    {
      name = "acorn___acorn_2.7.0.tgz";
      path = fetchurl {
        name = "acorn___acorn_2.7.0.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-2.7.0.tgz";
        sha1 = "ab6e7d9d886aaca8b085bc3312b79a198433f0e7";
      };
    }

    {
      name = "acorn___acorn_3.3.0.tgz";
      path = fetchurl {
        name = "acorn___acorn_3.3.0.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-3.3.0.tgz";
        sha1 = "45e37fb39e8da3f25baee3ff5369e2bb5f22017a";
      };
    }

    {
      name = "acorn___acorn_4.0.13.tgz";
      path = fetchurl {
        name = "acorn___acorn_4.0.13.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-4.0.13.tgz";
        sha1 = "105495ae5361d697bd195c825192e1ad7f253787";
      };
    }

    {
      name = "acorn___acorn_2.6.4.tgz";
      path = fetchurl {
        name = "acorn___acorn_2.6.4.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-2.6.4.tgz";
        sha1 = "eb1f45b4a43fa31d03701a5ec46f3b52673e90ee";
      };
    }

    {
      name = "after___after_0.8.2.tgz";
      path = fetchurl {
        name = "after___after_0.8.2.tgz";
        url  = "https://registry.yarnpkg.com/after/-/after-0.8.2.tgz";
        sha1 = "fedb394f9f0e02aa9768e702bda23b505fae7e1f";
      };
    }

    {
      name = "ajv___ajv_6.12.0.tgz";
      path = fetchurl {
        name = "ajv___ajv_6.12.0.tgz";
        url  = "https://registry.yarnpkg.com/ajv/-/ajv-6.12.0.tgz";
        sha1 = "06d60b96d87b8454a5adaba86e7854da629db4b7";
      };
    }

    {
      name = "align_text___align_text_0.1.4.tgz";
      path = fetchurl {
        name = "align_text___align_text_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/align-text/-/align-text-0.1.4.tgz";
        sha1 = "0cd90a561093f35d0a99256c22b7069433fad117";
      };
    }

    {
      name = "alter___alter_0.2.0.tgz";
      path = fetchurl {
        name = "alter___alter_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/alter/-/alter-0.2.0.tgz";
        sha1 = "c7588808617572034aae62480af26b1d4d1cb3cd";
      };
    }

    {
      name = "amdefine___amdefine_1.0.1.tgz";
      path = fetchurl {
        name = "amdefine___amdefine_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/amdefine/-/amdefine-1.0.1.tgz";
        sha1 = "4a5282ac164729e93619bcfd3ad151f817ce91f5";
      };
    }

    {
      name = "ansi_gray___ansi_gray_0.1.1.tgz";
      path = fetchurl {
        name = "ansi_gray___ansi_gray_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-gray/-/ansi-gray-0.1.1.tgz";
        sha1 = "2962cf54ec9792c48510a3deb524436861ef7251";
      };
    }

    {
      name = "ansi_regex___ansi_regex_0.2.1.tgz";
      path = fetchurl {
        name = "ansi_regex___ansi_regex_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-0.2.1.tgz";
        sha1 = "0d8e946967a3d8143f93e24e298525fc1b2235f9";
      };
    }

    {
      name = "ansi_regex___ansi_regex_1.1.1.tgz";
      path = fetchurl {
        name = "ansi_regex___ansi_regex_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-1.1.1.tgz";
        sha1 = "41c847194646375e6a1a5d10c3ca054ef9fc980d";
      };
    }

    {
      name = "ansi_regex___ansi_regex_2.1.1.tgz";
      path = fetchurl {
        name = "ansi_regex___ansi_regex_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-2.1.1.tgz";
        sha1 = "c3b33ab5ee360d86e0e628f0468ae7ef27d654df";
      };
    }

    {
      name = "ansi_regex___ansi_regex_3.0.0.tgz";
      path = fetchurl {
        name = "ansi_regex___ansi_regex_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-3.0.0.tgz";
        sha1 = "ed0317c322064f79466c02966bddb605ab37d998";
      };
    }

    {
      name = "ansi_styles___ansi_styles_1.1.0.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-1.1.0.tgz";
        sha1 = "eaecbf66cd706882760b2f4691582b8f55d7a7de";
      };
    }

    {
      name = "ansi_styles___ansi_styles_2.2.1.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-2.2.1.tgz";
        sha1 = "b432dd3358b634cf75e1e4664368240533c1ddbe";
      };
    }

    {
      name = "ansi_styles___ansi_styles_4.2.1.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_4.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-4.2.1.tgz";
        sha1 = "90ae75c424d008d2624c5bf29ead3177ebfcf359";
      };
    }

    {
      name = "ansi_styles___ansi_styles_1.0.0.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-1.0.0.tgz";
        sha1 = "cb102df1c56f5123eab8b67cd7b98027a0279178";
      };
    }

    {
      name = "ansi_wrap___ansi_wrap_0.1.0.tgz";
      path = fetchurl {
        name = "ansi_wrap___ansi_wrap_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/ansi-wrap/-/ansi-wrap-0.1.0.tgz";
        sha1 = "a82250ddb0015e9a27ca82e82ea603bbfa45efaf";
      };
    }

    {
      name = "ansicolors___ansicolors_0.2.1.tgz";
      path = fetchurl {
        name = "ansicolors___ansicolors_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansicolors/-/ansicolors-0.2.1.tgz";
        sha1 = "be089599097b74a5c9c4a84a0cdbcdb62bd87aef";
      };
    }

    {
      name = "anymatch___anymatch_1.3.2.tgz";
      path = fetchurl {
        name = "anymatch___anymatch_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/anymatch/-/anymatch-1.3.2.tgz";
        sha1 = "553dcb8f91e3c889845dfdba34c77721b90b9d7a";
      };
    }

    {
      name = "aproba___aproba_1.2.0.tgz";
      path = fetchurl {
        name = "aproba___aproba_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/aproba/-/aproba-1.2.0.tgz";
        sha1 = "6802e6264efd18c790a1b0d517f0f2627bf2c94a";
      };
    }

    {
      name = "archy___archy_1.0.0.tgz";
      path = fetchurl {
        name = "archy___archy_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/archy/-/archy-1.0.0.tgz";
        sha1 = "f9c8c13757cc1dd7bc379ac77b2c62a5c2868c40";
      };
    }

    {
      name = "archy___archy_0.0.2.tgz";
      path = fetchurl {
        name = "archy___archy_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/archy/-/archy-0.0.2.tgz";
        sha1 = "910f43bf66141fc335564597abc189df44b3d35e";
      };
    }

    {
      name = "are_we_there_yet___are_we_there_yet_1.1.5.tgz";
      path = fetchurl {
        name = "are_we_there_yet___are_we_there_yet_1.1.5.tgz";
        url  = "https://registry.yarnpkg.com/are-we-there-yet/-/are-we-there-yet-1.1.5.tgz";
        sha1 = "4b35c2944f062a8bfcda66410760350fe9ddfc21";
      };
    }

    {
      name = "argparse___argparse_1.0.10.tgz";
      path = fetchurl {
        name = "argparse___argparse_1.0.10.tgz";
        url  = "https://registry.yarnpkg.com/argparse/-/argparse-1.0.10.tgz";
        sha1 = "bcd6791ea5ae09725e17e5ad988134cd40b3d911";
      };
    }

    {
      name = "argparse___argparse_0.1.16.tgz";
      path = fetchurl {
        name = "argparse___argparse_0.1.16.tgz";
        url  = "https://registry.yarnpkg.com/argparse/-/argparse-0.1.16.tgz";
        sha1 = "cfd01e0fbba3d6caed049fbd758d40f65196f57c";
      };
    }

    {
      name = "arr_diff___arr_diff_2.0.0.tgz";
      path = fetchurl {
        name = "arr_diff___arr_diff_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/arr-diff/-/arr-diff-2.0.0.tgz";
        sha1 = "8f3b827f955a8bd669697e4a4256ac3ceae356cf";
      };
    }

    {
      name = "arr_diff___arr_diff_4.0.0.tgz";
      path = fetchurl {
        name = "arr_diff___arr_diff_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/arr-diff/-/arr-diff-4.0.0.tgz";
        sha1 = "d6461074febfec71e7e15235761a329a5dc7c520";
      };
    }

    {
      name = "arr_flatten___arr_flatten_1.1.0.tgz";
      path = fetchurl {
        name = "arr_flatten___arr_flatten_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/arr-flatten/-/arr-flatten-1.1.0.tgz";
        sha1 = "36048bbff4e7b47e136644316c99669ea5ae91f1";
      };
    }

    {
      name = "arr_union___arr_union_3.1.0.tgz";
      path = fetchurl {
        name = "arr_union___arr_union_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/arr-union/-/arr-union-3.1.0.tgz";
        sha1 = "e39b09aea9def866a8f206e288af63919bae39c4";
      };
    }

    {
      name = "array_differ___array_differ_1.0.0.tgz";
      path = fetchurl {
        name = "array_differ___array_differ_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/array-differ/-/array-differ-1.0.0.tgz";
        sha1 = "eff52e3758249d33be402b8bb8e564bb2b5d4031";
      };
    }

    {
      name = "array_each___array_each_1.0.1.tgz";
      path = fetchurl {
        name = "array_each___array_each_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/array-each/-/array-each-1.0.1.tgz";
        sha1 = "a794af0c05ab1752846ee753a1f211a05ba0c44f";
      };
    }

    {
      name = "array_filter___array_filter_0.0.1.tgz";
      path = fetchurl {
        name = "array_filter___array_filter_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/array-filter/-/array-filter-0.0.1.tgz";
        sha1 = "7da8cf2e26628ed732803581fd21f67cacd2eeec";
      };
    }

    {
      name = "array_find_index___array_find_index_1.0.2.tgz";
      path = fetchurl {
        name = "array_find_index___array_find_index_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/array-find-index/-/array-find-index-1.0.2.tgz";
        sha1 = "df010aa1287e164bbda6f9723b0a96a1ec4187a1";
      };
    }

    {
      name = "array_map___array_map_0.0.0.tgz";
      path = fetchurl {
        name = "array_map___array_map_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/array-map/-/array-map-0.0.0.tgz";
        sha1 = "88a2bab73d1cf7bcd5c1b118a003f66f665fa662";
      };
    }

    {
      name = "array_reduce___array_reduce_0.0.0.tgz";
      path = fetchurl {
        name = "array_reduce___array_reduce_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/array-reduce/-/array-reduce-0.0.0.tgz";
        sha1 = "173899d3ffd1c7d9383e4479525dbe278cab5f2b";
      };
    }

    {
      name = "array_slice___array_slice_0.2.3.tgz";
      path = fetchurl {
        name = "array_slice___array_slice_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/array-slice/-/array-slice-0.2.3.tgz";
        sha1 = "dd3cfb80ed7973a75117cdac69b0b99ec86186f5";
      };
    }

    {
      name = "array_slice___array_slice_1.1.0.tgz";
      path = fetchurl {
        name = "array_slice___array_slice_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/array-slice/-/array-slice-1.1.0.tgz";
        sha1 = "e368ea15f89bc7069f7ffb89aec3a6c7d4ac22d4";
      };
    }

    {
      name = "array_uniq___array_uniq_1.0.3.tgz";
      path = fetchurl {
        name = "array_uniq___array_uniq_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/array-uniq/-/array-uniq-1.0.3.tgz";
        sha1 = "af6ac877a25cc7f74e058894753858dfdb24fdb6";
      };
    }

    {
      name = "array_unique___array_unique_0.2.1.tgz";
      path = fetchurl {
        name = "array_unique___array_unique_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/array-unique/-/array-unique-0.2.1.tgz";
        sha1 = "a1d97ccafcbc2625cc70fadceb36a50c58b01a53";
      };
    }

    {
      name = "array_unique___array_unique_0.3.2.tgz";
      path = fetchurl {
        name = "array_unique___array_unique_0.3.2.tgz";
        url  = "https://registry.yarnpkg.com/array-unique/-/array-unique-0.3.2.tgz";
        sha1 = "a894b75d4bc4f6cd679ef3244a9fd8f46ae2d428";
      };
    }

    {
      name = "arraybuffer.slice___arraybuffer.slice_0.0.6.tgz";
      path = fetchurl {
        name = "arraybuffer.slice___arraybuffer.slice_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/arraybuffer.slice/-/arraybuffer.slice-0.0.6.tgz";
        sha1 = "f33b2159f0532a3f3107a272c0ccfbd1ad2979ca";
      };
    }

    {
      name = "asap___asap_2.0.6.tgz";
      path = fetchurl {
        name = "asap___asap_2.0.6.tgz";
        url  = "https://registry.yarnpkg.com/asap/-/asap-2.0.6.tgz";
        sha1 = "e50347611d7e690943208bbdafebcbc2fb866d46";
      };
    }

    {
      name = "asn1___asn1_0.1.11.tgz";
      path = fetchurl {
        name = "asn1___asn1_0.1.11.tgz";
        url  = "https://registry.yarnpkg.com/asn1/-/asn1-0.1.11.tgz";
        sha1 = "559be18376d08a4ec4dbe80877d27818639b2df7";
      };
    }

    {
      name = "asn1___asn1_0.2.4.tgz";
      path = fetchurl {
        name = "asn1___asn1_0.2.4.tgz";
        url  = "https://registry.yarnpkg.com/asn1/-/asn1-0.2.4.tgz";
        sha1 = "8d2475dfab553bb33e77b54e59e880bb8ce23136";
      };
    }

    {
      name = "assert_plus___assert_plus_1.0.0.tgz";
      path = fetchurl {
        name = "assert_plus___assert_plus_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/assert-plus/-/assert-plus-1.0.0.tgz";
        sha1 = "f12e0f3c5d77b0b1cdd9146942e4e96c1e4dd525";
      };
    }

    {
      name = "assert_plus___assert_plus_0.1.5.tgz";
      path = fetchurl {
        name = "assert_plus___assert_plus_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/assert-plus/-/assert-plus-0.1.5.tgz";
        sha1 = "ee74009413002d84cec7219c6ac811812e723160";
      };
    }

    {
      name = "assert___assert_1.1.2.tgz";
      path = fetchurl {
        name = "assert___assert_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/assert/-/assert-1.1.2.tgz";
        sha1 = "adaa04c46bb58c6dd1f294da3eb26e6228eb6e44";
      };
    }

    {
      name = "assign_symbols___assign_symbols_1.0.0.tgz";
      path = fetchurl {
        name = "assign_symbols___assign_symbols_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/assign-symbols/-/assign-symbols-1.0.0.tgz";
        sha1 = "59667f41fadd4f20ccbc2bb96b8d4f7f78ec0367";
      };
    }

    {
      name = "astw___astw_2.2.0.tgz";
      path = fetchurl {
        name = "astw___astw_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/astw/-/astw-2.2.0.tgz";
        sha1 = "7bd41784d32493987aeb239b6b4e1c57a873b917";
      };
    }

    {
      name = "async_each___async_each_1.0.3.tgz";
      path = fetchurl {
        name = "async_each___async_each_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/async-each/-/async-each-1.0.3.tgz";
        sha1 = "b727dbf87d7651602f06f4d4ac387f47d91b0cbf";
      };
    }

    {
      name = "async_foreach___async_foreach_0.1.3.tgz";
      path = fetchurl {
        name = "async_foreach___async_foreach_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/async-foreach/-/async-foreach-0.1.3.tgz";
        sha1 = "36121f845c0578172de419a97dbeb1d16ec34542";
      };
    }

    {
      name = "async___async_1.5.2.tgz";
      path = fetchurl {
        name = "async___async_1.5.2.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-1.5.2.tgz";
        sha1 = "ec6a61ae56480c0c3cb241c95618e20892f9672a";
      };
    }

    {
      name = "async___async_0.2.10.tgz";
      path = fetchurl {
        name = "async___async_0.2.10.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-0.2.10.tgz";
        sha1 = "b6bbe0b0674b9d719708ca38de8c237cb526c3d1";
      };
    }

    {
      name = "async___async_0.8.0.tgz";
      path = fetchurl {
        name = "async___async_0.8.0.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-0.8.0.tgz";
        sha1 = "ee65ec77298c2ff1456bc4418a052d0f06435112";
      };
    }

    {
      name = "async___async_0.9.2.tgz";
      path = fetchurl {
        name = "async___async_0.9.2.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-0.9.2.tgz";
        sha1 = "aea74d5e61c1f899613bf64bda66d4c78f2fd17d";
      };
    }

    {
      name = "asynckit___asynckit_0.4.0.tgz";
      path = fetchurl {
        name = "asynckit___asynckit_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/asynckit/-/asynckit-0.4.0.tgz";
        sha1 = "c79ed97f7f34cb8f2ba1bc9790bcc366474b4b79";
      };
    }

    {
      name = "atob___atob_2.1.2.tgz";
      path = fetchurl {
        name = "atob___atob_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/atob/-/atob-2.1.2.tgz";
        sha1 = "6d9517eb9e030d2436666651e86bd9f6f13533c9";
      };
    }

    {
      name = "aws_sign2___aws_sign2_0.5.0.tgz";
      path = fetchurl {
        name = "aws_sign2___aws_sign2_0.5.0.tgz";
        url  = "https://registry.yarnpkg.com/aws-sign2/-/aws-sign2-0.5.0.tgz";
        sha1 = "c57103f7a17fc037f02d7c2e64b602ea223f7d63";
      };
    }

    {
      name = "aws_sign2___aws_sign2_0.7.0.tgz";
      path = fetchurl {
        name = "aws_sign2___aws_sign2_0.7.0.tgz";
        url  = "https://registry.yarnpkg.com/aws-sign2/-/aws-sign2-0.7.0.tgz";
        sha1 = "b46e890934a9591f2d2f6f86d7e6a9f1b3fe76a8";
      };
    }

    {
      name = "aws_sign___aws_sign_0.3.0.tgz";
      path = fetchurl {
        name = "aws_sign___aws_sign_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/aws-sign/-/aws-sign-0.3.0.tgz";
        sha1 = "3d81ca69b474b1e16518728b51c24ff0bbedc6e9";
      };
    }

    {
      name = "aws4___aws4_1.9.1.tgz";
      path = fetchurl {
        name = "aws4___aws4_1.9.1.tgz";
        url  = "https://registry.yarnpkg.com/aws4/-/aws4-1.9.1.tgz";
        sha1 = "7e33d8f7d449b3f673cd72deb9abdc552dbe528e";
      };
    }

    {
      name = "babel_runtime___babel_runtime_6.26.0.tgz";
      path = fetchurl {
        name = "babel_runtime___babel_runtime_6.26.0.tgz";
        url  = "https://registry.yarnpkg.com/babel-runtime/-/babel-runtime-6.26.0.tgz";
        sha1 = "965c7058668e82b55d7bfe04ff2337bc8b5647fe";
      };
    }

    {
      name = "babel_types___babel_types_6.26.0.tgz";
      path = fetchurl {
        name = "babel_types___babel_types_6.26.0.tgz";
        url  = "https://registry.yarnpkg.com/babel-types/-/babel-types-6.26.0.tgz";
        sha1 = "a3b073f94ab49eb6fa55cd65227a334380632497";
      };
    }

    {
      name = "babylon___babylon_6.18.0.tgz";
      path = fetchurl {
        name = "babylon___babylon_6.18.0.tgz";
        url  = "https://registry.yarnpkg.com/babylon/-/babylon-6.18.0.tgz";
        sha1 = "af2f3b88fa6f5c1e4c634d1a0f8eac4f55b395e3";
      };
    }

    {
      name = "backo2___backo2_1.0.2.tgz";
      path = fetchurl {
        name = "backo2___backo2_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/backo2/-/backo2-1.0.2.tgz";
        sha1 = "31ab1ac8b129363463e35b3ebb69f4dfcfba7947";
      };
    }

    {
      name = "balanced_match___balanced_match_1.0.0.tgz";
      path = fetchurl {
        name = "balanced_match___balanced_match_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/balanced-match/-/balanced-match-1.0.0.tgz";
        sha1 = "89b4d199ab2bee49de164ea02b89ce462d71b767";
      };
    }

    {
      name = "base64_arraybuffer___base64_arraybuffer_0.1.5.tgz";
      path = fetchurl {
        name = "base64_arraybuffer___base64_arraybuffer_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/base64-arraybuffer/-/base64-arraybuffer-0.1.5.tgz";
        sha1 = "73926771923b5a19747ad666aa5cd4bf9c6e9ce8";
      };
    }

    {
      name = "base64_js___base64_js_0.0.8.tgz";
      path = fetchurl {
        name = "base64_js___base64_js_0.0.8.tgz";
        url  = "https://registry.yarnpkg.com/base64-js/-/base64-js-0.0.8.tgz";
        sha1 = "1101e9544f4a76b1bc3b26d452ca96d7a35e7978";
      };
    }

    {
      name = "base64id___base64id_1.0.0.tgz";
      path = fetchurl {
        name = "base64id___base64id_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/base64id/-/base64id-1.0.0.tgz";
        sha1 = "47688cb99bb6804f0e06d3e763b1c32e57d8e6b6";
      };
    }

    {
      name = "base___base_0.11.2.tgz";
      path = fetchurl {
        name = "base___base_0.11.2.tgz";
        url  = "https://registry.yarnpkg.com/base/-/base-0.11.2.tgz";
        sha1 = "7bde5ced145b6d551a90db87f83c558b4eb48a8f";
      };
    }

    {
      name = "batch___batch_0.5.3.tgz";
      path = fetchurl {
        name = "batch___batch_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/batch/-/batch-0.5.3.tgz";
        sha1 = "3f3414f380321743bfc1042f9a83ff1d5824d464";
      };
    }

    {
      name = "bcrypt_pbkdf___bcrypt_pbkdf_1.0.2.tgz";
      path = fetchurl {
        name = "bcrypt_pbkdf___bcrypt_pbkdf_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/bcrypt-pbkdf/-/bcrypt-pbkdf-1.0.2.tgz";
        sha1 = "a4301d389b6a43f9b67ff3ca11a3f6637e360e9e";
      };
    }

    {
      name = "beeper___beeper_1.1.1.tgz";
      path = fetchurl {
        name = "beeper___beeper_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/beeper/-/beeper-1.1.1.tgz";
        sha1 = "e6d5ea8c5dad001304a70b22638447f69cb2f809";
      };
    }

    {
      name = "better_assert___better_assert_1.0.2.tgz";
      path = fetchurl {
        name = "better_assert___better_assert_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/better-assert/-/better-assert-1.0.2.tgz";
        sha1 = "40866b9e1b9e0b55b481894311e68faffaebc522";
      };
    }

    {
      name = "binary_extensions___binary_extensions_1.13.1.tgz";
      path = fetchurl {
        name = "binary_extensions___binary_extensions_1.13.1.tgz";
        url  = "https://registry.yarnpkg.com/binary-extensions/-/binary-extensions-1.13.1.tgz";
        sha1 = "598afe54755b2868a5330d2aff9d4ebb53209b65";
      };
    }

    {
      name = "binary___binary_0.3.0.tgz";
      path = fetchurl {
        name = "binary___binary_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/binary/-/binary-0.3.0.tgz";
        sha1 = "9f60553bc5ce8c3386f3b553cff47462adecaa79";
      };
    }

    {
      name = "binaryextensions___binaryextensions_1.0.1.tgz";
      path = fetchurl {
        name = "binaryextensions___binaryextensions_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/binaryextensions/-/binaryextensions-1.0.1.tgz";
        sha1 = "1e637488b35b58bda5f4774bf96a5212a8c90755";
      };
    }

    {
      name = "bindings___bindings_1.5.0.tgz";
      path = fetchurl {
        name = "bindings___bindings_1.5.0.tgz";
        url  = "https://registry.yarnpkg.com/bindings/-/bindings-1.5.0.tgz";
        sha1 = "10353c9e945334bc0511a6d90b38fbc7c9c504df";
      };
    }

    {
      name = "bl___bl_0.9.5.tgz";
      path = fetchurl {
        name = "bl___bl_0.9.5.tgz";
        url  = "https://registry.yarnpkg.com/bl/-/bl-0.9.5.tgz";
        sha1 = "c06b797af085ea00bc527afc8efcf11de2232054";
      };
    }

    {
      name = "blob___blob_0.0.4.tgz";
      path = fetchurl {
        name = "blob___blob_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/blob/-/blob-0.0.4.tgz";
        sha1 = "bcf13052ca54463f30f9fc7e95b9a47630a94921";
      };
    }

    {
      name = "block_stream___block_stream_0.0.9.tgz";
      path = fetchurl {
        name = "block_stream___block_stream_0.0.9.tgz";
        url  = "https://registry.yarnpkg.com/block-stream/-/block-stream-0.0.9.tgz";
        sha1 = "13ebfe778a03205cfe03751481ebb4b3300c126a";
      };
    }

    {
      name = "bluebird___bluebird_2.11.0.tgz";
      path = fetchurl {
        name = "bluebird___bluebird_2.11.0.tgz";
        url  = "https://registry.yarnpkg.com/bluebird/-/bluebird-2.11.0.tgz";
        sha1 = "534b9033c022c9579c56ba3b3e5a5caafbb650e1";
      };
    }

    {
      name = "body_parser___body_parser_1.19.0.tgz";
      path = fetchurl {
        name = "body_parser___body_parser_1.19.0.tgz";
        url  = "https://registry.yarnpkg.com/body-parser/-/body-parser-1.19.0.tgz";
        sha1 = "96b2709e57c9c4e09a6fd66a8fd979844f69f08a";
      };
    }

    {
      name = "body_parser___body_parser_1.14.2.tgz";
      path = fetchurl {
        name = "body_parser___body_parser_1.14.2.tgz";
        url  = "https://registry.yarnpkg.com/body-parser/-/body-parser-1.14.2.tgz";
        sha1 = "1015cb1fe2c443858259581db53332f8d0cf50f9";
      };
    }

    {
      name = "boom___boom_0.4.2.tgz";
      path = fetchurl {
        name = "boom___boom_0.4.2.tgz";
        url  = "https://registry.yarnpkg.com/boom/-/boom-0.4.2.tgz";
        sha1 = "7a636e9ded4efcefb19cef4947a3c67dfaee911b";
      };
    }

    {
      name = "bower_config___bower_config_0.5.3.tgz";
      path = fetchurl {
        name = "bower_config___bower_config_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/bower-config/-/bower-config-0.5.3.tgz";
        sha1 = "98fc5b41a87870ef9cbb9297635cf81f5505fdb1";
      };
    }

    {
      name = "bower_endpoint_parser___bower_endpoint_parser_0.2.2.tgz";
      path = fetchurl {
        name = "bower_endpoint_parser___bower_endpoint_parser_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/bower-endpoint-parser/-/bower-endpoint-parser-0.2.2.tgz";
        sha1 = "00b565adbfab6f2d35addde977e97962acbcb3f6";
      };
    }

    {
      name = "bower_json___bower_json_0.4.0.tgz";
      path = fetchurl {
        name = "bower_json___bower_json_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/bower-json/-/bower-json-0.4.0.tgz";
        sha1 = "a99c3ccf416ef0590ed0ded252c760f1c6d93766";
      };
    }

    {
      name = "bower_logger___bower_logger_0.2.2.tgz";
      path = fetchurl {
        name = "bower_logger___bower_logger_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/bower-logger/-/bower-logger-0.2.2.tgz";
        sha1 = "39be07e979b2fc8e03a94634205ed9422373d381";
      };
    }

    {
      name = "bower_registry_client___bower_registry_client_0.2.4.tgz";
      path = fetchurl {
        name = "bower_registry_client___bower_registry_client_0.2.4.tgz";
        url  = "https://registry.yarnpkg.com/bower-registry-client/-/bower-registry-client-0.2.4.tgz";
        sha1 = "269fc7e898b627fb939d1144a593254d7fbbeebc";
      };
    }

    {
      name = "bower___bower_1.3.8.tgz";
      path = fetchurl {
        name = "bower___bower_1.3.8.tgz";
        url  = "https://registry.yarnpkg.com/bower/-/bower-1.3.8.tgz";
        sha1 = "afa3338a8a88a6e084c38112ea4a15998cbee3e6";
      };
    }

    {
      name = "brace_expansion___brace_expansion_1.1.11.tgz";
      path = fetchurl {
        name = "brace_expansion___brace_expansion_1.1.11.tgz";
        url  = "https://registry.yarnpkg.com/brace-expansion/-/brace-expansion-1.1.11.tgz";
        sha1 = "3c7fcbf529d87226f3d2f52b966ff5271eb441dd";
      };
    }

    {
      name = "braces___braces_0.1.5.tgz";
      path = fetchurl {
        name = "braces___braces_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/braces/-/braces-0.1.5.tgz";
        sha1 = "c085711085291d8b75fdd74eab0f8597280711e6";
      };
    }

    {
      name = "braces___braces_1.8.5.tgz";
      path = fetchurl {
        name = "braces___braces_1.8.5.tgz";
        url  = "https://registry.yarnpkg.com/braces/-/braces-1.8.5.tgz";
        sha1 = "ba77962e12dff969d6b76711e914b737857bf6a7";
      };
    }

    {
      name = "braces___braces_2.3.2.tgz";
      path = fetchurl {
        name = "braces___braces_2.3.2.tgz";
        url  = "https://registry.yarnpkg.com/braces/-/braces-2.3.2.tgz";
        sha1 = "5979fd3f14cd531565e5fa2df1abfff1dfaee729";
      };
    }

    {
      name = "browser_pack___browser_pack_2.0.1.tgz";
      path = fetchurl {
        name = "browser_pack___browser_pack_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/browser-pack/-/browser-pack-2.0.1.tgz";
        sha1 = "5d1c527f56c582677411c4db2a128648ff6bf150";
      };
    }

    {
      name = "browser_resolve___browser_resolve_1.2.4.tgz";
      path = fetchurl {
        name = "browser_resolve___browser_resolve_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/browser-resolve/-/browser-resolve-1.2.4.tgz";
        sha1 = "59ae7820a82955ecd32f5fb7c468ac21c4723806";
      };
    }

    {
      name = "browserify_shim___browserify_shim_2.0.10.tgz";
      path = fetchurl {
        name = "browserify_shim___browserify_shim_2.0.10.tgz";
        url  = "https://registry.yarnpkg.com/browserify-shim/-/browserify-shim-2.0.10.tgz";
        sha1 = "74a0ed5b9b784a5a287906513a896d31f54a84b8";
      };
    }

    {
      name = "browserify_zlib___browserify_zlib_0.1.4.tgz";
      path = fetchurl {
        name = "browserify_zlib___browserify_zlib_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/browserify-zlib/-/browserify-zlib-0.1.4.tgz";
        sha1 = "bb35f8a519f600e0fa6b8485241c979d0141fb2d";
      };
    }

    {
      name = "browserify___browserify_3.46.1.tgz";
      path = fetchurl {
        name = "browserify___browserify_3.46.1.tgz";
        url  = "https://registry.yarnpkg.com/browserify/-/browserify-3.46.1.tgz";
        sha1 = "2c2e4a7f2f408178e78c223b5b57b37c2185ad8e";
      };
    }

    {
      name = "buffer_alloc_unsafe___buffer_alloc_unsafe_1.1.0.tgz";
      path = fetchurl {
        name = "buffer_alloc_unsafe___buffer_alloc_unsafe_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/buffer-alloc-unsafe/-/buffer-alloc-unsafe-1.1.0.tgz";
        sha1 = "bd7dc26ae2972d0eda253be061dba992349c19f0";
      };
    }

    {
      name = "buffer_alloc___buffer_alloc_1.2.0.tgz";
      path = fetchurl {
        name = "buffer_alloc___buffer_alloc_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/buffer-alloc/-/buffer-alloc-1.2.0.tgz";
        sha1 = "890dd90d923a873e08e10e5fd51a57e5b7cce0ec";
      };
    }

    {
      name = "buffer_fill___buffer_fill_1.0.0.tgz";
      path = fetchurl {
        name = "buffer_fill___buffer_fill_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/buffer-fill/-/buffer-fill-1.0.0.tgz";
        sha1 = "f8f78b76789888ef39f205cd637f68e702122b2c";
      };
    }

    {
      name = "buffer___buffer_2.1.13.tgz";
      path = fetchurl {
        name = "buffer___buffer_2.1.13.tgz";
        url  = "https://registry.yarnpkg.com/buffer/-/buffer-2.1.13.tgz";
        sha1 = "c88838ebf79f30b8b4a707788470bea8a62c2355";
      };
    }

    {
      name = "buffers___buffers_0.1.1.tgz";
      path = fetchurl {
        name = "buffers___buffers_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/buffers/-/buffers-0.1.1.tgz";
        sha1 = "b24579c3bed4d6d396aeee6d9a8ae7f5482ab7bb";
      };
    }

    {
      name = "bufferstreams___bufferstreams_0.0.2.tgz";
      path = fetchurl {
        name = "bufferstreams___bufferstreams_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/bufferstreams/-/bufferstreams-0.0.2.tgz";
        sha1 = "7ce8dff968bbac00b9e90158a2c41456f740abdd";
      };
    }

    {
      name = "builtins___builtins_0.0.7.tgz";
      path = fetchurl {
        name = "builtins___builtins_0.0.7.tgz";
        url  = "https://registry.yarnpkg.com/builtins/-/builtins-0.0.7.tgz";
        sha1 = "355219cd6cf18dbe7c01cc7fd2dce765cfdc549a";
      };
    }

    {
      name = "bytes___bytes_2.2.0.tgz";
      path = fetchurl {
        name = "bytes___bytes_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/bytes/-/bytes-2.2.0.tgz";
        sha1 = "fd35464a403f6f9117c2de3609ecff9cae000588";
      };
    }

    {
      name = "bytes___bytes_2.4.0.tgz";
      path = fetchurl {
        name = "bytes___bytes_2.4.0.tgz";
        url  = "https://registry.yarnpkg.com/bytes/-/bytes-2.4.0.tgz";
        sha1 = "7d97196f9d5baf7f6935e25985549edd2a6c2339";
      };
    }

    {
      name = "bytes___bytes_3.1.0.tgz";
      path = fetchurl {
        name = "bytes___bytes_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/bytes/-/bytes-3.1.0.tgz";
        sha1 = "f6cf7933a360e0588fa9fde85651cdc7f805d1f6";
      };
    }

    {
      name = "cache_base___cache_base_1.0.1.tgz";
      path = fetchurl {
        name = "cache_base___cache_base_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/cache-base/-/cache-base-1.0.1.tgz";
        sha1 = "0a7f46416831c8b662ee36fe4e7c59d76f666ab2";
      };
    }

    {
      name = "callsite___callsite_1.0.0.tgz";
      path = fetchurl {
        name = "callsite___callsite_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/callsite/-/callsite-1.0.0.tgz";
        sha1 = "280398e5d664bd74038b6f0905153e6e8af1bc20";
      };
    }

    {
      name = "camelcase_keys___camelcase_keys_2.1.0.tgz";
      path = fetchurl {
        name = "camelcase_keys___camelcase_keys_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/camelcase-keys/-/camelcase-keys-2.1.0.tgz";
        sha1 = "308beeaffdf28119051efa1d932213c91b8f92e7";
      };
    }

    {
      name = "camelcase___camelcase_1.2.1.tgz";
      path = fetchurl {
        name = "camelcase___camelcase_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/camelcase/-/camelcase-1.2.1.tgz";
        sha1 = "9bb5304d2e0b56698b2c758b08a3eaa9daa58a39";
      };
    }

    {
      name = "camelcase___camelcase_2.1.1.tgz";
      path = fetchurl {
        name = "camelcase___camelcase_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/camelcase/-/camelcase-2.1.1.tgz";
        sha1 = "7c1d16d679a1bbe59ca02cacecfb011e201f5a1f";
      };
    }

    {
      name = "camelcase___camelcase_3.0.0.tgz";
      path = fetchurl {
        name = "camelcase___camelcase_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/camelcase/-/camelcase-3.0.0.tgz";
        sha1 = "32fc4b9fcdaf845fcdf7e73bb97cac2261f0ab0a";
      };
    }

    {
      name = "cardinal___cardinal_0.4.4.tgz";
      path = fetchurl {
        name = "cardinal___cardinal_0.4.4.tgz";
        url  = "https://registry.yarnpkg.com/cardinal/-/cardinal-0.4.4.tgz";
        sha1 = "ca5bb68a5b511b90fe93b9acea49bdee5c32bfe2";
      };
    }

    {
      name = "caseless___caseless_0.12.0.tgz";
      path = fetchurl {
        name = "caseless___caseless_0.12.0.tgz";
        url  = "https://registry.yarnpkg.com/caseless/-/caseless-0.12.0.tgz";
        sha1 = "1b681c21ff84033c826543090689420d187151dc";
      };
    }

    {
      name = "caseless___caseless_0.8.0.tgz";
      path = fetchurl {
        name = "caseless___caseless_0.8.0.tgz";
        url  = "https://registry.yarnpkg.com/caseless/-/caseless-0.8.0.tgz";
        sha1 = "5bca2881d41437f54b2407ebe34888c7b9ad4f7d";
      };
    }

    {
      name = "center_align___center_align_0.1.3.tgz";
      path = fetchurl {
        name = "center_align___center_align_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/center-align/-/center-align-0.1.3.tgz";
        sha1 = "aa0d32629b6ee972200411cbd4461c907bc2b7ad";
      };
    }

    {
      name = "chainsaw___chainsaw_0.1.0.tgz";
      path = fetchurl {
        name = "chainsaw___chainsaw_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/chainsaw/-/chainsaw-0.1.0.tgz";
        sha1 = "5eab50b28afe58074d0d58291388828b5e5fbc98";
      };
    }

    {
      name = "chalk___chalk_3.0.0.tgz";
      path = fetchurl {
        name = "chalk___chalk_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-3.0.0.tgz";
        sha1 = "3f73c2bf526591f574cc492c51e2456349f844e4";
      };
    }

    {
      name = "chalk___chalk_0.5.1.tgz";
      path = fetchurl {
        name = "chalk___chalk_0.5.1.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-0.5.1.tgz";
        sha1 = "663b3a648b68b55d04690d49167aa837858f2174";
      };
    }

    {
      name = "chalk___chalk_1.1.3.tgz";
      path = fetchurl {
        name = "chalk___chalk_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-1.1.3.tgz";
        sha1 = "a8115c55e4a702fe4d150abd3872822a7e09fc98";
      };
    }

    {
      name = "chalk___chalk_0.4.0.tgz";
      path = fetchurl {
        name = "chalk___chalk_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-0.4.0.tgz";
        sha1 = "5199a3ddcd0c1efe23bc08c1b027b06176e0c64f";
      };
    }

    {
      name = "character_parser___character_parser_2.2.0.tgz";
      path = fetchurl {
        name = "character_parser___character_parser_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/character-parser/-/character-parser-2.2.0.tgz";
        sha1 = "c7ce28f36d4bcd9744e5ffc2c5fcde1c73261fc0";
      };
    }

    {
      name = "chmodr___chmodr_0.1.2.tgz";
      path = fetchurl {
        name = "chmodr___chmodr_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/chmodr/-/chmodr-0.1.2.tgz";
        sha1 = "0dd8041c915087575bec383b47827bb7576a4fd6";
      };
    }

    {
      name = "chokidar___chokidar_1.7.0.tgz";
      path = fetchurl {
        name = "chokidar___chokidar_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/chokidar/-/chokidar-1.7.0.tgz";
        sha1 = "798e689778151c8076b4b360e5edd28cda2bb468";
      };
    }

    {
      name = "chownr___chownr_1.1.4.tgz";
      path = fetchurl {
        name = "chownr___chownr_1.1.4.tgz";
        url  = "https://registry.yarnpkg.com/chownr/-/chownr-1.1.4.tgz";
        sha1 = "6fc9d7b42d32a583596337666e7d08084da2cc6b";
      };
    }

    {
      name = "class_utils___class_utils_0.3.6.tgz";
      path = fetchurl {
        name = "class_utils___class_utils_0.3.6.tgz";
        url  = "https://registry.yarnpkg.com/class-utils/-/class-utils-0.3.6.tgz";
        sha1 = "f93369ae8b9a7ce02fd41faad0ca83033190c463";
      };
    }

    {
      name = "clean_css___clean_css_2.2.23.tgz";
      path = fetchurl {
        name = "clean_css___clean_css_2.2.23.tgz";
        url  = "https://registry.yarnpkg.com/clean-css/-/clean-css-2.2.23.tgz";
        sha1 = "0590b5478b516c4903edc2d89bd3fdbdd286328c";
      };
    }

    {
      name = "clean_css___clean_css_4.2.3.tgz";
      path = fetchurl {
        name = "clean_css___clean_css_4.2.3.tgz";
        url  = "https://registry.yarnpkg.com/clean-css/-/clean-css-4.2.3.tgz";
        sha1 = "507b5de7d97b48ee53d84adb0160ff6216380f78";
      };
    }

    {
      name = "cli_color___cli_color_0.2.3.tgz";
      path = fetchurl {
        name = "cli_color___cli_color_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/cli-color/-/cli-color-0.2.3.tgz";
        sha1 = "0a25ceae5a6a1602be7f77d28563c36700274e88";
      };
    }

    {
      name = "cli_color___cli_color_0.3.3.tgz";
      path = fetchurl {
        name = "cli_color___cli_color_0.3.3.tgz";
        url  = "https://registry.yarnpkg.com/cli-color/-/cli-color-0.3.3.tgz";
        sha1 = "12d5bdd158ff8a0b0db401198913c03df069f6f5";
      };
    }

    {
      name = "cliui___cliui_2.1.0.tgz";
      path = fetchurl {
        name = "cliui___cliui_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/cliui/-/cliui-2.1.0.tgz";
        sha1 = "4b475760ff80264c762c3a1719032e91c7fea0d1";
      };
    }

    {
      name = "cliui___cliui_3.2.0.tgz";
      path = fetchurl {
        name = "cliui___cliui_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/cliui/-/cliui-3.2.0.tgz";
        sha1 = "120601537a916d29940f934da3b48d585a39213d";
      };
    }

    {
      name = "clone_buffer___clone_buffer_1.0.0.tgz";
      path = fetchurl {
        name = "clone_buffer___clone_buffer_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/clone-buffer/-/clone-buffer-1.0.0.tgz";
        sha1 = "e3e25b207ac4e701af721e2cb5a16792cac3dc58";
      };
    }

    {
      name = "clone_stats___clone_stats_0.0.1.tgz";
      path = fetchurl {
        name = "clone_stats___clone_stats_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/clone-stats/-/clone-stats-0.0.1.tgz";
        sha1 = "b88f94a82cf38b8791d58046ea4029ad88ca99d1";
      };
    }

    {
      name = "clone_stats___clone_stats_1.0.0.tgz";
      path = fetchurl {
        name = "clone_stats___clone_stats_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/clone-stats/-/clone-stats-1.0.0.tgz";
        sha1 = "b3782dff8bb5474e18b9b6bf0fdfe782f8777680";
      };
    }

    {
      name = "clone___clone_0.2.0.tgz";
      path = fetchurl {
        name = "clone___clone_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/clone/-/clone-0.2.0.tgz";
        sha1 = "c6126a90ad4f72dbf5acdb243cc37724fe93fc1f";
      };
    }

    {
      name = "clone___clone_1.0.4.tgz";
      path = fetchurl {
        name = "clone___clone_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/clone/-/clone-1.0.4.tgz";
        sha1 = "da309cc263df15994c688ca902179ca3c7cd7c7e";
      };
    }

    {
      name = "clone___clone_2.1.2.tgz";
      path = fetchurl {
        name = "clone___clone_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/clone/-/clone-2.1.2.tgz";
        sha1 = "1b7f4b9f591f1e8f83670401600345a02887435f";
      };
    }

    {
      name = "cloneable_readable___cloneable_readable_1.1.3.tgz";
      path = fetchurl {
        name = "cloneable_readable___cloneable_readable_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/cloneable-readable/-/cloneable-readable-1.1.3.tgz";
        sha1 = "120a00cb053bfb63a222e709f9683ea2e11d8cec";
      };
    }

    {
      name = "code_point_at___code_point_at_1.1.0.tgz";
      path = fetchurl {
        name = "code_point_at___code_point_at_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/code-point-at/-/code-point-at-1.1.0.tgz";
        sha1 = "0d070b4d043a5bea33a2f1a40e2edb3d9a4ccf77";
      };
    }

    {
      name = "coffee_script___coffee_script_1.12.7.tgz";
      path = fetchurl {
        name = "coffee_script___coffee_script_1.12.7.tgz";
        url  = "https://registry.yarnpkg.com/coffee-script/-/coffee-script-1.12.7.tgz";
        sha1 = "c05dae0cb79591d05b3070a8433a98c9a89ccc53";
      };
    }

    {
      name = "coffee_script___coffee_script_1.10.0.tgz";
      path = fetchurl {
        name = "coffee_script___coffee_script_1.10.0.tgz";
        url  = "https://registry.yarnpkg.com/coffee-script/-/coffee-script-1.10.0.tgz";
        sha1 = "12938bcf9be1948fa006f92e0c4c9e81705108c0";
      };
    }

    {
      name = "coffeescript___coffeescript_1.12.7.tgz";
      path = fetchurl {
        name = "coffeescript___coffeescript_1.12.7.tgz";
        url  = "https://registry.yarnpkg.com/coffeescript/-/coffeescript-1.12.7.tgz";
        sha1 = "e57ee4c4867cf7f606bfc4a0f2d550c0981ddd27";
      };
    }

    {
      name = "collection_visit___collection_visit_1.0.0.tgz";
      path = fetchurl {
        name = "collection_visit___collection_visit_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/collection-visit/-/collection-visit-1.0.0.tgz";
        sha1 = "4bc0373c164bc3291b4d368c829cf1a80a59dca0";
      };
    }

    {
      name = "color_convert___color_convert_2.0.1.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-2.0.1.tgz";
        sha1 = "72d3a68d598c9bdb3af2ad1e84f21d896abd4de3";
      };
    }

    {
      name = "color_name___color_name_1.1.4.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.4.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.4.tgz";
        sha1 = "c2a09a87acbde69543de6f63fa3995c826c536a2";
      };
    }

    {
      name = "color_support___color_support_1.1.3.tgz";
      path = fetchurl {
        name = "color_support___color_support_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/color-support/-/color-support-1.1.3.tgz";
        sha1 = "93834379a1cc9a0c61f82f52f0d04322251bd5a2";
      };
    }

    {
      name = "colors___colors_1.4.0.tgz";
      path = fetchurl {
        name = "colors___colors_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/colors/-/colors-1.4.0.tgz";
        sha1 = "c50491479d4c1bdaed2c9ced32cf7c7dc2360f78";
      };
    }

    {
      name = "combine_source_map___combine_source_map_0.3.0.tgz";
      path = fetchurl {
        name = "combine_source_map___combine_source_map_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/combine-source-map/-/combine-source-map-0.3.0.tgz";
        sha1 = "d9e74f593d9cd43807312cb5d846d451efaa9eb7";
      };
    }

    {
      name = "combined_stream___combined_stream_1.0.8.tgz";
      path = fetchurl {
        name = "combined_stream___combined_stream_1.0.8.tgz";
        url  = "https://registry.yarnpkg.com/combined-stream/-/combined-stream-1.0.8.tgz";
        sha1 = "c3d45a8b34fd730631a110a8a2520682b31d5a7f";
      };
    }

    {
      name = "combined_stream___combined_stream_0.0.7.tgz";
      path = fetchurl {
        name = "combined_stream___combined_stream_0.0.7.tgz";
        url  = "https://registry.yarnpkg.com/combined-stream/-/combined-stream-0.0.7.tgz";
        sha1 = "0137e657baa5a7541c57ac37ac5fc07d73b4dc1f";
      };
    }

    {
      name = "commander___commander_2.2.0.tgz";
      path = fetchurl {
        name = "commander___commander_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/commander/-/commander-2.2.0.tgz";
        sha1 = "175ad4b9317f3ff615f201c1e57224f55a3e91df";
      };
    }

    {
      name = "commander___commander_2.20.3.tgz";
      path = fetchurl {
        name = "commander___commander_2.20.3.tgz";
        url  = "https://registry.yarnpkg.com/commander/-/commander-2.20.3.tgz";
        sha1 = "fd485e84c03eb4881c20722ba48035e8531aeb33";
      };
    }

    {
      name = "commondir___commondir_0.0.1.tgz";
      path = fetchurl {
        name = "commondir___commondir_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/commondir/-/commondir-0.0.1.tgz";
        sha1 = "89f00fdcd51b519c578733fec563e6a6da7f5be2";
      };
    }

    {
      name = "component_bind___component_bind_1.0.0.tgz";
      path = fetchurl {
        name = "component_bind___component_bind_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/component-bind/-/component-bind-1.0.0.tgz";
        sha1 = "00c608ab7dcd93897c0009651b1d3a8e1e73bbd1";
      };
    }

    {
      name = "component_emitter___component_emitter_1.1.2.tgz";
      path = fetchurl {
        name = "component_emitter___component_emitter_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/component-emitter/-/component-emitter-1.1.2.tgz";
        sha1 = "296594f2753daa63996d2af08d15a95116c9aec3";
      };
    }

    {
      name = "component_emitter___component_emitter_1.2.1.tgz";
      path = fetchurl {
        name = "component_emitter___component_emitter_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/component-emitter/-/component-emitter-1.2.1.tgz";
        sha1 = "137918d6d78283f7df7a6b7c5a63e140e69425e6";
      };
    }

    {
      name = "component_emitter___component_emitter_1.3.0.tgz";
      path = fetchurl {
        name = "component_emitter___component_emitter_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/component-emitter/-/component-emitter-1.3.0.tgz";
        sha1 = "16e4070fba8ae29b679f2215853ee181ab2eabc0";
      };
    }

    {
      name = "component_inherit___component_inherit_0.0.3.tgz";
      path = fetchurl {
        name = "component_inherit___component_inherit_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/component-inherit/-/component-inherit-0.0.3.tgz";
        sha1 = "645fc4adf58b72b649d5cae65135619db26ff143";
      };
    }

    {
      name = "concat_map___concat_map_0.0.1.tgz";
      path = fetchurl {
        name = "concat_map___concat_map_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/concat-map/-/concat-map-0.0.1.tgz";
        sha1 = "d8a96bd77fd68df7793a73036a3ba0d5405d477b";
      };
    }

    {
      name = "concat_stream___concat_stream_1.4.11.tgz";
      path = fetchurl {
        name = "concat_stream___concat_stream_1.4.11.tgz";
        url  = "https://registry.yarnpkg.com/concat-stream/-/concat-stream-1.4.11.tgz";
        sha1 = "1dc9f666f2621da9c618b1e7f8f3b2ff70b5f76f";
      };
    }

    {
      name = "concat_with_sourcemaps___concat_with_sourcemaps_1.1.0.tgz";
      path = fetchurl {
        name = "concat_with_sourcemaps___concat_with_sourcemaps_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/concat-with-sourcemaps/-/concat-with-sourcemaps-1.1.0.tgz";
        sha1 = "d4ea93f05ae25790951b99e7b3b09e3908a4082e";
      };
    }

    {
      name = "configstore___configstore_0.3.2.tgz";
      path = fetchurl {
        name = "configstore___configstore_0.3.2.tgz";
        url  = "https://registry.yarnpkg.com/configstore/-/configstore-0.3.2.tgz";
        sha1 = "25e4c16c3768abf75c5a65bc61761f495055b459";
      };
    }

    {
      name = "configstore___configstore_0.2.3.tgz";
      path = fetchurl {
        name = "configstore___configstore_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/configstore/-/configstore-0.2.3.tgz";
        sha1 = "b1bdc4ad823a25423dc15d220fcc1ae1d7efab02";
      };
    }

    {
      name = "connect___connect_3.7.0.tgz";
      path = fetchurl {
        name = "connect___connect_3.7.0.tgz";
        url  = "https://registry.yarnpkg.com/connect/-/connect-3.7.0.tgz";
        sha1 = "5d49348910caa5e07a01800b030d0c35f20484f8";
      };
    }

    {
      name = "console_browserify___console_browserify_1.0.3.tgz";
      path = fetchurl {
        name = "console_browserify___console_browserify_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/console-browserify/-/console-browserify-1.0.3.tgz";
        sha1 = "d3898d2c3a93102f364197f8874b4f92b5286a8e";
      };
    }

    {
      name = "console_control_strings___console_control_strings_1.1.0.tgz";
      path = fetchurl {
        name = "console_control_strings___console_control_strings_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/console-control-strings/-/console-control-strings-1.1.0.tgz";
        sha1 = "3d7cf4464db6446ea644bf4b39507f9851008e8e";
      };
    }

    {
      name = "constantinople___constantinople_3.1.2.tgz";
      path = fetchurl {
        name = "constantinople___constantinople_3.1.2.tgz";
        url  = "https://registry.yarnpkg.com/constantinople/-/constantinople-3.1.2.tgz";
        sha1 = "d45ed724f57d3d10500017a7d3a889c1381ae647";
      };
    }

    {
      name = "constants_browserify___constants_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "constants_browserify___constants_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/constants-browserify/-/constants-browserify-0.0.1.tgz";
        sha1 = "92577db527ba6c4cf0a4568d84bc031f441e21f2";
      };
    }

    {
      name = "content_type___content_type_1.0.4.tgz";
      path = fetchurl {
        name = "content_type___content_type_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/content-type/-/content-type-1.0.4.tgz";
        sha1 = "e138cc75e040c727b1966fe5e5f8c9aee256fe3b";
      };
    }

    {
      name = "convert_source_map___convert_source_map_0.4.1.tgz";
      path = fetchurl {
        name = "convert_source_map___convert_source_map_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/convert-source-map/-/convert-source-map-0.4.1.tgz";
        sha1 = "f919a0099fe31f80fc5a1d0eb303161b394070c7";
      };
    }

    {
      name = "convert_source_map___convert_source_map_1.7.0.tgz";
      path = fetchurl {
        name = "convert_source_map___convert_source_map_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/convert-source-map/-/convert-source-map-1.7.0.tgz";
        sha1 = "17a2cb882d7f77d3490585e2ce6c524424a3a442";
      };
    }

    {
      name = "convert_source_map___convert_source_map_0.3.5.tgz";
      path = fetchurl {
        name = "convert_source_map___convert_source_map_0.3.5.tgz";
        url  = "https://registry.yarnpkg.com/convert-source-map/-/convert-source-map-0.3.5.tgz";
        sha1 = "f1d802950af7dd2631a1febe0596550c86ab3190";
      };
    }

    {
      name = "convert_source_map___convert_source_map_1.1.3.tgz";
      path = fetchurl {
        name = "convert_source_map___convert_source_map_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/convert-source-map/-/convert-source-map-1.1.3.tgz";
        sha1 = "4829c877e9fe49b3161f3bf3673888e204699860";
      };
    }

    {
      name = "cookie_jar___cookie_jar_0.3.0.tgz";
      path = fetchurl {
        name = "cookie_jar___cookie_jar_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/cookie-jar/-/cookie-jar-0.3.0.tgz";
        sha1 = "bc9a27d4e2b97e186cd57c9e2063cb99fa68cccc";
      };
    }

    {
      name = "cookie___cookie_0.3.1.tgz";
      path = fetchurl {
        name = "cookie___cookie_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/cookie/-/cookie-0.3.1.tgz";
        sha1 = "e7e0a1f9ef43b4c8ba925c5c5a96e806d16873bb";
      };
    }

    {
      name = "copy_descriptor___copy_descriptor_0.1.1.tgz";
      path = fetchurl {
        name = "copy_descriptor___copy_descriptor_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/copy-descriptor/-/copy-descriptor-0.1.1.tgz";
        sha1 = "676f6eb3c39997c2ee1ac3a924fd6124748f578d";
      };
    }

    {
      name = "core_js___core_js_2.6.11.tgz";
      path = fetchurl {
        name = "core_js___core_js_2.6.11.tgz";
        url  = "https://registry.yarnpkg.com/core-js/-/core-js-2.6.11.tgz";
        sha1 = "38831469f9922bded8ee21c9dc46985e0399308c";
      };
    }

    {
      name = "core_util_is___core_util_is_1.0.2.tgz";
      path = fetchurl {
        name = "core_util_is___core_util_is_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/core-util-is/-/core-util-is-1.0.2.tgz";
        sha1 = "b5fd54220aa2bc5ab57aab7140c940754503c1a7";
      };
    }

    {
      name = "cross_spawn___cross_spawn_3.0.1.tgz";
      path = fetchurl {
        name = "cross_spawn___cross_spawn_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/cross-spawn/-/cross-spawn-3.0.1.tgz";
        sha1 = "1256037ecb9f0c5f79e3d6ef135e30770184b982";
      };
    }

    {
      name = "cryptiles___cryptiles_0.2.2.tgz";
      path = fetchurl {
        name = "cryptiles___cryptiles_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/cryptiles/-/cryptiles-0.2.2.tgz";
        sha1 = "ed91ff1f17ad13d3748288594f8a48a0d26f325c";
      };
    }

    {
      name = "crypto_browserify___crypto_browserify_1.0.9.tgz";
      path = fetchurl {
        name = "crypto_browserify___crypto_browserify_1.0.9.tgz";
        url  = "https://registry.yarnpkg.com/crypto-browserify/-/crypto-browserify-1.0.9.tgz";
        sha1 = "cc5449685dfb85eb11c9828acc7cb87ab5bbfcc0";
      };
    }

    {
      name = "ctype___ctype_0.5.3.tgz";
      path = fetchurl {
        name = "ctype___ctype_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/ctype/-/ctype-0.5.3.tgz";
        sha1 = "82c18c2461f74114ef16c135224ad0b9144ca12f";
      };
    }

    {
      name = "currently_unhandled___currently_unhandled_0.4.1.tgz";
      path = fetchurl {
        name = "currently_unhandled___currently_unhandled_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/currently-unhandled/-/currently-unhandled-0.4.1.tgz";
        sha1 = "988df33feab191ef799a61369dd76c17adf957ea";
      };
    }

    {
      name = "custom_event___custom_event_1.0.1.tgz";
      path = fetchurl {
        name = "custom_event___custom_event_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/custom-event/-/custom-event-1.0.1.tgz";
        sha1 = "5d02a46850adf1b4a317946a3928fccb5bfd0425";
      };
    }

    {
      name = "d___d_1.0.1.tgz";
      path = fetchurl {
        name = "d___d_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/d/-/d-1.0.1.tgz";
        sha1 = "8698095372d58dbee346ffd0c7093f99f8f9eb5a";
      };
    }

    {
      name = "d___d_0.1.1.tgz";
      path = fetchurl {
        name = "d___d_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/d/-/d-0.1.1.tgz";
        sha1 = "da184c535d18d8ee7ba2aa229b914009fae11309";
      };
    }

    {
      name = "dashdash___dashdash_1.14.1.tgz";
      path = fetchurl {
        name = "dashdash___dashdash_1.14.1.tgz";
        url  = "https://registry.yarnpkg.com/dashdash/-/dashdash-1.14.1.tgz";
        sha1 = "853cfa0f7cbe2fed5de20326b8dd581035f6e2f0";
      };
    }

    {
      name = "dateformat___dateformat_1.0.12.tgz";
      path = fetchurl {
        name = "dateformat___dateformat_1.0.12.tgz";
        url  = "https://registry.yarnpkg.com/dateformat/-/dateformat-1.0.12.tgz";
        sha1 = "9f124b67594c937ff706932e4a642cca8dbbfee9";
      };
    }

    {
      name = "dateformat___dateformat_2.2.0.tgz";
      path = fetchurl {
        name = "dateformat___dateformat_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/dateformat/-/dateformat-2.2.0.tgz";
        sha1 = "4065e2013cf9fb916ddfd82efb506ad4c6769062";
      };
    }

    {
      name = "deap___deap_1.0.1.tgz";
      path = fetchurl {
        name = "deap___deap_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/deap/-/deap-1.0.1.tgz";
        sha1 = "0646e9e1a095ffe8a9e404d68d1f76dcf57e66fb";
      };
    }

    {
      name = "debug___debug_2.2.0.tgz";
      path = fetchurl {
        name = "debug___debug_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-2.2.0.tgz";
        sha1 = "f87057e995b1a1f6ae6a4960664137bc56f039da";
      };
    }

    {
      name = "debug___debug_2.3.3.tgz";
      path = fetchurl {
        name = "debug___debug_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-2.3.3.tgz";
        sha1 = "40c453e67e6e13c901ddec317af8986cda9eff8c";
      };
    }

    {
      name = "debug___debug_2.6.9.tgz";
      path = fetchurl {
        name = "debug___debug_2.6.9.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-2.6.9.tgz";
        sha1 = "5d128515df134ff327e90a4c93f4e077a536341f";
      };
    }

    {
      name = "debug___debug_3.2.6.tgz";
      path = fetchurl {
        name = "debug___debug_3.2.6.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-3.2.6.tgz";
        sha1 = "e83d17de16d8a7efb7717edbe5fb10135eee629b";
      };
    }

    {
      name = "decamelize___decamelize_1.2.0.tgz";
      path = fetchurl {
        name = "decamelize___decamelize_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/decamelize/-/decamelize-1.2.0.tgz";
        sha1 = "f6534d15148269b20352e7bee26f501f9a191290";
      };
    }

    {
      name = "decode_uri_component___decode_uri_component_0.2.0.tgz";
      path = fetchurl {
        name = "decode_uri_component___decode_uri_component_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/decode-uri-component/-/decode-uri-component-0.2.0.tgz";
        sha1 = "eb3913333458775cb84cd1a1fae062106bb87545";
      };
    }

    {
      name = "decompress_zip___decompress_zip_0.0.8.tgz";
      path = fetchurl {
        name = "decompress_zip___decompress_zip_0.0.8.tgz";
        url  = "https://registry.yarnpkg.com/decompress-zip/-/decompress-zip-0.0.8.tgz";
        sha1 = "4a265b22c7b209d7b24fa66f2b2dfbced59044f3";
      };
    }

    {
      name = "deep_equal___deep_equal_0.1.2.tgz";
      path = fetchurl {
        name = "deep_equal___deep_equal_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/deep-equal/-/deep-equal-0.1.2.tgz";
        sha1 = "b246c2b80a570a47c11be1d9bd1070ec878b87ce";
      };
    }

    {
      name = "deep_extend___deep_extend_0.6.0.tgz";
      path = fetchurl {
        name = "deep_extend___deep_extend_0.6.0.tgz";
        url  = "https://registry.yarnpkg.com/deep-extend/-/deep-extend-0.6.0.tgz";
        sha1 = "c4fa7c95404a17a9c3e8ca7e1537312b736330ac";
      };
    }

    {
      name = "deep_extend___deep_extend_0.2.11.tgz";
      path = fetchurl {
        name = "deep_extend___deep_extend_0.2.11.tgz";
        url  = "https://registry.yarnpkg.com/deep-extend/-/deep-extend-0.2.11.tgz";
        sha1 = "7a16ba69729132340506170494bc83f7076fe08f";
      };
    }

    {
      name = "deep_is___deep_is_0.1.3.tgz";
      path = fetchurl {
        name = "deep_is___deep_is_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/deep-is/-/deep-is-0.1.3.tgz";
        sha1 = "b369d6fb5dbc13eecf524f91b070feedc357cf34";
      };
    }

    {
      name = "defaults___defaults_1.0.3.tgz";
      path = fetchurl {
        name = "defaults___defaults_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/defaults/-/defaults-1.0.3.tgz";
        sha1 = "c656051e9817d9ff08ed881477f3fe4019f3ef7d";
      };
    }

    {
      name = "define_property___define_property_0.2.5.tgz";
      path = fetchurl {
        name = "define_property___define_property_0.2.5.tgz";
        url  = "https://registry.yarnpkg.com/define-property/-/define-property-0.2.5.tgz";
        sha1 = "c35b1ef918ec3c990f9a5bc57be04aacec5c8116";
      };
    }

    {
      name = "define_property___define_property_1.0.0.tgz";
      path = fetchurl {
        name = "define_property___define_property_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/define-property/-/define-property-1.0.0.tgz";
        sha1 = "769ebaaf3f4a63aad3af9e8d304c9bbe79bfb0e6";
      };
    }

    {
      name = "define_property___define_property_2.0.2.tgz";
      path = fetchurl {
        name = "define_property___define_property_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/define-property/-/define-property-2.0.2.tgz";
        sha1 = "d459689e8d654ba77e02a817f8710d702cb16e9d";
      };
    }

    {
      name = "defined___defined_0.0.0.tgz";
      path = fetchurl {
        name = "defined___defined_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/defined/-/defined-0.0.0.tgz";
        sha1 = "f35eea7d705e933baf13b2f03b3f83d921403b3e";
      };
    }

    {
      name = "delayed_stream___delayed_stream_0.0.5.tgz";
      path = fetchurl {
        name = "delayed_stream___delayed_stream_0.0.5.tgz";
        url  = "https://registry.yarnpkg.com/delayed-stream/-/delayed-stream-0.0.5.tgz";
        sha1 = "d4b1f43a93e8296dfe02694f4680bc37a313c73f";
      };
    }

    {
      name = "delayed_stream___delayed_stream_1.0.0.tgz";
      path = fetchurl {
        name = "delayed_stream___delayed_stream_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/delayed-stream/-/delayed-stream-1.0.0.tgz";
        sha1 = "df3ae199acadfb7d440aaae0b29e2272b24ec619";
      };
    }

    {
      name = "delegates___delegates_1.0.0.tgz";
      path = fetchurl {
        name = "delegates___delegates_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/delegates/-/delegates-1.0.0.tgz";
        sha1 = "84c6e159b81904fdca59a0ef44cd870d31250f9a";
      };
    }

    {
      name = "depd___depd_1.1.2.tgz";
      path = fetchurl {
        name = "depd___depd_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/depd/-/depd-1.1.2.tgz";
        sha1 = "9bcd52e14c097763e749b274c4346ed2e560b5a9";
      };
    }

    {
      name = "deprecated___deprecated_0.0.1.tgz";
      path = fetchurl {
        name = "deprecated___deprecated_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/deprecated/-/deprecated-0.0.1.tgz";
        sha1 = "f9c9af5464afa1e7a971458a8bdef2aa94d5bb19";
      };
    }

    {
      name = "deps_sort___deps_sort_0.1.2.tgz";
      path = fetchurl {
        name = "deps_sort___deps_sort_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/deps-sort/-/deps-sort-0.1.2.tgz";
        sha1 = "daa2fb614a17c9637d801e2f55339ae370f3611a";
      };
    }

    {
      name = "derequire___derequire_0.8.0.tgz";
      path = fetchurl {
        name = "derequire___derequire_0.8.0.tgz";
        url  = "https://registry.yarnpkg.com/derequire/-/derequire-0.8.0.tgz";
        sha1 = "c1f7f1da2cede44adede047378f03f444e9c4c0d";
      };
    }

    {
      name = "destroy___destroy_1.0.4.tgz";
      path = fetchurl {
        name = "destroy___destroy_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/destroy/-/destroy-1.0.4.tgz";
        sha1 = "978857442c44749e4206613e37946205826abd80";
      };
    }

    {
      name = "detect_file___detect_file_1.0.0.tgz";
      path = fetchurl {
        name = "detect_file___detect_file_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/detect-file/-/detect-file-1.0.0.tgz";
        sha1 = "f0d66d03672a825cb1b73bdb3fe62310c8e552b7";
      };
    }

    {
      name = "detect_libc___detect_libc_1.0.3.tgz";
      path = fetchurl {
        name = "detect_libc___detect_libc_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/detect-libc/-/detect-libc-1.0.3.tgz";
        sha1 = "fa137c4bd698edf55cd5cd02ac559f91a4c4ba9b";
      };
    }

    {
      name = "detective___detective_3.1.0.tgz";
      path = fetchurl {
        name = "detective___detective_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/detective/-/detective-3.1.0.tgz";
        sha1 = "77782444ab752b88ca1be2e9d0a0395f1da25eed";
      };
    }

    {
      name = "di___di_0.0.1.tgz";
      path = fetchurl {
        name = "di___di_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/di/-/di-0.0.1.tgz";
        sha1 = "806649326ceaa7caa3306d75d985ea2748ba913c";
      };
    }

    {
      name = "doctypes___doctypes_1.1.0.tgz";
      path = fetchurl {
        name = "doctypes___doctypes_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/doctypes/-/doctypes-1.1.0.tgz";
        sha1 = "ea80b106a87538774e8a3a4a5afe293de489e0a9";
      };
    }

    {
      name = "dom_serialize___dom_serialize_2.2.1.tgz";
      path = fetchurl {
        name = "dom_serialize___dom_serialize_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/dom-serialize/-/dom-serialize-2.2.1.tgz";
        sha1 = "562ae8999f44be5ea3076f5419dcd59eb43ac95b";
      };
    }

    {
      name = "domain_browser___domain_browser_1.1.7.tgz";
      path = fetchurl {
        name = "domain_browser___domain_browser_1.1.7.tgz";
        url  = "https://registry.yarnpkg.com/domain-browser/-/domain-browser-1.1.7.tgz";
        sha1 = "867aa4b093faa05f1de08c06f4d7b21fdf8698bc";
      };
    }

    {
      name = "duplexer2___duplexer2_0.0.2.tgz";
      path = fetchurl {
        name = "duplexer2___duplexer2_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/duplexer2/-/duplexer2-0.0.2.tgz";
        sha1 = "c614dcf67e2fb14995a91711e5a617e8a60a31db";
      };
    }

    {
      name = "duplexer___duplexer_0.1.1.tgz";
      path = fetchurl {
        name = "duplexer___duplexer_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/duplexer/-/duplexer-0.1.1.tgz";
        sha1 = "ace6ff808c1ce66b57d1ebf97977acb02334cfc1";
      };
    }

    {
      name = "duplexify___duplexify_3.7.1.tgz";
      path = fetchurl {
        name = "duplexify___duplexify_3.7.1.tgz";
        url  = "https://registry.yarnpkg.com/duplexify/-/duplexify-3.7.1.tgz";
        sha1 = "2a4df5317f6ccfd91f86d6fd25d8d8a103b88309";
      };
    }

    {
      name = "ecc_jsbn___ecc_jsbn_0.1.2.tgz";
      path = fetchurl {
        name = "ecc_jsbn___ecc_jsbn_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/ecc-jsbn/-/ecc-jsbn-0.1.2.tgz";
        sha1 = "3a83a904e54353287874c564b7549386849a98c9";
      };
    }

    {
      name = "ee_first___ee_first_1.1.1.tgz";
      path = fetchurl {
        name = "ee_first___ee_first_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ee-first/-/ee-first-1.1.1.tgz";
        sha1 = "590c61156b0ae2f4f0255732a158b266bc56b21d";
      };
    }

    {
      name = "encodeurl___encodeurl_1.0.2.tgz";
      path = fetchurl {
        name = "encodeurl___encodeurl_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/encodeurl/-/encodeurl-1.0.2.tgz";
        sha1 = "ad3ff4c86ec2d029322f5a02c3a9a606c95b3f59";
      };
    }

    {
      name = "end_of_stream___end_of_stream_1.4.4.tgz";
      path = fetchurl {
        name = "end_of_stream___end_of_stream_1.4.4.tgz";
        url  = "https://registry.yarnpkg.com/end-of-stream/-/end-of-stream-1.4.4.tgz";
        sha1 = "5ae64a5f45057baf3626ec14da0ca5e4b2431eb0";
      };
    }

    {
      name = "end_of_stream___end_of_stream_0.1.5.tgz";
      path = fetchurl {
        name = "end_of_stream___end_of_stream_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/end-of-stream/-/end-of-stream-0.1.5.tgz";
        sha1 = "8e177206c3c80837d85632e8b9359dfe8b2f6eaf";
      };
    }

    {
      name = "engine.io_client___engine.io_client_1.8.5.tgz";
      path = fetchurl {
        name = "engine.io_client___engine.io_client_1.8.5.tgz";
        url  = "https://registry.yarnpkg.com/engine.io-client/-/engine.io-client-1.8.5.tgz";
        sha1 = "fe7fb60cb0dcf2fa2859489329cb5968dedeb11f";
      };
    }

    {
      name = "engine.io_parser___engine.io_parser_1.3.2.tgz";
      path = fetchurl {
        name = "engine.io_parser___engine.io_parser_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/engine.io-parser/-/engine.io-parser-1.3.2.tgz";
        sha1 = "937b079f0007d0893ec56d46cb220b8cb435220a";
      };
    }

    {
      name = "engine.io___engine.io_1.8.5.tgz";
      path = fetchurl {
        name = "engine.io___engine.io_1.8.5.tgz";
        url  = "https://registry.yarnpkg.com/engine.io/-/engine.io-1.8.5.tgz";
        sha1 = "4ebe5e75c6dc123dee4afdce6e5fdced21eb93f6";
      };
    }

    {
      name = "ent___ent_2.2.0.tgz";
      path = fetchurl {
        name = "ent___ent_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/ent/-/ent-2.2.0.tgz";
        sha1 = "e964219325a21d05f44466a2f686ed6ce5f5dd1d";
      };
    }

    {
      name = "error_ex___error_ex_1.3.2.tgz";
      path = fetchurl {
        name = "error_ex___error_ex_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/error-ex/-/error-ex-1.3.2.tgz";
        sha1 = "b4ac40648107fdcdcfae242f428bea8a14d4f1bf";
      };
    }

    {
      name = "es5_ext___es5_ext_0.10.53.tgz";
      path = fetchurl {
        name = "es5_ext___es5_ext_0.10.53.tgz";
        url  = "https://registry.yarnpkg.com/es5-ext/-/es5-ext-0.10.53.tgz";
        sha1 = "93c5a3acfdbef275220ad72644ad02ee18368de1";
      };
    }

    {
      name = "es5_ext___es5_ext_0.9.2.tgz";
      path = fetchurl {
        name = "es5_ext___es5_ext_0.9.2.tgz";
        url  = "https://registry.yarnpkg.com/es5-ext/-/es5-ext-0.9.2.tgz";
        sha1 = "d2e309d1f223b0718648835acf5b8823a8061f8a";
      };
    }

    {
      name = "es6_iterator___es6_iterator_0.1.3.tgz";
      path = fetchurl {
        name = "es6_iterator___es6_iterator_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/es6-iterator/-/es6-iterator-0.1.3.tgz";
        sha1 = "d6f58b8c4fc413c249b4baa19768f8e4d7c8944e";
      };
    }

    {
      name = "es6_iterator___es6_iterator_2.0.3.tgz";
      path = fetchurl {
        name = "es6_iterator___es6_iterator_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/es6-iterator/-/es6-iterator-2.0.3.tgz";
        sha1 = "a7de889141a05a94b0854403b2d0a0fbfa98f3b7";
      };
    }

    {
      name = "es6_symbol___es6_symbol_3.1.3.tgz";
      path = fetchurl {
        name = "es6_symbol___es6_symbol_3.1.3.tgz";
        url  = "https://registry.yarnpkg.com/es6-symbol/-/es6-symbol-3.1.3.tgz";
        sha1 = "bad5d3c1bcdac28269f4cb331e431c78ac705d18";
      };
    }

    {
      name = "es6_symbol___es6_symbol_2.0.1.tgz";
      path = fetchurl {
        name = "es6_symbol___es6_symbol_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/es6-symbol/-/es6-symbol-2.0.1.tgz";
        sha1 = "761b5c67cfd4f1d18afb234f691d678682cb3bf3";
      };
    }

    {
      name = "es6_weak_map___es6_weak_map_0.1.4.tgz";
      path = fetchurl {
        name = "es6_weak_map___es6_weak_map_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/es6-weak-map/-/es6-weak-map-0.1.4.tgz";
        sha1 = "706cef9e99aa236ba7766c239c8b9e286ea7d228";
      };
    }

    {
      name = "escape_html___escape_html_1.0.3.tgz";
      path = fetchurl {
        name = "escape_html___escape_html_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/escape-html/-/escape-html-1.0.3.tgz";
        sha1 = "0258eae4d3d0c0974de1c169188ef0051d1d1988";
      };
    }

    {
      name = "escape_string_regexp___escape_string_regexp_1.0.5.tgz";
      path = fetchurl {
        name = "escape_string_regexp___escape_string_regexp_1.0.5.tgz";
        url  = "https://registry.yarnpkg.com/escape-string-regexp/-/escape-string-regexp-1.0.5.tgz";
        sha1 = "1b61c0562190a8dff6ae3bb2cf0200ca130b86d4";
      };
    }

    {
      name = "escodegen___escodegen_1.8.1.tgz";
      path = fetchurl {
        name = "escodegen___escodegen_1.8.1.tgz";
        url  = "https://registry.yarnpkg.com/escodegen/-/escodegen-1.8.1.tgz";
        sha1 = "5a5b53af4693110bebb0867aa3430dd3b70a1018";
      };
    }

    {
      name = "escodegen___escodegen_1.1.0.tgz";
      path = fetchurl {
        name = "escodegen___escodegen_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/escodegen/-/escodegen-1.1.0.tgz";
        sha1 = "c663923f6e20aad48d0c0fa49f31c6d4f49360cf";
      };
    }

    {
      name = "escope___escope_0.0.16.tgz";
      path = fetchurl {
        name = "escope___escope_0.0.16.tgz";
        url  = "https://registry.yarnpkg.com/escope/-/escope-0.0.16.tgz";
        sha1 = "418c7a0afca721dafe659193fd986283e746538f";
      };
    }

    {
      name = "esprima_fb___esprima_fb_3001.0001.0000_dev_harmony_fb.tgz";
      path = fetchurl {
        name = "esprima_fb___esprima_fb_3001.0001.0000_dev_harmony_fb.tgz";
        url  = "https://registry.yarnpkg.com/esprima-fb/-/esprima-fb-3001.0001.0000-dev-harmony-fb.tgz";
        sha1 = "b77d37abcd38ea0b77426bb8bc2922ce6b426411";
      };
    }

    {
      name = "esprima___esprima_2.7.3.tgz";
      path = fetchurl {
        name = "esprima___esprima_2.7.3.tgz";
        url  = "https://registry.yarnpkg.com/esprima/-/esprima-2.7.3.tgz";
        sha1 = "96e3b70d5779f6ad49cd032673d1c312767ba581";
      };
    }

    {
      name = "esprima___esprima_4.0.1.tgz";
      path = fetchurl {
        name = "esprima___esprima_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/esprima/-/esprima-4.0.1.tgz";
        sha1 = "13b04cdb3e6c5d19df91ab6987a8695619b0aa71";
      };
    }

    {
      name = "esprima___esprima_1.0.4.tgz";
      path = fetchurl {
        name = "esprima___esprima_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/esprima/-/esprima-1.0.4.tgz";
        sha1 = "9f557e08fc3b4d26ece9dd34f8fbf476b62585ad";
      };
    }

    {
      name = "esrefactor___esrefactor_0.1.0.tgz";
      path = fetchurl {
        name = "esrefactor___esrefactor_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/esrefactor/-/esrefactor-0.1.0.tgz";
        sha1 = "d142795a282339ab81e936b5b7a21b11bf197b13";
      };
    }

    {
      name = "estraverse___estraverse_5.0.0.tgz";
      path = fetchurl {
        name = "estraverse___estraverse_5.0.0.tgz";
        url  = "https://registry.yarnpkg.com/estraverse/-/estraverse-5.0.0.tgz";
        sha1 = "ac81750b482c11cca26e4b07e83ed8f75fbcdc22";
      };
    }

    {
      name = "estraverse___estraverse_1.9.3.tgz";
      path = fetchurl {
        name = "estraverse___estraverse_1.9.3.tgz";
        url  = "https://registry.yarnpkg.com/estraverse/-/estraverse-1.9.3.tgz";
        sha1 = "af67f2dc922582415950926091a4005d29c9bb44";
      };
    }

    {
      name = "estraverse___estraverse_0.0.4.tgz";
      path = fetchurl {
        name = "estraverse___estraverse_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/estraverse/-/estraverse-0.0.4.tgz";
        sha1 = "01a0932dfee574684a598af5a67c3bf9b6428db2";
      };
    }

    {
      name = "estraverse___estraverse_1.5.1.tgz";
      path = fetchurl {
        name = "estraverse___estraverse_1.5.1.tgz";
        url  = "https://registry.yarnpkg.com/estraverse/-/estraverse-1.5.1.tgz";
        sha1 = "867a3e8e58a9f84618afb6c2ddbcd916b7cbaf71";
      };
    }

    {
      name = "esutils___esutils_2.0.3.tgz";
      path = fetchurl {
        name = "esutils___esutils_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/esutils/-/esutils-2.0.3.tgz";
        sha1 = "74d2eb4de0b8da1293711910d50775b9b710ef64";
      };
    }

    {
      name = "esutils___esutils_1.0.0.tgz";
      path = fetchurl {
        name = "esutils___esutils_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/esutils/-/esutils-1.0.0.tgz";
        sha1 = "8151d358e20c8acc7fb745e7472c0025fe496570";
      };
    }

    {
      name = "etag___etag_1.7.0.tgz";
      path = fetchurl {
        name = "etag___etag_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/etag/-/etag-1.7.0.tgz";
        sha1 = "03d30b5f67dd6e632d2945d30d6652731a34d5d8";
      };
    }

    {
      name = "event_emitter___event_emitter_0.2.2.tgz";
      path = fetchurl {
        name = "event_emitter___event_emitter_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/event-emitter/-/event-emitter-0.2.2.tgz";
        sha1 = "c81e3724eb55407c5a0d5ee3299411f700f54291";
      };
    }

    {
      name = "event_emitter___event_emitter_0.3.5.tgz";
      path = fetchurl {
        name = "event_emitter___event_emitter_0.3.5.tgz";
        url  = "https://registry.yarnpkg.com/event-emitter/-/event-emitter-0.3.5.tgz";
        sha1 = "df8c69eef1647923c7157b9ce83840610b02cc39";
      };
    }

    {
      name = "event_stream___event_stream_4.0.1.tgz";
      path = fetchurl {
        name = "event_stream___event_stream_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/event-stream/-/event-stream-4.0.1.tgz";
        sha1 = "4092808ec995d0dd75ea4580c1df6a74db2cde65";
      };
    }

    {
      name = "event_stream___event_stream_3.3.2.tgz";
      path = fetchurl {
        name = "event_stream___event_stream_3.3.2.tgz";
        url  = "https://registry.yarnpkg.com/event-stream/-/event-stream-3.3.2.tgz";
        sha1 = "3cc310feb1f28d2f62b2a085d736a9ef566378b8";
      };
    }

    {
      name = "event_stream___event_stream_3.3.5.tgz";
      path = fetchurl {
        name = "event_stream___event_stream_3.3.5.tgz";
        url  = "https://registry.yarnpkg.com/event-stream/-/event-stream-3.3.5.tgz";
        sha1 = "e5dd8989543630d94c6cf4d657120341fa31636b";
      };
    }

    {
      name = "eventemitter3___eventemitter3_4.0.0.tgz";
      path = fetchurl {
        name = "eventemitter3___eventemitter3_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/eventemitter3/-/eventemitter3-4.0.0.tgz";
        sha1 = "d65176163887ee59f386d64c82610b696a4a74eb";
      };
    }

    {
      name = "events___events_1.0.2.tgz";
      path = fetchurl {
        name = "events___events_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/events/-/events-1.0.2.tgz";
        sha1 = "75849dcfe93d10fb057c30055afdbd51d06a8e24";
      };
    }

    {
      name = "expand_braces___expand_braces_0.1.2.tgz";
      path = fetchurl {
        name = "expand_braces___expand_braces_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/expand-braces/-/expand-braces-0.1.2.tgz";
        sha1 = "488b1d1d2451cb3d3a6b192cfc030f44c5855fea";
      };
    }

    {
      name = "expand_brackets___expand_brackets_0.1.5.tgz";
      path = fetchurl {
        name = "expand_brackets___expand_brackets_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/expand-brackets/-/expand-brackets-0.1.5.tgz";
        sha1 = "df07284e342a807cd733ac5af72411e581d1177b";
      };
    }

    {
      name = "expand_brackets___expand_brackets_2.1.4.tgz";
      path = fetchurl {
        name = "expand_brackets___expand_brackets_2.1.4.tgz";
        url  = "https://registry.yarnpkg.com/expand-brackets/-/expand-brackets-2.1.4.tgz";
        sha1 = "b77735e315ce30f6b6eff0f83b04151a22449622";
      };
    }

    {
      name = "expand_range___expand_range_0.1.1.tgz";
      path = fetchurl {
        name = "expand_range___expand_range_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/expand-range/-/expand-range-0.1.1.tgz";
        sha1 = "4cb8eda0993ca56fa4f41fc42f3cbb4ccadff044";
      };
    }

    {
      name = "expand_range___expand_range_1.8.2.tgz";
      path = fetchurl {
        name = "expand_range___expand_range_1.8.2.tgz";
        url  = "https://registry.yarnpkg.com/expand-range/-/expand-range-1.8.2.tgz";
        sha1 = "a299effd335fe2721ebae8e257ec79644fc85337";
      };
    }

    {
      name = "expand_tilde___expand_tilde_2.0.2.tgz";
      path = fetchurl {
        name = "expand_tilde___expand_tilde_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/expand-tilde/-/expand-tilde-2.0.2.tgz";
        sha1 = "97e801aa052df02454de46b02bf621642cdc8502";
      };
    }

    {
      name = "ext___ext_1.4.0.tgz";
      path = fetchurl {
        name = "ext___ext_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/ext/-/ext-1.4.0.tgz";
        sha1 = "89ae7a07158f79d35517882904324077e4379244";
      };
    }

    {
      name = "extend_shallow___extend_shallow_2.0.1.tgz";
      path = fetchurl {
        name = "extend_shallow___extend_shallow_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/extend-shallow/-/extend-shallow-2.0.1.tgz";
        sha1 = "51af7d614ad9a9f610ea1bafbb989d6b1c56890f";
      };
    }

    {
      name = "extend_shallow___extend_shallow_3.0.2.tgz";
      path = fetchurl {
        name = "extend_shallow___extend_shallow_3.0.2.tgz";
        url  = "https://registry.yarnpkg.com/extend-shallow/-/extend-shallow-3.0.2.tgz";
        sha1 = "26a71aaf073b39fb2127172746131c2704028db8";
      };
    }

    {
      name = "extend___extend_3.0.2.tgz";
      path = fetchurl {
        name = "extend___extend_3.0.2.tgz";
        url  = "https://registry.yarnpkg.com/extend/-/extend-3.0.2.tgz";
        sha1 = "f8b1136b4071fbd8eb140aff858b1019ec2915fa";
      };
    }

    {
      name = "extglob___extglob_0.3.2.tgz";
      path = fetchurl {
        name = "extglob___extglob_0.3.2.tgz";
        url  = "https://registry.yarnpkg.com/extglob/-/extglob-0.3.2.tgz";
        sha1 = "2e18ff3d2f49ab2765cec9023f011daa8d8349a1";
      };
    }

    {
      name = "extglob___extglob_2.0.4.tgz";
      path = fetchurl {
        name = "extglob___extglob_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/extglob/-/extglob-2.0.4.tgz";
        sha1 = "ad00fe4dc612a9232e8718711dc5cb5ab0285543";
      };
    }

    {
      name = "extsprintf___extsprintf_1.3.0.tgz";
      path = fetchurl {
        name = "extsprintf___extsprintf_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/extsprintf/-/extsprintf-1.3.0.tgz";
        sha1 = "96918440e3041a7a414f8c52e3c574eb3c3e1e05";
      };
    }

    {
      name = "extsprintf___extsprintf_1.4.0.tgz";
      path = fetchurl {
        name = "extsprintf___extsprintf_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/extsprintf/-/extsprintf-1.4.0.tgz";
        sha1 = "e2689f8f356fad62cca65a3a91c5df5f9551692f";
      };
    }

    {
      name = "fancy_log___fancy_log_1.3.3.tgz";
      path = fetchurl {
        name = "fancy_log___fancy_log_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/fancy-log/-/fancy-log-1.3.3.tgz";
        sha1 = "dbc19154f558690150a23953a0adbd035be45fc7";
      };
    }

    {
      name = "fast_deep_equal___fast_deep_equal_3.1.1.tgz";
      path = fetchurl {
        name = "fast_deep_equal___fast_deep_equal_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/fast-deep-equal/-/fast-deep-equal-3.1.1.tgz";
        sha1 = "545145077c501491e33b15ec408c294376e94ae4";
      };
    }

    {
      name = "fast_json_stable_stringify___fast_json_stable_stringify_2.1.0.tgz";
      path = fetchurl {
        name = "fast_json_stable_stringify___fast_json_stable_stringify_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/fast-json-stable-stringify/-/fast-json-stable-stringify-2.1.0.tgz";
        sha1 = "874bf69c6f404c2b5d99c481341399fd55892633";
      };
    }

    {
      name = "fast_levenshtein___fast_levenshtein_2.0.6.tgz";
      path = fetchurl {
        name = "fast_levenshtein___fast_levenshtein_2.0.6.tgz";
        url  = "https://registry.yarnpkg.com/fast-levenshtein/-/fast-levenshtein-2.0.6.tgz";
        sha1 = "3d8a5c66883a16a30ca8643e851f19baa7797917";
      };
    }

    {
      name = "faye_websocket___faye_websocket_0.7.3.tgz";
      path = fetchurl {
        name = "faye_websocket___faye_websocket_0.7.3.tgz";
        url  = "https://registry.yarnpkg.com/faye-websocket/-/faye-websocket-0.7.3.tgz";
        sha1 = "cc4074c7f4a4dfd03af54dd65c354b135132ce11";
      };
    }

    {
      name = "file_uri_to_path___file_uri_to_path_1.0.0.tgz";
      path = fetchurl {
        name = "file_uri_to_path___file_uri_to_path_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/file-uri-to-path/-/file-uri-to-path-1.0.0.tgz";
        sha1 = "553a7b8446ff6f684359c445f1e37a05dacc33dd";
      };
    }

    {
      name = "filename_regex___filename_regex_2.0.1.tgz";
      path = fetchurl {
        name = "filename_regex___filename_regex_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/filename-regex/-/filename-regex-2.0.1.tgz";
        sha1 = "c1c4b9bee3e09725ddb106b75c1e301fe2f18b26";
      };
    }

    {
      name = "fill_range___fill_range_2.2.4.tgz";
      path = fetchurl {
        name = "fill_range___fill_range_2.2.4.tgz";
        url  = "https://registry.yarnpkg.com/fill-range/-/fill-range-2.2.4.tgz";
        sha1 = "eb1e773abb056dcd8df2bfdf6af59b8b3a936565";
      };
    }

    {
      name = "fill_range___fill_range_4.0.0.tgz";
      path = fetchurl {
        name = "fill_range___fill_range_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fill-range/-/fill-range-4.0.0.tgz";
        sha1 = "d544811d428f98eb06a63dc402d2403c328c38f7";
      };
    }

    {
      name = "finalhandler___finalhandler_1.1.2.tgz";
      path = fetchurl {
        name = "finalhandler___finalhandler_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/finalhandler/-/finalhandler-1.1.2.tgz";
        sha1 = "b7e7d000ffd11938d0fdb053506f6ebabe9f587d";
      };
    }

    {
      name = "find_index___find_index_0.1.1.tgz";
      path = fetchurl {
        name = "find_index___find_index_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/find-index/-/find-index-0.1.1.tgz";
        sha1 = "675d358b2ca3892d795a1ab47232f8b6e2e0dde4";
      };
    }

    {
      name = "find_up___find_up_1.1.2.tgz";
      path = fetchurl {
        name = "find_up___find_up_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/find-up/-/find-up-1.1.2.tgz";
        sha1 = "6b2e9822b1a2ce0a60ab64d610eccad53cb24d0f";
      };
    }

    {
      name = "findup_sync___findup_sync_2.0.0.tgz";
      path = fetchurl {
        name = "findup_sync___findup_sync_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/findup-sync/-/findup-sync-2.0.0.tgz";
        sha1 = "9326b1488c22d1a6088650a86901b2d9a90a2cbc";
      };
    }

    {
      name = "fined___fined_1.2.0.tgz";
      path = fetchurl {
        name = "fined___fined_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/fined/-/fined-1.2.0.tgz";
        sha1 = "d00beccf1aa2b475d16d423b0238b713a2c4a37b";
      };
    }

    {
      name = "first_chunk_stream___first_chunk_stream_1.0.0.tgz";
      path = fetchurl {
        name = "first_chunk_stream___first_chunk_stream_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/first-chunk-stream/-/first-chunk-stream-1.0.0.tgz";
        sha1 = "59bfb50cd905f60d7c394cd3d9acaab4e6ad934e";
      };
    }

    {
      name = "fixtures2js___fixtures2js_0.0.0.tgz";
      path = fetchurl {
        name = "fixtures2js___fixtures2js_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fixtures2js/-/fixtures2js-0.0.0.tgz";
        sha1 = "602f7964c5b2963fe73224c8e4a3607d75c1b34f";
      };
    }

    {
      name = "flagged_respawn___flagged_respawn_1.0.1.tgz";
      path = fetchurl {
        name = "flagged_respawn___flagged_respawn_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/flagged-respawn/-/flagged-respawn-1.0.1.tgz";
        sha1 = "e7de6f1279ddd9ca9aac8a5971d618606b3aab41";
      };
    }

    {
      name = "follow_redirects___follow_redirects_1.11.0.tgz";
      path = fetchurl {
        name = "follow_redirects___follow_redirects_1.11.0.tgz";
        url  = "https://registry.yarnpkg.com/follow-redirects/-/follow-redirects-1.11.0.tgz";
        sha1 = "afa14f08ba12a52963140fe43212658897bc0ecb";
      };
    }

    {
      name = "for_in___for_in_1.0.2.tgz";
      path = fetchurl {
        name = "for_in___for_in_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/for-in/-/for-in-1.0.2.tgz";
        sha1 = "81068d295a8142ec0ac726c6e2200c30fb6d5e80";
      };
    }

    {
      name = "for_own___for_own_0.1.5.tgz";
      path = fetchurl {
        name = "for_own___for_own_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/for-own/-/for-own-0.1.5.tgz";
        sha1 = "5265c681a4f294dabbf17c9509b6763aa84510ce";
      };
    }

    {
      name = "for_own___for_own_1.0.0.tgz";
      path = fetchurl {
        name = "for_own___for_own_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/for-own/-/for-own-1.0.0.tgz";
        sha1 = "c63332f415cedc4b04dbfe70cf836494c53cb44b";
      };
    }

    {
      name = "forever_agent___forever_agent_0.5.2.tgz";
      path = fetchurl {
        name = "forever_agent___forever_agent_0.5.2.tgz";
        url  = "https://registry.yarnpkg.com/forever-agent/-/forever-agent-0.5.2.tgz";
        sha1 = "6d0e09c4921f94a27f63d3b49c5feff1ea4c5130";
      };
    }

    {
      name = "forever_agent___forever_agent_0.6.1.tgz";
      path = fetchurl {
        name = "forever_agent___forever_agent_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/forever-agent/-/forever-agent-0.6.1.tgz";
        sha1 = "fbc71f0c41adeb37f96c577ad1ed42d8fdacca91";
      };
    }

    {
      name = "fork_stream___fork_stream_0.0.4.tgz";
      path = fetchurl {
        name = "fork_stream___fork_stream_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/fork-stream/-/fork-stream-0.0.4.tgz";
        sha1 = "db849fce77f6708a5f8f386ae533a0907b54ae70";
      };
    }

    {
      name = "form_data___form_data_0.1.4.tgz";
      path = fetchurl {
        name = "form_data___form_data_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/form-data/-/form-data-0.1.4.tgz";
        sha1 = "91abd788aba9702b1aabfa8bc01031a2ac9e3b12";
      };
    }

    {
      name = "form_data___form_data_0.2.0.tgz";
      path = fetchurl {
        name = "form_data___form_data_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/form-data/-/form-data-0.2.0.tgz";
        sha1 = "26f8bc26da6440e299cbdcfb69035c4f77a6e466";
      };
    }

    {
      name = "form_data___form_data_2.3.3.tgz";
      path = fetchurl {
        name = "form_data___form_data_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/form-data/-/form-data-2.3.3.tgz";
        sha1 = "dcce52c05f644f298c6a7ab936bd724ceffbf3a6";
      };
    }

    {
      name = "fragment_cache___fragment_cache_0.2.1.tgz";
      path = fetchurl {
        name = "fragment_cache___fragment_cache_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/fragment-cache/-/fragment-cache-0.2.1.tgz";
        sha1 = "4290fad27f13e89be7f33799c6bc5a0abfff0d19";
      };
    }

    {
      name = "fresh___fresh_0.3.0.tgz";
      path = fetchurl {
        name = "fresh___fresh_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/fresh/-/fresh-0.3.0.tgz";
        sha1 = "651f838e22424e7566de161d8358caa199f83d4f";
      };
    }

    {
      name = "from___from_0.1.7.tgz";
      path = fetchurl {
        name = "from___from_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/from/-/from-0.1.7.tgz";
        sha1 = "83c60afc58b9c56997007ed1a768b3ab303a44fe";
      };
    }

    {
      name = "fs_access___fs_access_1.0.1.tgz";
      path = fetchurl {
        name = "fs_access___fs_access_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/fs-access/-/fs-access-1.0.1.tgz";
        sha1 = "d6a87f262271cefebec30c553407fb995da8777a";
      };
    }

    {
      name = "fs_minipass___fs_minipass_1.2.7.tgz";
      path = fetchurl {
        name = "fs_minipass___fs_minipass_1.2.7.tgz";
        url  = "https://registry.yarnpkg.com/fs-minipass/-/fs-minipass-1.2.7.tgz";
        sha1 = "ccff8570841e7fe4265693da88936c55aed7f7c7";
      };
    }

    {
      name = "fs.realpath___fs.realpath_1.0.0.tgz";
      path = fetchurl {
        name = "fs.realpath___fs.realpath_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fs.realpath/-/fs.realpath-1.0.0.tgz";
        sha1 = "1504ad2523158caa40db4a2787cb01411994ea4f";
      };
    }

    {
      name = "fsevents___fsevents_1.2.12.tgz";
      path = fetchurl {
        name = "fsevents___fsevents_1.2.12.tgz";
        url  = "https://registry.yarnpkg.com/fsevents/-/fsevents-1.2.12.tgz";
        sha1 = "db7e0d8ec3b0b45724fd4d83d43554a8f1f0de5c";
      };
    }

    {
      name = "fstream_ignore___fstream_ignore_0.0.10.tgz";
      path = fetchurl {
        name = "fstream_ignore___fstream_ignore_0.0.10.tgz";
        url  = "https://registry.yarnpkg.com/fstream-ignore/-/fstream-ignore-0.0.10.tgz";
        sha1 = "b10f8f522cc55415f80b41f7d3a32e6cba254e8c";
      };
    }

    {
      name = "fstream___fstream_1.0.12.tgz";
      path = fetchurl {
        name = "fstream___fstream_1.0.12.tgz";
        url  = "https://registry.yarnpkg.com/fstream/-/fstream-1.0.12.tgz";
        sha1 = "4e8ba8ee2d48be4f7d0de505455548eae5932045";
      };
    }

    {
      name = "fstream___fstream_0.1.31.tgz";
      path = fetchurl {
        name = "fstream___fstream_0.1.31.tgz";
        url  = "https://registry.yarnpkg.com/fstream/-/fstream-0.1.31.tgz";
        sha1 = "7337f058fbbbbefa8c9f561a28cab0849202c988";
      };
    }

    {
      name = "function_bind___function_bind_1.1.1.tgz";
      path = fetchurl {
        name = "function_bind___function_bind_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/function-bind/-/function-bind-1.1.1.tgz";
        sha1 = "a56899d3ea3c9bab874bb9773b7c5ede92f4895d";
      };
    }

    {
      name = "gauge___gauge_2.7.4.tgz";
      path = fetchurl {
        name = "gauge___gauge_2.7.4.tgz";
        url  = "https://registry.yarnpkg.com/gauge/-/gauge-2.7.4.tgz";
        sha1 = "2c03405c7538c39d7eb37b317022e325fb018bf7";
      };
    }

    {
      name = "gaze___gaze_0.5.2.tgz";
      path = fetchurl {
        name = "gaze___gaze_0.5.2.tgz";
        url  = "https://registry.yarnpkg.com/gaze/-/gaze-0.5.2.tgz";
        sha1 = "40b709537d24d1d45767db5a908689dfe69ac44f";
      };
    }

    {
      name = "gaze___gaze_1.1.3.tgz";
      path = fetchurl {
        name = "gaze___gaze_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/gaze/-/gaze-1.1.3.tgz";
        sha1 = "c441733e13b927ac8c0ff0b4c3b033f28812924a";
      };
    }

    {
      name = "get_caller_file___get_caller_file_1.0.3.tgz";
      path = fetchurl {
        name = "get_caller_file___get_caller_file_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/get-caller-file/-/get-caller-file-1.0.3.tgz";
        sha1 = "f978fa4c90d1dfe7ff2d6beda2a515e713bdcf4a";
      };
    }

    {
      name = "get_stdin___get_stdin_4.0.1.tgz";
      path = fetchurl {
        name = "get_stdin___get_stdin_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/get-stdin/-/get-stdin-4.0.1.tgz";
        sha1 = "b968c6b0a04384324902e8bf1a5df32579a450fe";
      };
    }

    {
      name = "get_value___get_value_2.0.6.tgz";
      path = fetchurl {
        name = "get_value___get_value_2.0.6.tgz";
        url  = "https://registry.yarnpkg.com/get-value/-/get-value-2.0.6.tgz";
        sha1 = "dc15ca1c672387ca76bd37ac0a395ba2042a2c28";
      };
    }

    {
      name = "getpass___getpass_0.1.7.tgz";
      path = fetchurl {
        name = "getpass___getpass_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/getpass/-/getpass-0.1.7.tgz";
        sha1 = "5eff8e3e684d569ae4cb2b1282604e8ba62149fa";
      };
    }

    {
      name = "glob_base___glob_base_0.3.0.tgz";
      path = fetchurl {
        name = "glob_base___glob_base_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/glob-base/-/glob-base-0.3.0.tgz";
        sha1 = "dbb164f6221b1c0b1ccf82aea328b497df0ea3c4";
      };
    }

    {
      name = "glob_parent___glob_parent_2.0.0.tgz";
      path = fetchurl {
        name = "glob_parent___glob_parent_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/glob-parent/-/glob-parent-2.0.0.tgz";
        sha1 = "81383d72db054fcccf5336daa902f182f6edbb28";
      };
    }

    {
      name = "glob_stream___glob_stream_3.1.18.tgz";
      path = fetchurl {
        name = "glob_stream___glob_stream_3.1.18.tgz";
        url  = "https://registry.yarnpkg.com/glob-stream/-/glob-stream-3.1.18.tgz";
        sha1 = "9170a5f12b790306fdfe598f313f8f7954fd143b";
      };
    }

    {
      name = "glob_watcher___glob_watcher_0.0.6.tgz";
      path = fetchurl {
        name = "glob_watcher___glob_watcher_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/glob-watcher/-/glob-watcher-0.0.6.tgz";
        sha1 = "b95b4a8df74b39c83298b0c05c978b4d9a3b710b";
      };
    }

    {
      name = "glob2base___glob2base_0.0.12.tgz";
      path = fetchurl {
        name = "glob2base___glob2base_0.0.12.tgz";
        url  = "https://registry.yarnpkg.com/glob2base/-/glob2base-0.0.12.tgz";
        sha1 = "9d419b3e28f12e83a362164a277055922c9c0d56";
      };
    }

    {
      name = "glob___glob_4.5.3.tgz";
      path = fetchurl {
        name = "glob___glob_4.5.3.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-4.5.3.tgz";
        sha1 = "c6cb73d3226c1efef04de3c56d012f03377ee15f";
      };
    }

    {
      name = "glob___glob_5.0.15.tgz";
      path = fetchurl {
        name = "glob___glob_5.0.15.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-5.0.15.tgz";
        sha1 = "1bc936b9e02f4a603fcc222ecf7633d30b8b93b1";
      };
    }

    {
      name = "glob___glob_6.0.4.tgz";
      path = fetchurl {
        name = "glob___glob_6.0.4.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-6.0.4.tgz";
        sha1 = "0f08860f6a155127b2fadd4f9ce24b1aab6e4d22";
      };
    }

    {
      name = "glob___glob_7.1.6.tgz";
      path = fetchurl {
        name = "glob___glob_7.1.6.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-7.1.6.tgz";
        sha1 = "141f33b81a7c2492e125594307480c46679278a6";
      };
    }

    {
      name = "glob___glob_3.1.21.tgz";
      path = fetchurl {
        name = "glob___glob_3.1.21.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-3.1.21.tgz";
        sha1 = "d29e0a055dea5138f4d07ed40e8982e83c2066cd";
      };
    }

    {
      name = "glob___glob_3.2.11.tgz";
      path = fetchurl {
        name = "glob___glob_3.2.11.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-3.2.11.tgz";
        sha1 = "4a973f635b9190f715d10987d5c00fd2815ebe3d";
      };
    }

    {
      name = "glob___glob_4.0.6.tgz";
      path = fetchurl {
        name = "glob___glob_4.0.6.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-4.0.6.tgz";
        sha1 = "695c50bdd4e2fb5c5d370b091f388d3707e291a7";
      };
    }

    {
      name = "global_modules___global_modules_1.0.0.tgz";
      path = fetchurl {
        name = "global_modules___global_modules_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/global-modules/-/global-modules-1.0.0.tgz";
        sha1 = "6d770f0eb523ac78164d72b5e71a8877265cc3ea";
      };
    }

    {
      name = "global_prefix___global_prefix_1.0.2.tgz";
      path = fetchurl {
        name = "global_prefix___global_prefix_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/global-prefix/-/global-prefix-1.0.2.tgz";
        sha1 = "dbf743c6c14992593c655568cb66ed32c0122ebe";
      };
    }

    {
      name = "globule___globule_1.3.1.tgz";
      path = fetchurl {
        name = "globule___globule_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/globule/-/globule-1.3.1.tgz";
        sha1 = "90a25338f22b7fbeb527cee63c629aea754d33b9";
      };
    }

    {
      name = "globule___globule_0.1.0.tgz";
      path = fetchurl {
        name = "globule___globule_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/globule/-/globule-0.1.0.tgz";
        sha1 = "d9c8edde1da79d125a151b79533b978676346ae5";
      };
    }

    {
      name = "glogg___glogg_1.0.2.tgz";
      path = fetchurl {
        name = "glogg___glogg_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/glogg/-/glogg-1.0.2.tgz";
        sha1 = "2d7dd702beda22eb3bffadf880696da6d846313f";
      };
    }

    {
      name = "got___got_3.3.1.tgz";
      path = fetchurl {
        name = "got___got_3.3.1.tgz";
        url  = "https://registry.yarnpkg.com/got/-/got-3.3.1.tgz";
        sha1 = "e5d0ed4af55fc3eef4d56007769d98192bcb2eca";
      };
    }

    {
      name = "graceful_fs___graceful_fs_3.0.12.tgz";
      path = fetchurl {
        name = "graceful_fs___graceful_fs_3.0.12.tgz";
        url  = "https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-3.0.12.tgz";
        sha1 = "0034947ce9ed695ec8ab0b854bc919e82b1ffaef";
      };
    }

    {
      name = "graceful_fs___graceful_fs_4.2.3.tgz";
      path = fetchurl {
        name = "graceful_fs___graceful_fs_4.2.3.tgz";
        url  = "https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.2.3.tgz";
        sha1 = "4a12ff1b60376ef09862c2093edd908328be8423";
      };
    }

    {
      name = "graceful_fs___graceful_fs_1.2.3.tgz";
      path = fetchurl {
        name = "graceful_fs___graceful_fs_1.2.3.tgz";
        url  = "https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-1.2.3.tgz";
        sha1 = "15a4806a57547cb2d2dbf27f42e89a8c3451b364";
      };
    }

    {
      name = "graceful_fs___graceful_fs_2.0.3.tgz";
      path = fetchurl {
        name = "graceful_fs___graceful_fs_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-2.0.3.tgz";
        sha1 = "7cd2cdb228a4a3f36e95efa6cc142de7d1a136d0";
      };
    }

    {
      name = "guanlecoja___guanlecoja_0.9.2.tgz";
      path = fetchurl {
        name = "guanlecoja___guanlecoja_0.9.2.tgz";
        url  = "https://registry.yarnpkg.com/guanlecoja/-/guanlecoja-0.9.2.tgz";
        sha1 = "03febe92d9e7575a633b4d5ad8d19f5ee1cdf326";
      };
    }

    {
      name = "gulp_angular_templatecache___gulp_angular_templatecache_1.9.1.tgz";
      path = fetchurl {
        name = "gulp_angular_templatecache___gulp_angular_templatecache_1.9.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-angular-templatecache/-/gulp-angular-templatecache-1.9.1.tgz";
        sha1 = "60f631e97aaaa765d942e37042e4bfbb1a5df244";
      };
    }

    {
      name = "gulp_bower_deps___gulp_bower_deps_0.3.3.tgz";
      path = fetchurl {
        name = "gulp_bower_deps___gulp_bower_deps_0.3.3.tgz";
        url  = "https://registry.yarnpkg.com/gulp-bower-deps/-/gulp-bower-deps-0.3.3.tgz";
        sha1 = "2109fe3fbee35069f67312bb977e591d890296cd";
      };
    }

    {
      name = "gulp_browserify___gulp_browserify_0.5.1.tgz";
      path = fetchurl {
        name = "gulp_browserify___gulp_browserify_0.5.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-browserify/-/gulp-browserify-0.5.1.tgz";
        sha1 = "820108ac2554a954adb8be17d23958b0c04be083";
      };
    }

    {
      name = "gulp_cached___gulp_cached_1.1.1.tgz";
      path = fetchurl {
        name = "gulp_cached___gulp_cached_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-cached/-/gulp-cached-1.1.1.tgz";
        sha1 = "fe7cd4f87f37601e6073cfedee5c2bdaf8b6acce";
      };
    }

    {
      name = "gulp_clean_css___gulp_clean_css_2.4.0.tgz";
      path = fetchurl {
        name = "gulp_clean_css___gulp_clean_css_2.4.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-clean-css/-/gulp-clean-css-2.4.0.tgz";
        sha1 = "2ae48109fe83ccc967ff5ad53c044949a4863b36";
      };
    }

    {
      name = "gulp_coffee___gulp_coffee_2.3.5.tgz";
      path = fetchurl {
        name = "gulp_coffee___gulp_coffee_2.3.5.tgz";
        url  = "https://registry.yarnpkg.com/gulp-coffee/-/gulp-coffee-2.3.5.tgz";
        sha1 = "8c64e9ac884e1bab4e20b66ac7c386a816859041";
      };
    }

    {
      name = "gulp_concat___gulp_concat_2.6.0.tgz";
      path = fetchurl {
        name = "gulp_concat___gulp_concat_2.6.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-concat/-/gulp-concat-2.6.0.tgz";
        sha1 = "585cfb115411f348773131140566b6a81c69cb91";
      };
    }

    {
      name = "gulp_concat___gulp_concat_2.6.1.tgz";
      path = fetchurl {
        name = "gulp_concat___gulp_concat_2.6.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-concat/-/gulp-concat-2.6.1.tgz";
        sha1 = "633d16c95d88504628ad02665663cee5a4793353";
      };
    }

    {
      name = "gulp_fixtures2js___gulp_fixtures2js_0.0.1.tgz";
      path = fetchurl {
        name = "gulp_fixtures2js___gulp_fixtures2js_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-fixtures2js/-/gulp-fixtures2js-0.0.1.tgz";
        sha1 = "4a3cbb4404bdfab92f7d2b6e09de2bfd0ae78506";
      };
    }

    {
      name = "gulp_footer___gulp_footer_1.0.5.tgz";
      path = fetchurl {
        name = "gulp_footer___gulp_footer_1.0.5.tgz";
        url  = "https://registry.yarnpkg.com/gulp-footer/-/gulp-footer-1.0.5.tgz";
        sha1 = "e84ca777e266be7bbc2d45d2df0e7eba8dfa3e54";
      };
    }

    {
      name = "gulp_footer___gulp_footer_1.1.2.tgz";
      path = fetchurl {
        name = "gulp_footer___gulp_footer_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/gulp-footer/-/gulp-footer-1.1.2.tgz";
        sha1 = "7fe28324ec67e3d618d31e0f5ea2ee5b454f6877";
      };
    }

    {
      name = "gulp_header___gulp_header_1.8.2.tgz";
      path = fetchurl {
        name = "gulp_header___gulp_header_1.8.2.tgz";
        url  = "https://registry.yarnpkg.com/gulp-header/-/gulp-header-1.8.2.tgz";
        sha1 = "3ab222f53719d2d03d81d9134252fe7d52425aa4";
      };
    }

    {
      name = "gulp_header___gulp_header_1.8.12.tgz";
      path = fetchurl {
        name = "gulp_header___gulp_header_1.8.12.tgz";
        url  = "https://registry.yarnpkg.com/gulp-header/-/gulp-header-1.8.12.tgz";
        sha1 = "ad306be0066599127281c4f8786660e705080a84";
      };
    }

    {
      name = "gulp_help___gulp_help_1.6.1.tgz";
      path = fetchurl {
        name = "gulp_help___gulp_help_1.6.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-help/-/gulp-help-1.6.1.tgz";
        sha1 = "261db186e18397fef3f6a2c22e9c315bfa88ae0c";
      };
    }

    {
      name = "gulp_if___gulp_if_2.0.2.tgz";
      path = fetchurl {
        name = "gulp_if___gulp_if_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/gulp-if/-/gulp-if-2.0.2.tgz";
        sha1 = "a497b7e7573005041caa2bc8b7dda3c80444d629";
      };
    }

    {
      name = "gulp_less___gulp_less_1.3.9.tgz";
      path = fetchurl {
        name = "gulp_less___gulp_less_1.3.9.tgz";
        url  = "https://registry.yarnpkg.com/gulp-less/-/gulp-less-1.3.9.tgz";
        sha1 = "e129750f236693ead5b522af311cc33eeff1910e";
      };
    }

    {
      name = "gulp_livereload___gulp_livereload_3.8.1.tgz";
      path = fetchurl {
        name = "gulp_livereload___gulp_livereload_3.8.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-livereload/-/gulp-livereload-3.8.1.tgz";
        sha1 = "00f744b2d749d3e9e3746589c8a44acac779b50f";
      };
    }

    {
      name = "gulp_match___gulp_match_1.1.0.tgz";
      path = fetchurl {
        name = "gulp_match___gulp_match_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-match/-/gulp-match-1.1.0.tgz";
        sha1 = "552b7080fc006ee752c90563f9fec9d61aafdf4f";
      };
    }

    {
      name = "gulp_ng_annotate___gulp_ng_annotate_1.1.0.tgz";
      path = fetchurl {
        name = "gulp_ng_annotate___gulp_ng_annotate_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-ng-annotate/-/gulp-ng-annotate-1.1.0.tgz";
        sha1 = "5e801be073d8f6d343c4ff65b71717b90fac13ce";
      };
    }

    {
      name = "gulp_ng_classify___gulp_ng_classify_4.0.1.tgz";
      path = fetchurl {
        name = "gulp_ng_classify___gulp_ng_classify_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-ng-classify/-/gulp-ng-classify-4.0.1.tgz";
        sha1 = "3019161127c35c317ea08dc2a65ea35b592dbfd7";
      };
    }

    {
      name = "gulp_pug___gulp_pug_3.3.0.tgz";
      path = fetchurl {
        name = "gulp_pug___gulp_pug_3.3.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-pug/-/gulp-pug-3.3.0.tgz";
        sha1 = "46982c1439c094c360542ed8ba5c882d3bb711cf";
      };
    }

    {
      name = "gulp_remember___gulp_remember_0.3.1.tgz";
      path = fetchurl {
        name = "gulp_remember___gulp_remember_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-remember/-/gulp-remember-0.3.1.tgz";
        sha1 = "5776b6f64c5a1c5c4d4555406723ec8e2b0407e7";
      };
    }

    {
      name = "gulp_rename___gulp_rename_1.2.3.tgz";
      path = fetchurl {
        name = "gulp_rename___gulp_rename_1.2.3.tgz";
        url  = "https://registry.yarnpkg.com/gulp-rename/-/gulp-rename-1.2.3.tgz";
        sha1 = "37b75298e9d3e6c0fe9ac4eac13ce3be5434646b";
      };
    }

    {
      name = "gulp_replace___gulp_replace_0.5.4.tgz";
      path = fetchurl {
        name = "gulp_replace___gulp_replace_0.5.4.tgz";
        url  = "https://registry.yarnpkg.com/gulp-replace/-/gulp-replace-0.5.4.tgz";
        sha1 = "69a67914bbd13c562bff14f504a403796aa0daa9";
      };
    }

    {
      name = "gulp_sass___gulp_sass_3.2.1.tgz";
      path = fetchurl {
        name = "gulp_sass___gulp_sass_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp-sass/-/gulp-sass-3.2.1.tgz";
        sha1 = "2e3688a96fd8be1c0c01340750c191b2e79fab94";
      };
    }

    {
      name = "gulp_sourcemaps___gulp_sourcemaps_1.6.0.tgz";
      path = fetchurl {
        name = "gulp_sourcemaps___gulp_sourcemaps_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-sourcemaps/-/gulp-sourcemaps-1.6.0.tgz";
        sha1 = "b86ff349d801ceb56e1d9e7dc7bbcb4b7dee600c";
      };
    }

    {
      name = "gulp_uglify___gulp_uglify_1.4.2.tgz";
      path = fetchurl {
        name = "gulp_uglify___gulp_uglify_1.4.2.tgz";
        url  = "https://registry.yarnpkg.com/gulp-uglify/-/gulp-uglify-1.4.2.tgz";
        sha1 = "2807ea1016e4962c37766c02feeb5501818857c3";
      };
    }

    {
      name = "gulp_util___gulp_util_3.0.8.tgz";
      path = fetchurl {
        name = "gulp_util___gulp_util_3.0.8.tgz";
        url  = "https://registry.yarnpkg.com/gulp-util/-/gulp-util-3.0.8.tgz";
        sha1 = "0054e1e744502e27c04c187c3ecc505dd54bbb4f";
      };
    }

    {
      name = "gulp_util___gulp_util_3.0.7.tgz";
      path = fetchurl {
        name = "gulp_util___gulp_util_3.0.7.tgz";
        url  = "https://registry.yarnpkg.com/gulp-util/-/gulp-util-3.0.7.tgz";
        sha1 = "78925c4b8f8b49005ac01a011c557e6218941cbb";
      };
    }

    {
      name = "gulp_util___gulp_util_2.2.20.tgz";
      path = fetchurl {
        name = "gulp_util___gulp_util_2.2.20.tgz";
        url  = "https://registry.yarnpkg.com/gulp-util/-/gulp-util-2.2.20.tgz";
        sha1 = "d7146e5728910bd8f047a6b0b1e549bc22dbd64c";
      };
    }

    {
      name = "gulp_wrap___gulp_wrap_0.8.0.tgz";
      path = fetchurl {
        name = "gulp_wrap___gulp_wrap_0.8.0.tgz";
        url  = "https://registry.yarnpkg.com/gulp-wrap/-/gulp-wrap-0.8.0.tgz";
        sha1 = "c41ce89a374947788b78c9e67f33bbe838c69b86";
      };
    }

    {
      name = "gulp___gulp_3.9.1.tgz";
      path = fetchurl {
        name = "gulp___gulp_3.9.1.tgz";
        url  = "https://registry.yarnpkg.com/gulp/-/gulp-3.9.1.tgz";
        sha1 = "571ce45928dd40af6514fc4011866016c13845b4";
      };
    }

    {
      name = "gulplog___gulplog_1.0.0.tgz";
      path = fetchurl {
        name = "gulplog___gulplog_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/gulplog/-/gulplog-1.0.0.tgz";
        sha1 = "e28c4d45d05ecbbed818363ce8f9c5926229ffe5";
      };
    }

    {
      name = "handlebars___handlebars_4.7.3.tgz";
      path = fetchurl {
        name = "handlebars___handlebars_4.7.3.tgz";
        url  = "https://registry.yarnpkg.com/handlebars/-/handlebars-4.7.3.tgz";
        sha1 = "8ece2797826886cf8082d1726ff21d2a022550ee";
      };
    }

    {
      name = "handlebars___handlebars_1.3.0.tgz";
      path = fetchurl {
        name = "handlebars___handlebars_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/handlebars/-/handlebars-1.3.0.tgz";
        sha1 = "9e9b130a93e389491322d975cf3ec1818c37ce34";
      };
    }

    {
      name = "har_schema___har_schema_2.0.0.tgz";
      path = fetchurl {
        name = "har_schema___har_schema_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/har-schema/-/har-schema-2.0.0.tgz";
        sha1 = "a94c2224ebcac04782a0d9035521f24735b7ec92";
      };
    }

    {
      name = "har_validator___har_validator_5.1.3.tgz";
      path = fetchurl {
        name = "har_validator___har_validator_5.1.3.tgz";
        url  = "https://registry.yarnpkg.com/har-validator/-/har-validator-5.1.3.tgz";
        sha1 = "1ef89ebd3e4996557675eed9893110dc350fa080";
      };
    }

    {
      name = "has_ansi___has_ansi_0.1.0.tgz";
      path = fetchurl {
        name = "has_ansi___has_ansi_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/has-ansi/-/has-ansi-0.1.0.tgz";
        sha1 = "84f265aae8c0e6a88a12d7022894b7568894c62e";
      };
    }

    {
      name = "has_ansi___has_ansi_2.0.0.tgz";
      path = fetchurl {
        name = "has_ansi___has_ansi_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-ansi/-/has-ansi-2.0.0.tgz";
        sha1 = "34f5049ce1ecdf2b0649af3ef24e45ed35416d91";
      };
    }

    {
      name = "has_binary___has_binary_0.1.7.tgz";
      path = fetchurl {
        name = "has_binary___has_binary_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/has-binary/-/has-binary-0.1.7.tgz";
        sha1 = "68e61eb16210c9545a0a5cce06a873912fe1e68c";
      };
    }

    {
      name = "has_color___has_color_0.1.7.tgz";
      path = fetchurl {
        name = "has_color___has_color_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/has-color/-/has-color-0.1.7.tgz";
        sha1 = "67144a5260c34fc3cca677d041daf52fe7b78b2f";
      };
    }

    {
      name = "has_cors___has_cors_1.1.0.tgz";
      path = fetchurl {
        name = "has_cors___has_cors_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/has-cors/-/has-cors-1.1.0.tgz";
        sha1 = "5e474793f7ea9843d1bb99c23eef49ff126fff39";
      };
    }

    {
      name = "has_flag___has_flag_1.0.0.tgz";
      path = fetchurl {
        name = "has_flag___has_flag_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-flag/-/has-flag-1.0.0.tgz";
        sha1 = "9d9e793165ce017a00f00418c43f942a7b1d11fa";
      };
    }

    {
      name = "has_flag___has_flag_4.0.0.tgz";
      path = fetchurl {
        name = "has_flag___has_flag_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-flag/-/has-flag-4.0.0.tgz";
        sha1 = "944771fd9c81c81265c4d6941860da06bb59479b";
      };
    }

    {
      name = "has_gulplog___has_gulplog_0.1.0.tgz";
      path = fetchurl {
        name = "has_gulplog___has_gulplog_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/has-gulplog/-/has-gulplog-0.1.0.tgz";
        sha1 = "6414c82913697da51590397dafb12f22967811ce";
      };
    }

    {
      name = "has_unicode___has_unicode_2.0.1.tgz";
      path = fetchurl {
        name = "has_unicode___has_unicode_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/has-unicode/-/has-unicode-2.0.1.tgz";
        sha1 = "e0e6fe6a28cf51138855e086d1691e771de2a8b9";
      };
    }

    {
      name = "has_value___has_value_0.3.1.tgz";
      path = fetchurl {
        name = "has_value___has_value_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/has-value/-/has-value-0.3.1.tgz";
        sha1 = "7b1f58bada62ca827ec0a2078025654845995e1f";
      };
    }

    {
      name = "has_value___has_value_1.0.0.tgz";
      path = fetchurl {
        name = "has_value___has_value_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-value/-/has-value-1.0.0.tgz";
        sha1 = "18b281da585b1c5c51def24c930ed29a0be6b177";
      };
    }

    {
      name = "has_values___has_values_0.1.4.tgz";
      path = fetchurl {
        name = "has_values___has_values_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/has-values/-/has-values-0.1.4.tgz";
        sha1 = "6d61de95d91dfca9b9a02089ad384bff8f62b771";
      };
    }

    {
      name = "has_values___has_values_1.0.0.tgz";
      path = fetchurl {
        name = "has_values___has_values_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-values/-/has-values-1.0.0.tgz";
        sha1 = "95b0b63fec2146619a6fe57fe75628d5a39efe4f";
      };
    }

    {
      name = "has___has_1.0.3.tgz";
      path = fetchurl {
        name = "has___has_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/has/-/has-1.0.3.tgz";
        sha1 = "722d7cbfc1f6aa8241f16dd814e011e1f41e8796";
      };
    }

    {
      name = "hawk___hawk_1.1.1.tgz";
      path = fetchurl {
        name = "hawk___hawk_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/hawk/-/hawk-1.1.1.tgz";
        sha1 = "87cd491f9b46e4e2aeaca335416766885d2d1ed9";
      };
    }

    {
      name = "hawk___hawk_1.0.0.tgz";
      path = fetchurl {
        name = "hawk___hawk_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/hawk/-/hawk-1.0.0.tgz";
        sha1 = "b90bb169807285411da7ffcb8dd2598502d3b52d";
      };
    }

    {
      name = "hoek___hoek_0.9.1.tgz";
      path = fetchurl {
        name = "hoek___hoek_0.9.1.tgz";
        url  = "https://registry.yarnpkg.com/hoek/-/hoek-0.9.1.tgz";
        sha1 = "3d322462badf07716ea7eb85baf88079cddce505";
      };
    }

    {
      name = "homedir_polyfill___homedir_polyfill_1.0.3.tgz";
      path = fetchurl {
        name = "homedir_polyfill___homedir_polyfill_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/homedir-polyfill/-/homedir-polyfill-1.0.3.tgz";
        sha1 = "743298cef4e5af3e194161fbadcc2151d3a058e8";
      };
    }

    {
      name = "hosted_git_info___hosted_git_info_2.8.8.tgz";
      path = fetchurl {
        name = "hosted_git_info___hosted_git_info_2.8.8.tgz";
        url  = "https://registry.yarnpkg.com/hosted-git-info/-/hosted-git-info-2.8.8.tgz";
        sha1 = "7539bd4bc1e0e0a895815a2e0262420b12858488";
      };
    }

    {
      name = "http_browserify___http_browserify_1.3.2.tgz";
      path = fetchurl {
        name = "http_browserify___http_browserify_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/http-browserify/-/http-browserify-1.3.2.tgz";
        sha1 = "b562c34479349a690d7a6597df495aefa8c604f5";
      };
    }

    {
      name = "http_errors___http_errors_1.7.2.tgz";
      path = fetchurl {
        name = "http_errors___http_errors_1.7.2.tgz";
        url  = "https://registry.yarnpkg.com/http-errors/-/http-errors-1.7.2.tgz";
        sha1 = "4f5029cf13239f31036e5b2e55292bcfbcc85c8f";
      };
    }

    {
      name = "http_errors___http_errors_1.3.1.tgz";
      path = fetchurl {
        name = "http_errors___http_errors_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/http-errors/-/http-errors-1.3.1.tgz";
        sha1 = "197e22cdebd4198585e8694ef6786197b91ed942";
      };
    }

    {
      name = "http_parser_js___http_parser_js_0.4.10.tgz";
      path = fetchurl {
        name = "http_parser_js___http_parser_js_0.4.10.tgz";
        url  = "https://registry.yarnpkg.com/http-parser-js/-/http-parser-js-0.4.10.tgz";
        sha1 = "92c9c1374c35085f75db359ec56cc257cbb93fa4";
      };
    }

    {
      name = "http_proxy___http_proxy_1.18.0.tgz";
      path = fetchurl {
        name = "http_proxy___http_proxy_1.18.0.tgz";
        url  = "https://registry.yarnpkg.com/http-proxy/-/http-proxy-1.18.0.tgz";
        sha1 = "dbe55f63e75a347db7f3d99974f2692a314a6a3a";
      };
    }

    {
      name = "http_signature___http_signature_0.10.1.tgz";
      path = fetchurl {
        name = "http_signature___http_signature_0.10.1.tgz";
        url  = "https://registry.yarnpkg.com/http-signature/-/http-signature-0.10.1.tgz";
        sha1 = "4fbdac132559aa8323121e540779c0a012b27e66";
      };
    }

    {
      name = "http_signature___http_signature_1.2.0.tgz";
      path = fetchurl {
        name = "http_signature___http_signature_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/http-signature/-/http-signature-1.2.0.tgz";
        sha1 = "9aecd925114772f3d95b65a60abb8f7c18fbace1";
      };
    }

    {
      name = "https_browserify___https_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "https_browserify___https_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/https-browserify/-/https-browserify-0.0.1.tgz";
        sha1 = "3f91365cabe60b77ed0ebba24b454e3e09d95a82";
      };
    }

    {
      name = "iconv_lite___iconv_lite_0.4.13.tgz";
      path = fetchurl {
        name = "iconv_lite___iconv_lite_0.4.13.tgz";
        url  = "https://registry.yarnpkg.com/iconv-lite/-/iconv-lite-0.4.13.tgz";
        sha1 = "1f88aba4ab0b1508e8312acc39345f36e992e2f2";
      };
    }

    {
      name = "iconv_lite___iconv_lite_0.4.24.tgz";
      path = fetchurl {
        name = "iconv_lite___iconv_lite_0.4.24.tgz";
        url  = "https://registry.yarnpkg.com/iconv-lite/-/iconv-lite-0.4.24.tgz";
        sha1 = "2022b4b25fbddc21d2f524974a474aafe733908b";
      };
    }

    {
      name = "ieee754___ieee754_1.1.13.tgz";
      path = fetchurl {
        name = "ieee754___ieee754_1.1.13.tgz";
        url  = "https://registry.yarnpkg.com/ieee754/-/ieee754-1.1.13.tgz";
        sha1 = "ec168558e95aa181fd87d37f55c32bbcb6708b84";
      };
    }

    {
      name = "ignore_walk___ignore_walk_3.0.3.tgz";
      path = fetchurl {
        name = "ignore_walk___ignore_walk_3.0.3.tgz";
        url  = "https://registry.yarnpkg.com/ignore-walk/-/ignore-walk-3.0.3.tgz";
        sha1 = "017e2447184bfeade7c238e4aefdd1e8f95b1e37";
      };
    }

    {
      name = "in_publish___in_publish_2.0.1.tgz";
      path = fetchurl {
        name = "in_publish___in_publish_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/in-publish/-/in-publish-2.0.1.tgz";
        sha1 = "948b1a535c8030561cea522f73f78f4be357e00c";
      };
    }

    {
      name = "indent_string___indent_string_2.1.0.tgz";
      path = fetchurl {
        name = "indent_string___indent_string_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/indent-string/-/indent-string-2.1.0.tgz";
        sha1 = "8e2d48348742121b4a8218b7a137e9a52049dc80";
      };
    }

    {
      name = "indexof___indexof_0.0.1.tgz";
      path = fetchurl {
        name = "indexof___indexof_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/indexof/-/indexof-0.0.1.tgz";
        sha1 = "82dc336d232b9062179d05ab3293a66059fd435d";
      };
    }

    {
      name = "infinity_agent___infinity_agent_2.0.3.tgz";
      path = fetchurl {
        name = "infinity_agent___infinity_agent_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/infinity-agent/-/infinity-agent-2.0.3.tgz";
        sha1 = "45e0e2ff7a9eb030b27d62b74b3744b7a7ac4216";
      };
    }

    {
      name = "inflight___inflight_1.0.6.tgz";
      path = fetchurl {
        name = "inflight___inflight_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/inflight/-/inflight-1.0.6.tgz";
        sha1 = "49bd6331d7d02d0c09bc910a1075ba8165b56df9";
      };
    }

    {
      name = "inherits___inherits_1.0.2.tgz";
      path = fetchurl {
        name = "inherits___inherits_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-1.0.2.tgz";
        sha1 = "ca4309dadee6b54cc0b8d247e8d7c7a0975bdc9b";
      };
    }

    {
      name = "inherits___inherits_2.0.4.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.4.tgz";
        sha1 = "0fa2c64f932917c3433a0ded55363aae37416b7c";
      };
    }

    {
      name = "inherits___inherits_2.0.1.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.1.tgz";
        sha1 = "b17d08d326b4423e568eff719f91b0b1cbdf69f1";
      };
    }

    {
      name = "inherits___inherits_2.0.3.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.3.tgz";
        sha1 = "633c2c83e3da42a502f52466022480f4208261de";
      };
    }

    {
      name = "ini___ini_1.3.5.tgz";
      path = fetchurl {
        name = "ini___ini_1.3.5.tgz";
        url  = "https://registry.yarnpkg.com/ini/-/ini-1.3.5.tgz";
        sha1 = "eee25f56db1c9ec6085e0c22778083f596abf927";
      };
    }

    {
      name = "inline_source_map___inline_source_map_0.3.1.tgz";
      path = fetchurl {
        name = "inline_source_map___inline_source_map_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/inline-source-map/-/inline-source-map-0.3.1.tgz";
        sha1 = "a528b514e689fce90db3089e870d92f527acb5eb";
      };
    }

    {
      name = "inquirer___inquirer_0.4.1.tgz";
      path = fetchurl {
        name = "inquirer___inquirer_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/inquirer/-/inquirer-0.4.1.tgz";
        sha1 = "6cf74eb1a347f97a1a207bea8ad1c987d0ff4b81";
      };
    }

    {
      name = "inquirer___inquirer_0.5.1.tgz";
      path = fetchurl {
        name = "inquirer___inquirer_0.5.1.tgz";
        url  = "https://registry.yarnpkg.com/inquirer/-/inquirer-0.5.1.tgz";
        sha1 = "e9f2cd1ee172c7a32e054b78a03d4ddb0d7707f1";
      };
    }

    {
      name = "insert_module_globals___insert_module_globals_6.0.0.tgz";
      path = fetchurl {
        name = "insert_module_globals___insert_module_globals_6.0.0.tgz";
        url  = "https://registry.yarnpkg.com/insert-module-globals/-/insert-module-globals-6.0.0.tgz";
        sha1 = "ee8aeb9dee16819e33aa14588a558824af0c15dc";
      };
    }

    {
      name = "insight___insight_0.3.1.tgz";
      path = fetchurl {
        name = "insight___insight_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/insight/-/insight-0.3.1.tgz";
        sha1 = "1a14f32c06115c0850338c38a253d707b611d448";
      };
    }

    {
      name = "interpret___interpret_1.2.0.tgz";
      path = fetchurl {
        name = "interpret___interpret_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/interpret/-/interpret-1.2.0.tgz";
        sha1 = "d5061a6224be58e8083985f5014d844359576296";
      };
    }

    {
      name = "intersect___intersect_0.0.3.tgz";
      path = fetchurl {
        name = "intersect___intersect_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/intersect/-/intersect-0.0.3.tgz";
        sha1 = "c1a4a5e5eac6ede4af7504cc07e0ada7bc9f4920";
      };
    }

    {
      name = "invert_kv___invert_kv_1.0.0.tgz";
      path = fetchurl {
        name = "invert_kv___invert_kv_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/invert-kv/-/invert-kv-1.0.0.tgz";
        sha1 = "104a8e4aaca6d3d8cd157a8ef8bfab2d7a3ffdb6";
      };
    }

    {
      name = "is_absolute___is_absolute_1.0.0.tgz";
      path = fetchurl {
        name = "is_absolute___is_absolute_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-absolute/-/is-absolute-1.0.0.tgz";
        sha1 = "395e1ae84b11f26ad1795e73c17378e48a301576";
      };
    }

    {
      name = "is_accessor_descriptor___is_accessor_descriptor_0.1.6.tgz";
      path = fetchurl {
        name = "is_accessor_descriptor___is_accessor_descriptor_0.1.6.tgz";
        url  = "https://registry.yarnpkg.com/is-accessor-descriptor/-/is-accessor-descriptor-0.1.6.tgz";
        sha1 = "a9e12cb3ae8d876727eeef3843f8a0897b5c98d6";
      };
    }

    {
      name = "is_accessor_descriptor___is_accessor_descriptor_1.0.0.tgz";
      path = fetchurl {
        name = "is_accessor_descriptor___is_accessor_descriptor_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-accessor-descriptor/-/is-accessor-descriptor-1.0.0.tgz";
        sha1 = "169c2f6d3df1f992618072365c9b0ea1f6878656";
      };
    }

    {
      name = "is_arrayish___is_arrayish_0.2.1.tgz";
      path = fetchurl {
        name = "is_arrayish___is_arrayish_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/is-arrayish/-/is-arrayish-0.2.1.tgz";
        sha1 = "77c99840527aa8ecb1a8ba697b80645a7a926a9d";
      };
    }

    {
      name = "is_binary_path___is_binary_path_1.0.1.tgz";
      path = fetchurl {
        name = "is_binary_path___is_binary_path_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/is-binary-path/-/is-binary-path-1.0.1.tgz";
        sha1 = "75f16642b480f187a711c814161fd3a4a7655898";
      };
    }

    {
      name = "is_buffer___is_buffer_1.1.6.tgz";
      path = fetchurl {
        name = "is_buffer___is_buffer_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/is-buffer/-/is-buffer-1.1.6.tgz";
        sha1 = "efaa2ea9daa0d7ab2ea13a97b2b8ad51fefbe8be";
      };
    }

    {
      name = "is_data_descriptor___is_data_descriptor_0.1.4.tgz";
      path = fetchurl {
        name = "is_data_descriptor___is_data_descriptor_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/is-data-descriptor/-/is-data-descriptor-0.1.4.tgz";
        sha1 = "0b5ee648388e2c860282e793f1856fec3f301b56";
      };
    }

    {
      name = "is_data_descriptor___is_data_descriptor_1.0.0.tgz";
      path = fetchurl {
        name = "is_data_descriptor___is_data_descriptor_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-data-descriptor/-/is-data-descriptor-1.0.0.tgz";
        sha1 = "d84876321d0e7add03990406abbbbd36ba9268c7";
      };
    }

    {
      name = "is_descriptor___is_descriptor_0.1.6.tgz";
      path = fetchurl {
        name = "is_descriptor___is_descriptor_0.1.6.tgz";
        url  = "https://registry.yarnpkg.com/is-descriptor/-/is-descriptor-0.1.6.tgz";
        sha1 = "366d8240dde487ca51823b1ab9f07a10a78251ca";
      };
    }

    {
      name = "is_descriptor___is_descriptor_1.0.2.tgz";
      path = fetchurl {
        name = "is_descriptor___is_descriptor_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/is-descriptor/-/is-descriptor-1.0.2.tgz";
        sha1 = "3b159746a66604b04f8c81524ba365c5f14d86ec";
      };
    }

    {
      name = "is_dotfile___is_dotfile_1.0.3.tgz";
      path = fetchurl {
        name = "is_dotfile___is_dotfile_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/is-dotfile/-/is-dotfile-1.0.3.tgz";
        sha1 = "a6a2f32ffd2dfb04f5ca25ecd0f6b83cf798a1e1";
      };
    }

    {
      name = "is_equal_shallow___is_equal_shallow_0.1.3.tgz";
      path = fetchurl {
        name = "is_equal_shallow___is_equal_shallow_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/is-equal-shallow/-/is-equal-shallow-0.1.3.tgz";
        sha1 = "2238098fc221de0bcfa5d9eac4c45d638aa1c534";
      };
    }

    {
      name = "is_expression___is_expression_3.0.0.tgz";
      path = fetchurl {
        name = "is_expression___is_expression_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-expression/-/is-expression-3.0.0.tgz";
        sha1 = "39acaa6be7fd1f3471dc42c7416e61c24317ac9f";
      };
    }

    {
      name = "is_extendable___is_extendable_0.1.1.tgz";
      path = fetchurl {
        name = "is_extendable___is_extendable_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/is-extendable/-/is-extendable-0.1.1.tgz";
        sha1 = "62b110e289a471418e3ec36a617d472e301dfc89";
      };
    }

    {
      name = "is_extendable___is_extendable_1.0.1.tgz";
      path = fetchurl {
        name = "is_extendable___is_extendable_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/is-extendable/-/is-extendable-1.0.1.tgz";
        sha1 = "a7470f9e426733d81bd81e1155264e3a3507cab4";
      };
    }

    {
      name = "is_extglob___is_extglob_1.0.0.tgz";
      path = fetchurl {
        name = "is_extglob___is_extglob_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-extglob/-/is-extglob-1.0.0.tgz";
        sha1 = "ac468177c4943405a092fc8f29760c6ffc6206c0";
      };
    }

    {
      name = "is_extglob___is_extglob_2.1.1.tgz";
      path = fetchurl {
        name = "is_extglob___is_extglob_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/is-extglob/-/is-extglob-2.1.1.tgz";
        sha1 = "a88c02535791f02ed37c76a1b9ea9773c833f8c2";
      };
    }

    {
      name = "is_finite___is_finite_1.1.0.tgz";
      path = fetchurl {
        name = "is_finite___is_finite_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-finite/-/is-finite-1.1.0.tgz";
        sha1 = "904135c77fb42c0641d6aa1bcdbc4daa8da082f3";
      };
    }

    {
      name = "is_fullwidth_code_point___is_fullwidth_code_point_1.0.0.tgz";
      path = fetchurl {
        name = "is_fullwidth_code_point___is_fullwidth_code_point_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-fullwidth-code-point/-/is-fullwidth-code-point-1.0.0.tgz";
        sha1 = "ef9e31386f031a7f0d643af82fde50c457ef00cb";
      };
    }

    {
      name = "is_fullwidth_code_point___is_fullwidth_code_point_2.0.0.tgz";
      path = fetchurl {
        name = "is_fullwidth_code_point___is_fullwidth_code_point_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-fullwidth-code-point/-/is-fullwidth-code-point-2.0.0.tgz";
        sha1 = "a3b30a5c4f199183167aaab93beefae3ddfb654f";
      };
    }

    {
      name = "is_glob___is_glob_2.0.1.tgz";
      path = fetchurl {
        name = "is_glob___is_glob_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/is-glob/-/is-glob-2.0.1.tgz";
        sha1 = "d096f926a3ded5600f3fdfd91198cb0888c2d863";
      };
    }

    {
      name = "is_glob___is_glob_3.1.0.tgz";
      path = fetchurl {
        name = "is_glob___is_glob_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-glob/-/is-glob-3.1.0.tgz";
        sha1 = "7ba5ae24217804ac70707b96922567486cc3e84a";
      };
    }

    {
      name = "is_npm___is_npm_1.0.0.tgz";
      path = fetchurl {
        name = "is_npm___is_npm_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-npm/-/is-npm-1.0.0.tgz";
        sha1 = "f2fb63a65e4905b406c86072765a1a4dc793b9f4";
      };
    }

    {
      name = "is_number___is_number_0.1.1.tgz";
      path = fetchurl {
        name = "is_number___is_number_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/is-number/-/is-number-0.1.1.tgz";
        sha1 = "69a7af116963d47206ec9bd9b48a14216f1e3806";
      };
    }

    {
      name = "is_number___is_number_2.1.0.tgz";
      path = fetchurl {
        name = "is_number___is_number_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-number/-/is-number-2.1.0.tgz";
        sha1 = "01fcbbb393463a548f2f466cce16dece49db908f";
      };
    }

    {
      name = "is_number___is_number_3.0.0.tgz";
      path = fetchurl {
        name = "is_number___is_number_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-number/-/is-number-3.0.0.tgz";
        sha1 = "24fd6201a4782cf50561c810276afc7d12d71195";
      };
    }

    {
      name = "is_number___is_number_4.0.0.tgz";
      path = fetchurl {
        name = "is_number___is_number_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-number/-/is-number-4.0.0.tgz";
        sha1 = "0026e37f5454d73e356dfe6564699867c6a7f0ff";
      };
    }

    {
      name = "is_plain_object___is_plain_object_2.0.4.tgz";
      path = fetchurl {
        name = "is_plain_object___is_plain_object_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/is-plain-object/-/is-plain-object-2.0.4.tgz";
        sha1 = "2c163b3fafb1b606d9d17928f05c2a1c38e07677";
      };
    }

    {
      name = "is_posix_bracket___is_posix_bracket_0.1.1.tgz";
      path = fetchurl {
        name = "is_posix_bracket___is_posix_bracket_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/is-posix-bracket/-/is-posix-bracket-0.1.1.tgz";
        sha1 = "3334dc79774368e92f016e6fbc0a88f5cd6e6bc4";
      };
    }

    {
      name = "is_primitive___is_primitive_2.0.0.tgz";
      path = fetchurl {
        name = "is_primitive___is_primitive_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-primitive/-/is-primitive-2.0.0.tgz";
        sha1 = "207bab91638499c07b2adf240a41a87210034575";
      };
    }

    {
      name = "is_promise___is_promise_2.1.0.tgz";
      path = fetchurl {
        name = "is_promise___is_promise_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-promise/-/is-promise-2.1.0.tgz";
        sha1 = "79a2a9ece7f096e80f36d2b2f3bc16c1ff4bf3fa";
      };
    }

    {
      name = "is_redirect___is_redirect_1.0.0.tgz";
      path = fetchurl {
        name = "is_redirect___is_redirect_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-redirect/-/is-redirect-1.0.0.tgz";
        sha1 = "1d03dded53bd8db0f30c26e4f95d36fc7c87dc24";
      };
    }

    {
      name = "is_regex___is_regex_1.0.5.tgz";
      path = fetchurl {
        name = "is_regex___is_regex_1.0.5.tgz";
        url  = "https://registry.yarnpkg.com/is-regex/-/is-regex-1.0.5.tgz";
        sha1 = "39d589a358bf18967f726967120b8fc1aed74eae";
      };
    }

    {
      name = "is_relative___is_relative_1.0.0.tgz";
      path = fetchurl {
        name = "is_relative___is_relative_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-relative/-/is-relative-1.0.0.tgz";
        sha1 = "a1bb6935ce8c5dba1e8b9754b9b2dcc020e2260d";
      };
    }

    {
      name = "is_root___is_root_0.1.0.tgz";
      path = fetchurl {
        name = "is_root___is_root_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-root/-/is-root-0.1.0.tgz";
        sha1 = "825e394ab593df2d73c5d0092fce507270b53dcb";
      };
    }

    {
      name = "is_stream___is_stream_1.1.0.tgz";
      path = fetchurl {
        name = "is_stream___is_stream_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/is-stream/-/is-stream-1.1.0.tgz";
        sha1 = "12d4a3dd4e68e0b79ceb8dbc84173ae80d91ca44";
      };
    }

    {
      name = "is_typedarray___is_typedarray_1.0.0.tgz";
      path = fetchurl {
        name = "is_typedarray___is_typedarray_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-typedarray/-/is-typedarray-1.0.0.tgz";
        sha1 = "e479c80858df0c1b11ddda6940f96011fcda4a9a";
      };
    }

    {
      name = "is_unc_path___is_unc_path_1.0.0.tgz";
      path = fetchurl {
        name = "is_unc_path___is_unc_path_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-unc-path/-/is-unc-path-1.0.0.tgz";
        sha1 = "d731e8898ed090a12c352ad2eaed5095ad322c9d";
      };
    }

    {
      name = "is_utf8___is_utf8_0.2.1.tgz";
      path = fetchurl {
        name = "is_utf8___is_utf8_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/is-utf8/-/is-utf8-0.2.1.tgz";
        sha1 = "4b0da1442104d1b336340e80797e865cf39f7d72";
      };
    }

    {
      name = "is_windows___is_windows_1.0.2.tgz";
      path = fetchurl {
        name = "is_windows___is_windows_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/is-windows/-/is-windows-1.0.2.tgz";
        sha1 = "d1850eb9791ecd18e6182ce12a30f396634bb19d";
      };
    }

    {
      name = "is___is_3.3.0.tgz";
      path = fetchurl {
        name = "is___is_3.3.0.tgz";
        url  = "https://registry.yarnpkg.com/is/-/is-3.3.0.tgz";
        sha1 = "61cff6dd3c4193db94a3d62582072b44e5645d79";
      };
    }

    {
      name = "isarray___isarray_0.0.1.tgz";
      path = fetchurl {
        name = "isarray___isarray_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/isarray/-/isarray-0.0.1.tgz";
        sha1 = "8a18acfca9a8f4177e09abfc6038939b05d1eedf";
      };
    }

    {
      name = "isarray___isarray_1.0.0.tgz";
      path = fetchurl {
        name = "isarray___isarray_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/isarray/-/isarray-1.0.0.tgz";
        sha1 = "bb935d48582cba168c06834957a54a3e07124f11";
      };
    }

    {
      name = "isbinaryfile___isbinaryfile_3.0.3.tgz";
      path = fetchurl {
        name = "isbinaryfile___isbinaryfile_3.0.3.tgz";
        url  = "https://registry.yarnpkg.com/isbinaryfile/-/isbinaryfile-3.0.3.tgz";
        sha1 = "5d6def3edebf6e8ca8cae9c30183a804b5f8be80";
      };
    }

    {
      name = "isexe___isexe_2.0.0.tgz";
      path = fetchurl {
        name = "isexe___isexe_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/isexe/-/isexe-2.0.0.tgz";
        sha1 = "e8fbf374dc556ff8947a10dcb0572d633f2cfa10";
      };
    }

    {
      name = "isobject___isobject_2.1.0.tgz";
      path = fetchurl {
        name = "isobject___isobject_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/isobject/-/isobject-2.1.0.tgz";
        sha1 = "f065561096a3f1da2ef46272f815c840d87e0c89";
      };
    }

    {
      name = "isobject___isobject_3.0.1.tgz";
      path = fetchurl {
        name = "isobject___isobject_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/isobject/-/isobject-3.0.1.tgz";
        sha1 = "4e431e92b11a9731636aa1f9c8d1ccbcfdab78df";
      };
    }

    {
      name = "isstream___isstream_0.1.2.tgz";
      path = fetchurl {
        name = "isstream___isstream_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/isstream/-/isstream-0.1.2.tgz";
        sha1 = "47e63f7af55afa6f92e1500e690eb8b8529c099a";
      };
    }

    {
      name = "istanbul___istanbul_0.4.5.tgz";
      path = fetchurl {
        name = "istanbul___istanbul_0.4.5.tgz";
        url  = "https://registry.yarnpkg.com/istanbul/-/istanbul-0.4.5.tgz";
        sha1 = "65c7d73d4c4da84d4f3ac310b918fb0b8033733b";
      };
    }

    {
      name = "istextorbinary___istextorbinary_1.0.2.tgz";
      path = fetchurl {
        name = "istextorbinary___istextorbinary_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/istextorbinary/-/istextorbinary-1.0.2.tgz";
        sha1 = "ace19354d1a9a0173efeb1084ce0f87b0ad7decf";
      };
    }

    {
      name = "jasmine_core___jasmine_core_2.99.1.tgz";
      path = fetchurl {
        name = "jasmine_core___jasmine_core_2.99.1.tgz";
        url  = "https://registry.yarnpkg.com/jasmine-core/-/jasmine-core-2.99.1.tgz";
        sha1 = "e6400df1e6b56e130b61c4bcd093daa7f6e8ca15";
      };
    }

    {
      name = "js_base64___js_base64_2.5.2.tgz";
      path = fetchurl {
        name = "js_base64___js_base64_2.5.2.tgz";
        url  = "https://registry.yarnpkg.com/js-base64/-/js-base64-2.5.2.tgz";
        sha1 = "313b6274dda718f714d00b3330bbae6e38e90209";
      };
    }

    {
      name = "js_string_escape___js_string_escape_1.0.1.tgz";
      path = fetchurl {
        name = "js_string_escape___js_string_escape_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/js-string-escape/-/js-string-escape-1.0.1.tgz";
        sha1 = "e2625badbc0d67c7533e9edc1068c587ae4137ef";
      };
    }

    {
      name = "js_stringify___js_stringify_1.0.2.tgz";
      path = fetchurl {
        name = "js_stringify___js_stringify_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/js-stringify/-/js-stringify-1.0.2.tgz";
        sha1 = "1736fddfd9724f28a3682adc6230ae7e4e9679db";
      };
    }

    {
      name = "js_yaml___js_yaml_3.13.1.tgz";
      path = fetchurl {
        name = "js_yaml___js_yaml_3.13.1.tgz";
        url  = "https://registry.yarnpkg.com/js-yaml/-/js-yaml-3.13.1.tgz";
        sha1 = "aff151b30bfdfa8e49e05da22e7415e9dfa37847";
      };
    }

    {
      name = "js_yaml___js_yaml_3.0.2.tgz";
      path = fetchurl {
        name = "js_yaml___js_yaml_3.0.2.tgz";
        url  = "https://registry.yarnpkg.com/js-yaml/-/js-yaml-3.0.2.tgz";
        sha1 = "9937865f8e897a5e894e73c2c5cf2e89b32eb771";
      };
    }

    {
      name = "jsbn___jsbn_0.1.1.tgz";
      path = fetchurl {
        name = "jsbn___jsbn_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/jsbn/-/jsbn-0.1.1.tgz";
        sha1 = "a5e654c2e5a2deb5f201d96cefbca80c0ef2f513";
      };
    }

    {
      name = "json_schema_traverse___json_schema_traverse_0.4.1.tgz";
      path = fetchurl {
        name = "json_schema_traverse___json_schema_traverse_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/json-schema-traverse/-/json-schema-traverse-0.4.1.tgz";
        sha1 = "69f6a87d9513ab8bb8fe63bdb0979c448e684660";
      };
    }

    {
      name = "json_schema___json_schema_0.2.3.tgz";
      path = fetchurl {
        name = "json_schema___json_schema_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/json-schema/-/json-schema-0.2.3.tgz";
        sha1 = "b480c892e59a2f05954ce727bd3f2a4e882f9e13";
      };
    }

    {
      name = "json_stringify_safe___json_stringify_safe_5.0.1.tgz";
      path = fetchurl {
        name = "json_stringify_safe___json_stringify_safe_5.0.1.tgz";
        url  = "https://registry.yarnpkg.com/json-stringify-safe/-/json-stringify-safe-5.0.1.tgz";
        sha1 = "1296a2d58fd45f19a0f6ce01d65701e2c735b6eb";
      };
    }

    {
      name = "json3___json3_3.3.2.tgz";
      path = fetchurl {
        name = "json3___json3_3.3.2.tgz";
        url  = "https://registry.yarnpkg.com/json3/-/json3-3.3.2.tgz";
        sha1 = "3c0434743df93e2f5c42aee7b19bcb483575f4e1";
      };
    }

    {
      name = "jsonify___jsonify_0.0.0.tgz";
      path = fetchurl {
        name = "jsonify___jsonify_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/jsonify/-/jsonify-0.0.0.tgz";
        sha1 = "2c74b6ee41d93ca51b7b5aaee8f503631d252a73";
      };
    }

    {
      name = "jsonparse___jsonparse_0.0.5.tgz";
      path = fetchurl {
        name = "jsonparse___jsonparse_0.0.5.tgz";
        url  = "https://registry.yarnpkg.com/jsonparse/-/jsonparse-0.0.5.tgz";
        sha1 = "330542ad3f0a654665b778f3eb2d9a9fa507ac64";
      };
    }

    {
      name = "jsprim___jsprim_1.4.1.tgz";
      path = fetchurl {
        name = "jsprim___jsprim_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/jsprim/-/jsprim-1.4.1.tgz";
        sha1 = "313e66bc1e5cc06e438bc1b7499c2e5c56acb6a2";
      };
    }

    {
      name = "jstransformer___jstransformer_1.0.0.tgz";
      path = fetchurl {
        name = "jstransformer___jstransformer_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/jstransformer/-/jstransformer-1.0.0.tgz";
        sha1 = "ed8bf0921e2f3f1ed4d5c1a44f68709ed24722c3";
      };
    }

    {
      name = "junk___junk_0.3.0.tgz";
      path = fetchurl {
        name = "junk___junk_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/junk/-/junk-0.3.0.tgz";
        sha1 = "6c89c636f6e99898d8efbfc50430db40be71e10c";
      };
    }

    {
      name = "karma_chrome_launcher___karma_chrome_launcher_2.1.1.tgz";
      path = fetchurl {
        name = "karma_chrome_launcher___karma_chrome_launcher_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/karma-chrome-launcher/-/karma-chrome-launcher-2.1.1.tgz";
        sha1 = "216879c68ac04d8d5140e99619ba04b59afd46cf";
      };
    }

    {
      name = "karma_coffee_preprocessor___karma_coffee_preprocessor_0.3.0.tgz";
      path = fetchurl {
        name = "karma_coffee_preprocessor___karma_coffee_preprocessor_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/karma-coffee-preprocessor/-/karma-coffee-preprocessor-0.3.0.tgz";
        sha1 = "a4d8dc2b145bfef458a203d308b63bc03c9b4259";
      };
    }

    {
      name = "karma_coverage___karma_coverage_0.5.5.tgz";
      path = fetchurl {
        name = "karma_coverage___karma_coverage_0.5.5.tgz";
        url  = "https://registry.yarnpkg.com/karma-coverage/-/karma-coverage-0.5.5.tgz";
        sha1 = "b0d58b1025d59d5c6620263186f1d58f5d5348c5";
      };
    }

    {
      name = "karma_jasmine___karma_jasmine_0.3.8.tgz";
      path = fetchurl {
        name = "karma_jasmine___karma_jasmine_0.3.8.tgz";
        url  = "https://registry.yarnpkg.com/karma-jasmine/-/karma-jasmine-0.3.8.tgz";
        sha1 = "5b6457791ad9b89aa173f079e3ebe1b8c805236c";
      };
    }

    {
      name = "karma_sourcemap_loader___karma_sourcemap_loader_0.3.7.tgz";
      path = fetchurl {
        name = "karma_sourcemap_loader___karma_sourcemap_loader_0.3.7.tgz";
        url  = "https://registry.yarnpkg.com/karma-sourcemap-loader/-/karma-sourcemap-loader-0.3.7.tgz";
        sha1 = "91322c77f8f13d46fed062b042e1009d4c4505d8";
      };
    }

    {
      name = "karma___karma_0.13.22.tgz";
      path = fetchurl {
        name = "karma___karma_0.13.22.tgz";
        url  = "https://registry.yarnpkg.com/karma/-/karma-0.13.22.tgz";
        sha1 = "07750b1bd063d7e7e7b91bcd2e6354d8f2aa8744";
      };
    }

    {
      name = "kind_of___kind_of_3.2.2.tgz";
      path = fetchurl {
        name = "kind_of___kind_of_3.2.2.tgz";
        url  = "https://registry.yarnpkg.com/kind-of/-/kind-of-3.2.2.tgz";
        sha1 = "31ea21a734bab9bbb0f32466d893aea51e4a3c64";
      };
    }

    {
      name = "kind_of___kind_of_4.0.0.tgz";
      path = fetchurl {
        name = "kind_of___kind_of_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/kind-of/-/kind-of-4.0.0.tgz";
        sha1 = "20813df3d712928b207378691a45066fae72dd57";
      };
    }

    {
      name = "kind_of___kind_of_5.1.0.tgz";
      path = fetchurl {
        name = "kind_of___kind_of_5.1.0.tgz";
        url  = "https://registry.yarnpkg.com/kind-of/-/kind-of-5.1.0.tgz";
        sha1 = "729c91e2d857b7a419a1f9aa65685c4c33f5845d";
      };
    }

    {
      name = "kind_of___kind_of_6.0.3.tgz";
      path = fetchurl {
        name = "kind_of___kind_of_6.0.3.tgz";
        url  = "https://registry.yarnpkg.com/kind-of/-/kind-of-6.0.3.tgz";
        sha1 = "07c05034a6c349fa06e24fa35aa76db4580ce4dd";
      };
    }

    {
      name = "latest_version___latest_version_1.0.1.tgz";
      path = fetchurl {
        name = "latest_version___latest_version_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/latest-version/-/latest-version-1.0.1.tgz";
        sha1 = "72cfc46e3e8d1be651e1ebb54ea9f6ea96f374bb";
      };
    }

    {
      name = "lazy_cache___lazy_cache_1.0.4.tgz";
      path = fetchurl {
        name = "lazy_cache___lazy_cache_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/lazy-cache/-/lazy-cache-1.0.4.tgz";
        sha1 = "a1d78fc3a50474cb80845d3b3b6e1da49a446e8e";
      };
    }

    {
      name = "lazypipe___lazypipe_1.0.2.tgz";
      path = fetchurl {
        name = "lazypipe___lazypipe_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/lazypipe/-/lazypipe-1.0.2.tgz";
        sha1 = "b66f64ed7fd8b04869f1f1bcb795dbbaa80e418c";
      };
    }

    {
      name = "lcid___lcid_1.0.0.tgz";
      path = fetchurl {
        name = "lcid___lcid_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lcid/-/lcid-1.0.0.tgz";
        sha1 = "308accafa0bc483a3867b4b6f2b9506251d1b835";
      };
    }

    {
      name = "less___less_1.7.5.tgz";
      path = fetchurl {
        name = "less___less_1.7.5.tgz";
        url  = "https://registry.yarnpkg.com/less/-/less-1.7.5.tgz";
        sha1 = "4f220cf7288a27eaca739df6e4808a2d4c0d5756";
      };
    }

    {
      name = "levn___levn_0.3.0.tgz";
      path = fetchurl {
        name = "levn___levn_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/levn/-/levn-0.3.0.tgz";
        sha1 = "3b09924edf9f083c0490fdd4c0bc4421e04764ee";
      };
    }

    {
      name = "lexical_scope___lexical_scope_1.1.1.tgz";
      path = fetchurl {
        name = "lexical_scope___lexical_scope_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/lexical-scope/-/lexical-scope-1.1.1.tgz";
        sha1 = "debac1067435f1359d90fcfd9e94bcb2ee47b2bf";
      };
    }

    {
      name = "liftoff___liftoff_2.5.0.tgz";
      path = fetchurl {
        name = "liftoff___liftoff_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/liftoff/-/liftoff-2.5.0.tgz";
        sha1 = "2009291bb31cea861bbf10a7c15a28caf75c31ec";
      };
    }

    {
      name = "livereload_js___livereload_js_2.4.0.tgz";
      path = fetchurl {
        name = "livereload_js___livereload_js_2.4.0.tgz";
        url  = "https://registry.yarnpkg.com/livereload-js/-/livereload-js-2.4.0.tgz";
        sha1 = "447c31cf1ea9ab52fc20db615c5ddf678f78009c";
      };
    }

    {
      name = "load_json_file___load_json_file_1.1.0.tgz";
      path = fetchurl {
        name = "load_json_file___load_json_file_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/load-json-file/-/load-json-file-1.1.0.tgz";
        sha1 = "956905708d58b4bab4c2261b04f59f31c99374c0";
      };
    }

    {
      name = "lockfile___lockfile_0.4.3.tgz";
      path = fetchurl {
        name = "lockfile___lockfile_0.4.3.tgz";
        url  = "https://registry.yarnpkg.com/lockfile/-/lockfile-0.4.3.tgz";
        sha1 = "79b965ee9b32d9dd24b59cf81205e6dcb6d3b224";
      };
    }

    {
      name = "lodash._baseassign___lodash._baseassign_3.2.0.tgz";
      path = fetchurl {
        name = "lodash._baseassign___lodash._baseassign_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash._baseassign/-/lodash._baseassign-3.2.0.tgz";
        sha1 = "8c38a099500f215ad09e59f1722fd0c52bfe0a4e";
      };
    }

    {
      name = "lodash._basecopy___lodash._basecopy_3.0.1.tgz";
      path = fetchurl {
        name = "lodash._basecopy___lodash._basecopy_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._basecopy/-/lodash._basecopy-3.0.1.tgz";
        sha1 = "8da0e6a876cf344c0ad8a54882111dd3c5c7ca36";
      };
    }

    {
      name = "lodash._basetostring___lodash._basetostring_3.0.1.tgz";
      path = fetchurl {
        name = "lodash._basetostring___lodash._basetostring_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._basetostring/-/lodash._basetostring-3.0.1.tgz";
        sha1 = "d1861d877f824a52f669832dcaf3ee15566a07d5";
      };
    }

    {
      name = "lodash._basevalues___lodash._basevalues_3.0.0.tgz";
      path = fetchurl {
        name = "lodash._basevalues___lodash._basevalues_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash._basevalues/-/lodash._basevalues-3.0.0.tgz";
        sha1 = "5b775762802bde3d3297503e26300820fdf661b7";
      };
    }

    {
      name = "lodash._bindcallback___lodash._bindcallback_3.0.1.tgz";
      path = fetchurl {
        name = "lodash._bindcallback___lodash._bindcallback_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._bindcallback/-/lodash._bindcallback-3.0.1.tgz";
        sha1 = "e531c27644cf8b57a99e17ed95b35c748789392e";
      };
    }

    {
      name = "lodash._createassigner___lodash._createassigner_3.1.1.tgz";
      path = fetchurl {
        name = "lodash._createassigner___lodash._createassigner_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._createassigner/-/lodash._createassigner-3.1.1.tgz";
        sha1 = "838a5bae2fdaca63ac22dee8e19fa4e6d6970b11";
      };
    }

    {
      name = "lodash._escapehtmlchar___lodash._escapehtmlchar_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._escapehtmlchar___lodash._escapehtmlchar_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._escapehtmlchar/-/lodash._escapehtmlchar-2.4.1.tgz";
        sha1 = "df67c3bb6b7e8e1e831ab48bfa0795b92afe899d";
      };
    }

    {
      name = "lodash._escapestringchar___lodash._escapestringchar_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._escapestringchar___lodash._escapestringchar_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._escapestringchar/-/lodash._escapestringchar-2.4.1.tgz";
        sha1 = "ecfe22618a2ade50bfeea43937e51df66f0edb72";
      };
    }

    {
      name = "lodash._getnative___lodash._getnative_3.9.1.tgz";
      path = fetchurl {
        name = "lodash._getnative___lodash._getnative_3.9.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._getnative/-/lodash._getnative-3.9.1.tgz";
        sha1 = "570bc7dede46d61cdcde687d65d3eecbaa3aaff5";
      };
    }

    {
      name = "lodash._htmlescapes___lodash._htmlescapes_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._htmlescapes___lodash._htmlescapes_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._htmlescapes/-/lodash._htmlescapes-2.4.1.tgz";
        sha1 = "32d14bf0844b6de6f8b62a051b4f67c228b624cb";
      };
    }

    {
      name = "lodash._isiterateecall___lodash._isiterateecall_3.0.9.tgz";
      path = fetchurl {
        name = "lodash._isiterateecall___lodash._isiterateecall_3.0.9.tgz";
        url  = "https://registry.yarnpkg.com/lodash._isiterateecall/-/lodash._isiterateecall-3.0.9.tgz";
        sha1 = "5203ad7ba425fae842460e696db9cf3e6aac057c";
      };
    }

    {
      name = "lodash._isnative___lodash._isnative_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._isnative___lodash._isnative_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._isnative/-/lodash._isnative-2.4.1.tgz";
        sha1 = "3ea6404b784a7be836c7b57580e1cdf79b14832c";
      };
    }

    {
      name = "lodash._objecttypes___lodash._objecttypes_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._objecttypes___lodash._objecttypes_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._objecttypes/-/lodash._objecttypes-2.4.1.tgz";
        sha1 = "7c0b7f69d98a1f76529f890b0cdb1b4dfec11c11";
      };
    }

    {
      name = "lodash._reescape___lodash._reescape_3.0.0.tgz";
      path = fetchurl {
        name = "lodash._reescape___lodash._reescape_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash._reescape/-/lodash._reescape-3.0.0.tgz";
        sha1 = "2b1d6f5dfe07c8a355753e5f27fac7f1cde1616a";
      };
    }

    {
      name = "lodash._reevaluate___lodash._reevaluate_3.0.0.tgz";
      path = fetchurl {
        name = "lodash._reevaluate___lodash._reevaluate_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash._reevaluate/-/lodash._reevaluate-3.0.0.tgz";
        sha1 = "58bc74c40664953ae0b124d806996daca431e2ed";
      };
    }

    {
      name = "lodash._reinterpolate___lodash._reinterpolate_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._reinterpolate___lodash._reinterpolate_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._reinterpolate/-/lodash._reinterpolate-2.4.1.tgz";
        sha1 = "4f1227aa5a8711fc632f5b07a1f4607aab8b3222";
      };
    }

    {
      name = "lodash._reinterpolate___lodash._reinterpolate_3.0.0.tgz";
      path = fetchurl {
        name = "lodash._reinterpolate___lodash._reinterpolate_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash._reinterpolate/-/lodash._reinterpolate-3.0.0.tgz";
        sha1 = "0ccf2d89166af03b3663c796538b75ac6e114d9d";
      };
    }

    {
      name = "lodash._reunescapedhtml___lodash._reunescapedhtml_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._reunescapedhtml___lodash._reunescapedhtml_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._reunescapedhtml/-/lodash._reunescapedhtml-2.4.1.tgz";
        sha1 = "747c4fc40103eb3bb8a0976e571f7a2659e93ba7";
      };
    }

    {
      name = "lodash._root___lodash._root_3.0.1.tgz";
      path = fetchurl {
        name = "lodash._root___lodash._root_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._root/-/lodash._root-3.0.1.tgz";
        sha1 = "fba1c4524c19ee9a5f8136b4609f017cf4ded692";
      };
    }

    {
      name = "lodash._shimkeys___lodash._shimkeys_2.4.1.tgz";
      path = fetchurl {
        name = "lodash._shimkeys___lodash._shimkeys_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash._shimkeys/-/lodash._shimkeys-2.4.1.tgz";
        sha1 = "6e9cc9666ff081f0b5a6c978b83e242e6949d203";
      };
    }

    {
      name = "lodash.assign___lodash.assign_4.2.0.tgz";
      path = fetchurl {
        name = "lodash.assign___lodash.assign_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.assign/-/lodash.assign-4.2.0.tgz";
        sha1 = "0d99f3ccd7a6d261d19bdaeb9245005d285808e7";
      };
    }

    {
      name = "lodash.assign___lodash.assign_3.2.0.tgz";
      path = fetchurl {
        name = "lodash.assign___lodash.assign_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.assign/-/lodash.assign-3.2.0.tgz";
        sha1 = "3ce9f0234b4b2223e296b8fa0ac1fee8ebca64fa";
      };
    }

    {
      name = "lodash.clonedeep___lodash.clonedeep_4.5.0.tgz";
      path = fetchurl {
        name = "lodash.clonedeep___lodash.clonedeep_4.5.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.clonedeep/-/lodash.clonedeep-4.5.0.tgz";
        sha1 = "e23f3f9c4f8fbdde872529c1071857a086e5ccef";
      };
    }

    {
      name = "lodash.debounce___lodash.debounce_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.debounce___lodash.debounce_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.debounce/-/lodash.debounce-2.4.1.tgz";
        sha1 = "d8cead246ec4b926e8b85678fc396bfeba8cc6fc";
      };
    }

    {
      name = "lodash.defaults___lodash.defaults_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.defaults___lodash.defaults_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.defaults/-/lodash.defaults-2.4.1.tgz";
        sha1 = "a7e8885f05e68851144b6e12a8f3678026bc4c54";
      };
    }

    {
      name = "lodash.defaults___lodash.defaults_4.2.0.tgz";
      path = fetchurl {
        name = "lodash.defaults___lodash.defaults_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.defaults/-/lodash.defaults-4.2.0.tgz";
        sha1 = "d09178716ffea4dde9e5fb7b37f6f0802274580c";
      };
    }

    {
      name = "lodash.escape___lodash.escape_3.2.0.tgz";
      path = fetchurl {
        name = "lodash.escape___lodash.escape_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.escape/-/lodash.escape-3.2.0.tgz";
        sha1 = "995ee0dc18c1b48cc92effae71a10aab5b487698";
      };
    }

    {
      name = "lodash.escape___lodash.escape_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.escape___lodash.escape_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.escape/-/lodash.escape-2.4.1.tgz";
        sha1 = "2ce12c5e084db0a57dda5e5d1eeeb9f5d175a3b4";
      };
    }

    {
      name = "lodash.isarguments___lodash.isarguments_3.1.0.tgz";
      path = fetchurl {
        name = "lodash.isarguments___lodash.isarguments_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.isarguments/-/lodash.isarguments-3.1.0.tgz";
        sha1 = "2f573d85c6a24289ff00663b491c1d338ff3458a";
      };
    }

    {
      name = "lodash.isarray___lodash.isarray_3.0.4.tgz";
      path = fetchurl {
        name = "lodash.isarray___lodash.isarray_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/lodash.isarray/-/lodash.isarray-3.0.4.tgz";
        sha1 = "79e4eb88c36a8122af86f844aa9bcd851b5fbb55";
      };
    }

    {
      name = "lodash.isfunction___lodash.isfunction_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.isfunction___lodash.isfunction_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.isfunction/-/lodash.isfunction-2.4.1.tgz";
        sha1 = "2cfd575c73e498ab57e319b77fa02adef13a94d1";
      };
    }

    {
      name = "lodash.isobject___lodash.isobject_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.isobject___lodash.isobject_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.isobject/-/lodash.isobject-2.4.1.tgz";
        sha1 = "5a2e47fe69953f1ee631a7eba1fe64d2d06558f5";
      };
    }

    {
      name = "lodash.keys___lodash.keys_3.1.2.tgz";
      path = fetchurl {
        name = "lodash.keys___lodash.keys_3.1.2.tgz";
        url  = "https://registry.yarnpkg.com/lodash.keys/-/lodash.keys-3.1.2.tgz";
        sha1 = "4dbc0472b156be50a0b286855d1bd0b0c656098a";
      };
    }

    {
      name = "lodash.keys___lodash.keys_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.keys___lodash.keys_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.keys/-/lodash.keys-2.4.1.tgz";
        sha1 = "48dea46df8ff7632b10d706b8acb26591e2b3727";
      };
    }

    {
      name = "lodash.now___lodash.now_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.now___lodash.now_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.now/-/lodash.now-2.4.1.tgz";
        sha1 = "6872156500525185faf96785bb7fe7fe15b562c6";
      };
    }

    {
      name = "lodash.restparam___lodash.restparam_3.6.1.tgz";
      path = fetchurl {
        name = "lodash.restparam___lodash.restparam_3.6.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.restparam/-/lodash.restparam-3.6.1.tgz";
        sha1 = "936a4e309ef330a7645ed4145986c85ae5b20805";
      };
    }

    {
      name = "lodash.template___lodash.template_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.template___lodash.template_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.template/-/lodash.template-2.4.1.tgz";
        sha1 = "9e611007edf629129a974ab3c48b817b3e1cf20d";
      };
    }

    {
      name = "lodash.template___lodash.template_3.6.2.tgz";
      path = fetchurl {
        name = "lodash.template___lodash.template_3.6.2.tgz";
        url  = "https://registry.yarnpkg.com/lodash.template/-/lodash.template-3.6.2.tgz";
        sha1 = "f8cdecc6169a255be9098ae8b0c53d378931d14f";
      };
    }

    {
      name = "lodash.template___lodash.template_4.5.0.tgz";
      path = fetchurl {
        name = "lodash.template___lodash.template_4.5.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.template/-/lodash.template-4.5.0.tgz";
        sha1 = "f976195cf3f347d0d5f52483569fe8031ccce8ab";
      };
    }

    {
      name = "lodash.templatesettings___lodash.templatesettings_3.1.1.tgz";
      path = fetchurl {
        name = "lodash.templatesettings___lodash.templatesettings_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.templatesettings/-/lodash.templatesettings-3.1.1.tgz";
        sha1 = "fb307844753b66b9f1afa54e262c745307dba8e5";
      };
    }

    {
      name = "lodash.templatesettings___lodash.templatesettings_4.2.0.tgz";
      path = fetchurl {
        name = "lodash.templatesettings___lodash.templatesettings_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/lodash.templatesettings/-/lodash.templatesettings-4.2.0.tgz";
        sha1 = "e481310f049d3cf6d47e912ad09313b154f0fb33";
      };
    }

    {
      name = "lodash.templatesettings___lodash.templatesettings_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.templatesettings___lodash.templatesettings_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.templatesettings/-/lodash.templatesettings-2.4.1.tgz";
        sha1 = "ea76c75d11eb86d4dbe89a83893bb861929ac699";
      };
    }

    {
      name = "lodash.values___lodash.values_2.4.1.tgz";
      path = fetchurl {
        name = "lodash.values___lodash.values_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash.values/-/lodash.values-2.4.1.tgz";
        sha1 = "abf514436b3cb705001627978cbcf30b1280eea4";
      };
    }

    {
      name = "lodash___lodash_2.4.2.tgz";
      path = fetchurl {
        name = "lodash___lodash_2.4.2.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-2.4.2.tgz";
        sha1 = "fadd834b9683073da179b3eae6d9c0d15053f73e";
      };
    }

    {
      name = "lodash___lodash_3.10.1.tgz";
      path = fetchurl {
        name = "lodash___lodash_3.10.1.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-3.10.1.tgz";
        sha1 = "5bf45e8e49ba4189e17d482789dfd15bd140b7b6";
      };
    }

    {
      name = "lodash___lodash_4.17.15.tgz";
      path = fetchurl {
        name = "lodash___lodash_4.17.15.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-4.17.15.tgz";
        sha1 = "b447f6670a0455bbfeedd11392eff330ea097548";
      };
    }

    {
      name = "lodash___lodash_1.0.2.tgz";
      path = fetchurl {
        name = "lodash___lodash_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-1.0.2.tgz";
        sha1 = "8f57560c83b59fc270bd3d561b690043430e2551";
      };
    }

    {
      name = "log4js___log4js_0.6.38.tgz";
      path = fetchurl {
        name = "log4js___log4js_0.6.38.tgz";
        url  = "https://registry.yarnpkg.com/log4js/-/log4js-0.6.38.tgz";
        sha1 = "2c494116695d6fb25480943d3fc872e662a522fd";
      };
    }

    {
      name = "longest___longest_1.0.1.tgz";
      path = fetchurl {
        name = "longest___longest_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/longest/-/longest-1.0.1.tgz";
        sha1 = "30a0b2da38f73770e8294a0d22e6625ed77d0097";
      };
    }

    {
      name = "loophole___loophole_1.1.0.tgz";
      path = fetchurl {
        name = "loophole___loophole_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/loophole/-/loophole-1.1.0.tgz";
        sha1 = "37949fea453b6256acc725c320ce0c5a7f70a2bd";
      };
    }

    {
      name = "loud_rejection___loud_rejection_1.6.0.tgz";
      path = fetchurl {
        name = "loud_rejection___loud_rejection_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/loud-rejection/-/loud-rejection-1.6.0.tgz";
        sha1 = "5b46f80147edee578870f086d04821cf998e551f";
      };
    }

    {
      name = "lowercase_keys___lowercase_keys_1.0.1.tgz";
      path = fetchurl {
        name = "lowercase_keys___lowercase_keys_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/lowercase-keys/-/lowercase-keys-1.0.1.tgz";
        sha1 = "6f9e30b47084d971a7c820ff15a6c5167b74c26f";
      };
    }

    {
      name = "lru_cache___lru_cache_2.7.3.tgz";
      path = fetchurl {
        name = "lru_cache___lru_cache_2.7.3.tgz";
        url  = "https://registry.yarnpkg.com/lru-cache/-/lru-cache-2.7.3.tgz";
        sha1 = "6d4524e8b955f95d4f5b58851ce21dd72fb4e952";
      };
    }

    {
      name = "lru_cache___lru_cache_4.1.5.tgz";
      path = fetchurl {
        name = "lru_cache___lru_cache_4.1.5.tgz";
        url  = "https://registry.yarnpkg.com/lru-cache/-/lru-cache-4.1.5.tgz";
        sha1 = "8bbe50ea85bed59bc9e33dcab8235ee9bcf443cd";
      };
    }

    {
      name = "lru_cache___lru_cache_2.3.1.tgz";
      path = fetchurl {
        name = "lru_cache___lru_cache_2.3.1.tgz";
        url  = "https://registry.yarnpkg.com/lru-cache/-/lru-cache-2.3.1.tgz";
        sha1 = "b3adf6b3d856e954e2c390e6cef22081245a53d6";
      };
    }

    {
      name = "lru_cache___lru_cache_2.5.2.tgz";
      path = fetchurl {
        name = "lru_cache___lru_cache_2.5.2.tgz";
        url  = "https://registry.yarnpkg.com/lru-cache/-/lru-cache-2.5.2.tgz";
        sha1 = "1fddad938aae1263ce138680be1b3f591c0ab41c";
      };
    }

    {
      name = "lru_queue___lru_queue_0.1.0.tgz";
      path = fetchurl {
        name = "lru_queue___lru_queue_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/lru-queue/-/lru-queue-0.1.0.tgz";
        sha1 = "2738bd9f0d3cf4f84490c5736c48699ac632cda3";
      };
    }

    {
      name = "make_iterator___make_iterator_1.0.1.tgz";
      path = fetchurl {
        name = "make_iterator___make_iterator_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/make-iterator/-/make-iterator-1.0.1.tgz";
        sha1 = "29b33f312aa8f547c4a5e490f56afcec99133ad6";
      };
    }

    {
      name = "map_cache___map_cache_0.2.2.tgz";
      path = fetchurl {
        name = "map_cache___map_cache_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/map-cache/-/map-cache-0.2.2.tgz";
        sha1 = "c32abd0bd6525d9b051645bb4f26ac5dc98a0dbf";
      };
    }

    {
      name = "map_obj___map_obj_1.0.1.tgz";
      path = fetchurl {
        name = "map_obj___map_obj_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/map-obj/-/map-obj-1.0.1.tgz";
        sha1 = "d933ceb9205d82bdcf4886f6742bdc2b4dea146d";
      };
    }

    {
      name = "map_stream___map_stream_0.0.7.tgz";
      path = fetchurl {
        name = "map_stream___map_stream_0.0.7.tgz";
        url  = "https://registry.yarnpkg.com/map-stream/-/map-stream-0.0.7.tgz";
        sha1 = "8a1f07896d82b10926bd3744a2420009f88974a8";
      };
    }

    {
      name = "map_stream___map_stream_0.1.0.tgz";
      path = fetchurl {
        name = "map_stream___map_stream_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/map-stream/-/map-stream-0.1.0.tgz";
        sha1 = "e56aa94c4c8055a16404a0674b78f215f7c8e194";
      };
    }

    {
      name = "map_visit___map_visit_1.0.0.tgz";
      path = fetchurl {
        name = "map_visit___map_visit_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/map-visit/-/map-visit-1.0.0.tgz";
        sha1 = "ecdca8f13144e660f1b5bd41f12f3479d98dfb8f";
      };
    }

    {
      name = "math_random___math_random_1.0.4.tgz";
      path = fetchurl {
        name = "math_random___math_random_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/math-random/-/math-random-1.0.4.tgz";
        sha1 = "5dd6943c938548267016d4e34f057583080c514c";
      };
    }

    {
      name = "media_typer___media_typer_0.3.0.tgz";
      path = fetchurl {
        name = "media_typer___media_typer_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/media-typer/-/media-typer-0.3.0.tgz";
        sha1 = "8710d7af0aa626f8fffa1ce00168545263255748";
      };
    }

    {
      name = "memoizee___memoizee_0.2.6.tgz";
      path = fetchurl {
        name = "memoizee___memoizee_0.2.6.tgz";
        url  = "https://registry.yarnpkg.com/memoizee/-/memoizee-0.2.6.tgz";
        sha1 = "bb45a7ad02530082f1612671dab35219cd2e0741";
      };
    }

    {
      name = "memoizee___memoizee_0.3.10.tgz";
      path = fetchurl {
        name = "memoizee___memoizee_0.3.10.tgz";
        url  = "https://registry.yarnpkg.com/memoizee/-/memoizee-0.3.10.tgz";
        sha1 = "4eca0d8aed39ec9d017f4c5c2f2f6432f42e5c8f";
      };
    }

    {
      name = "meow___meow_3.7.0.tgz";
      path = fetchurl {
        name = "meow___meow_3.7.0.tgz";
        url  = "https://registry.yarnpkg.com/meow/-/meow-3.7.0.tgz";
        sha1 = "72cb668b425228290abbfa856892587308a801fb";
      };
    }

    {
      name = "merge_stream___merge_stream_1.0.1.tgz";
      path = fetchurl {
        name = "merge_stream___merge_stream_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/merge-stream/-/merge-stream-1.0.1.tgz";
        sha1 = "4041202d508a342ba00174008df0c251b8c135e1";
      };
    }

    {
      name = "merge___merge_1.2.1.tgz";
      path = fetchurl {
        name = "merge___merge_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/merge/-/merge-1.2.1.tgz";
        sha1 = "38bebf80c3220a8a487b6fcfb3941bb11720c145";
      };
    }

    {
      name = "micromatch___micromatch_2.3.11.tgz";
      path = fetchurl {
        name = "micromatch___micromatch_2.3.11.tgz";
        url  = "https://registry.yarnpkg.com/micromatch/-/micromatch-2.3.11.tgz";
        sha1 = "86677c97d1720b363431d04d0d15293bd38c1565";
      };
    }

    {
      name = "micromatch___micromatch_3.1.10.tgz";
      path = fetchurl {
        name = "micromatch___micromatch_3.1.10.tgz";
        url  = "https://registry.yarnpkg.com/micromatch/-/micromatch-3.1.10.tgz";
        sha1 = "70859bc95c9840952f359a068a3fc49f9ecfac23";
      };
    }

    {
      name = "mime_db___mime_db_1.43.0.tgz";
      path = fetchurl {
        name = "mime_db___mime_db_1.43.0.tgz";
        url  = "https://registry.yarnpkg.com/mime-db/-/mime-db-1.43.0.tgz";
        sha1 = "0a12e0502650e473d735535050e7c8f4eb4fae58";
      };
    }

    {
      name = "mime_db___mime_db_1.12.0.tgz";
      path = fetchurl {
        name = "mime_db___mime_db_1.12.0.tgz";
        url  = "https://registry.yarnpkg.com/mime-db/-/mime-db-1.12.0.tgz";
        sha1 = "3d0c63180f458eb10d325aaa37d7c58ae312e9d7";
      };
    }

    {
      name = "mime_types___mime_types_2.1.26.tgz";
      path = fetchurl {
        name = "mime_types___mime_types_2.1.26.tgz";
        url  = "https://registry.yarnpkg.com/mime-types/-/mime-types-2.1.26.tgz";
        sha1 = "9c921fc09b7e149a65dfdc0da4d20997200b0a06";
      };
    }

    {
      name = "mime_types___mime_types_1.0.2.tgz";
      path = fetchurl {
        name = "mime_types___mime_types_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/mime-types/-/mime-types-1.0.2.tgz";
        sha1 = "995ae1392ab8affcbfcb2641dd054e943c0d5dce";
      };
    }

    {
      name = "mime_types___mime_types_2.0.14.tgz";
      path = fetchurl {
        name = "mime_types___mime_types_2.0.14.tgz";
        url  = "https://registry.yarnpkg.com/mime-types/-/mime-types-2.0.14.tgz";
        sha1 = "310e159db23e077f8bb22b748dabfa4957140aa6";
      };
    }

    {
      name = "mime___mime_1.3.4.tgz";
      path = fetchurl {
        name = "mime___mime_1.3.4.tgz";
        url  = "https://registry.yarnpkg.com/mime/-/mime-1.3.4.tgz";
        sha1 = "115f9e3b6b3daf2959983cb38f149a2d40eb5d53";
      };
    }

    {
      name = "mime___mime_1.6.0.tgz";
      path = fetchurl {
        name = "mime___mime_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/mime/-/mime-1.6.0.tgz";
        sha1 = "32cd9e5c64553bd58d19a568af452acff04981b1";
      };
    }

    {
      name = "mime___mime_1.2.11.tgz";
      path = fetchurl {
        name = "mime___mime_1.2.11.tgz";
        url  = "https://registry.yarnpkg.com/mime/-/mime-1.2.11.tgz";
        sha1 = "58203eed86e3a5ef17aed2b7d9ebd47f0a60dd10";
      };
    }

    {
      name = "mini_lr___mini_lr_0.1.9.tgz";
      path = fetchurl {
        name = "mini_lr___mini_lr_0.1.9.tgz";
        url  = "https://registry.yarnpkg.com/mini-lr/-/mini-lr-0.1.9.tgz";
        sha1 = "02199d27347953d1fd1d6dbded4261f187b2d0f6";
      };
    }

    {
      name = "minimatch___minimatch_0.3.0.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-0.3.0.tgz";
        sha1 = "275d8edaac4f1bb3326472089e7949c8394699dd";
      };
    }

    {
      name = "minimatch___minimatch_3.0.4.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-3.0.4.tgz";
        sha1 = "5166e286457f03306064be5497e8dbb0c3d32083";
      };
    }

    {
      name = "minimatch___minimatch_0.2.14.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_0.2.14.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-0.2.14.tgz";
        sha1 = "c74e780574f63c6f9a090e90efbe6ef53a6a756a";
      };
    }

    {
      name = "minimatch___minimatch_1.0.0.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-1.0.0.tgz";
        sha1 = "e0dd2120b49e1b724ce8d714c520822a9438576d";
      };
    }

    {
      name = "minimatch___minimatch_2.0.10.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_2.0.10.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-2.0.10.tgz";
        sha1 = "8d087c39c6b38c001b97fca7ce6d0e1e80afbac7";
      };
    }

    {
      name = "minimist___minimist_0.2.1.tgz";
      path = fetchurl {
        name = "minimist___minimist_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/minimist/-/minimist-0.2.1.tgz";
        sha1 = "827ba4e7593464e7c221e8c5bed930904ee2c455";
      };
    }

    {
      name = "minimist___minimist_1.2.5.tgz";
      path = fetchurl {
        name = "minimist___minimist_1.2.5.tgz";
        url  = "https://registry.yarnpkg.com/minimist/-/minimist-1.2.5.tgz";
        sha1 = "67d66014b66a6a8aaa0c083c5fd58df4e4e97602";
      };
    }

    {
      name = "minimist___minimist_0.0.10.tgz";
      path = fetchurl {
        name = "minimist___minimist_0.0.10.tgz";
        url  = "https://registry.yarnpkg.com/minimist/-/minimist-0.0.10.tgz";
        sha1 = "de3f98543dbf96082be48ad1a0c7cda836301dcf";
      };
    }

    {
      name = "minipass___minipass_2.9.0.tgz";
      path = fetchurl {
        name = "minipass___minipass_2.9.0.tgz";
        url  = "https://registry.yarnpkg.com/minipass/-/minipass-2.9.0.tgz";
        sha1 = "e713762e7d3e32fed803115cf93e04bca9fcc9a6";
      };
    }

    {
      name = "minizlib___minizlib_1.3.3.tgz";
      path = fetchurl {
        name = "minizlib___minizlib_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/minizlib/-/minizlib-1.3.3.tgz";
        sha1 = "2290de96818a34c29551c8a8d301216bd65a861d";
      };
    }

    {
      name = "mixin_deep___mixin_deep_1.3.2.tgz";
      path = fetchurl {
        name = "mixin_deep___mixin_deep_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/mixin-deep/-/mixin-deep-1.3.2.tgz";
        sha1 = "1120b43dc359a785dce65b55b82e257ccf479566";
      };
    }

    {
      name = "mkdirp___mkdirp_0.5.4.tgz";
      path = fetchurl {
        name = "mkdirp___mkdirp_0.5.4.tgz";
        url  = "https://registry.yarnpkg.com/mkdirp/-/mkdirp-0.5.4.tgz";
        sha1 = "fd01504a6797ec5c9be81ff43d204961ed64a512";
      };
    }

    {
      name = "mkdirp___mkdirp_0.3.5.tgz";
      path = fetchurl {
        name = "mkdirp___mkdirp_0.3.5.tgz";
        url  = "https://registry.yarnpkg.com/mkdirp/-/mkdirp-0.3.5.tgz";
        sha1 = "de3e5f8961c88c787ee1368df849ac4413eca8d7";
      };
    }

    {
      name = "mkpath___mkpath_0.1.0.tgz";
      path = fetchurl {
        name = "mkpath___mkpath_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/mkpath/-/mkpath-0.1.0.tgz";
        sha1 = "7554a6f8d871834cc97b5462b122c4c124d6de91";
      };
    }

    {
      name = "module_deps___module_deps_2.0.6.tgz";
      path = fetchurl {
        name = "module_deps___module_deps_2.0.6.tgz";
        url  = "https://registry.yarnpkg.com/module-deps/-/module-deps-2.0.6.tgz";
        sha1 = "b999321c73ac33580f00712c0f3075fdca42563f";
      };
    }

    {
      name = "mout___mout_0.9.1.tgz";
      path = fetchurl {
        name = "mout___mout_0.9.1.tgz";
        url  = "https://registry.yarnpkg.com/mout/-/mout-0.9.1.tgz";
        sha1 = "84f0f3fd6acc7317f63de2affdcc0cee009b0477";
      };
    }

    {
      name = "ms___ms_0.7.1.tgz";
      path = fetchurl {
        name = "ms___ms_0.7.1.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-0.7.1.tgz";
        sha1 = "9cd13c03adbff25b65effde7ce864ee952017098";
      };
    }

    {
      name = "ms___ms_0.7.2.tgz";
      path = fetchurl {
        name = "ms___ms_0.7.2.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-0.7.2.tgz";
        sha1 = "ae25cf2512b3885a1d95d7f037868d8431124765";
      };
    }

    {
      name = "ms___ms_2.0.0.tgz";
      path = fetchurl {
        name = "ms___ms_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-2.0.0.tgz";
        sha1 = "5608aeadfc00be6c2901df5f9861788de0d597c8";
      };
    }

    {
      name = "ms___ms_2.1.2.tgz";
      path = fetchurl {
        name = "ms___ms_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-2.1.2.tgz";
        sha1 = "d09d1f357b443f493382a8eb3ccd183872ae6009";
      };
    }

    {
      name = "multipipe___multipipe_0.1.2.tgz";
      path = fetchurl {
        name = "multipipe___multipipe_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/multipipe/-/multipipe-0.1.2.tgz";
        sha1 = "2a8f2ddf70eed564dff2d57f1e1a137d9f05078b";
      };
    }

    {
      name = "mute_stream___mute_stream_0.0.4.tgz";
      path = fetchurl {
        name = "mute_stream___mute_stream_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/mute-stream/-/mute-stream-0.0.4.tgz";
        sha1 = "a9219960a6d5d5d046597aee51252c6655f7177e";
      };
    }

    {
      name = "mute_stream___mute_stream_0.0.8.tgz";
      path = fetchurl {
        name = "mute_stream___mute_stream_0.0.8.tgz";
        url  = "https://registry.yarnpkg.com/mute-stream/-/mute-stream-0.0.8.tgz";
        sha1 = "1630c42b2251ff81e2a283de96a5497ea92e5e0d";
      };
    }

    {
      name = "nan___nan_2.14.0.tgz";
      path = fetchurl {
        name = "nan___nan_2.14.0.tgz";
        url  = "https://registry.yarnpkg.com/nan/-/nan-2.14.0.tgz";
        sha1 = "7818f722027b2459a86f0295d434d1fc2336c52c";
      };
    }

    {
      name = "nanomatch___nanomatch_1.2.13.tgz";
      path = fetchurl {
        name = "nanomatch___nanomatch_1.2.13.tgz";
        url  = "https://registry.yarnpkg.com/nanomatch/-/nanomatch-1.2.13.tgz";
        sha1 = "b87a8aa4fc0de8fe6be88895b38983ff265bd119";
      };
    }

    {
      name = "natives___natives_1.1.6.tgz";
      path = fetchurl {
        name = "natives___natives_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/natives/-/natives-1.1.6.tgz";
        sha1 = "a603b4a498ab77173612b9ea1acdec4d980f00bb";
      };
    }

    {
      name = "needle___needle_2.3.3.tgz";
      path = fetchurl {
        name = "needle___needle_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/needle/-/needle-2.3.3.tgz";
        sha1 = "a041ad1d04a871b0ebb666f40baaf1fb47867117";
      };
    }

    {
      name = "negotiator___negotiator_0.6.1.tgz";
      path = fetchurl {
        name = "negotiator___negotiator_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/negotiator/-/negotiator-0.6.1.tgz";
        sha1 = "2b327184e8992101177b28563fb5e7102acd0ca9";
      };
    }

    {
      name = "neo_async___neo_async_2.6.1.tgz";
      path = fetchurl {
        name = "neo_async___neo_async_2.6.1.tgz";
        url  = "https://registry.yarnpkg.com/neo-async/-/neo-async-2.6.1.tgz";
        sha1 = "ac27ada66167fa8849a6addd837f6b189ad2081c";
      };
    }

    {
      name = "nested_error_stacks___nested_error_stacks_1.0.2.tgz";
      path = fetchurl {
        name = "nested_error_stacks___nested_error_stacks_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/nested-error-stacks/-/nested-error-stacks-1.0.2.tgz";
        sha1 = "19f619591519f096769a5ba9a86e6eeec823c3cf";
      };
    }

    {
      name = "next_tick___next_tick_0.1.0.tgz";
      path = fetchurl {
        name = "next_tick___next_tick_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/next-tick/-/next-tick-0.1.0.tgz";
        sha1 = "1912cce8eb9b697d640fbba94f8f00dec3b94259";
      };
    }

    {
      name = "next_tick___next_tick_1.1.0.tgz";
      path = fetchurl {
        name = "next_tick___next_tick_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/next-tick/-/next-tick-1.1.0.tgz";
        sha1 = "1836ee30ad56d67ef281b22bd199f709449b35eb";
      };
    }

    {
      name = "next_tick___next_tick_0.2.2.tgz";
      path = fetchurl {
        name = "next_tick___next_tick_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/next-tick/-/next-tick-0.2.2.tgz";
        sha1 = "75da4a927ee5887e39065880065b7336413b310d";
      };
    }

    {
      name = "next_tick___next_tick_1.0.0.tgz";
      path = fetchurl {
        name = "next_tick___next_tick_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/next-tick/-/next-tick-1.0.0.tgz";
        sha1 = "ca86d1fe8828169b0120208e3dc8424b9db8342c";
      };
    }

    {
      name = "ng_annotate___ng_annotate_1.2.2.tgz";
      path = fetchurl {
        name = "ng_annotate___ng_annotate_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/ng-annotate/-/ng-annotate-1.2.2.tgz";
        sha1 = "dc3fc51ba0b2f8b385dbe047f4da06f580a1fd61";
      };
    }

    {
      name = "ng_classify___ng_classify_4.1.1.tgz";
      path = fetchurl {
        name = "ng_classify___ng_classify_4.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ng-classify/-/ng-classify-4.1.1.tgz";
        sha1 = "6688b924c3c9b5f94da5f8fbc0d55176f3dda122";
      };
    }

    {
      name = "node_gyp___node_gyp_3.8.0.tgz";
      path = fetchurl {
        name = "node_gyp___node_gyp_3.8.0.tgz";
        url  = "https://registry.yarnpkg.com/node-gyp/-/node-gyp-3.8.0.tgz";
        sha1 = "540304261c330e80d0d5edce253a68cb3964218c";
      };
    }

    {
      name = "node_pre_gyp___node_pre_gyp_0.14.0.tgz";
      path = fetchurl {
        name = "node_pre_gyp___node_pre_gyp_0.14.0.tgz";
        url  = "https://registry.yarnpkg.com/node-pre-gyp/-/node-pre-gyp-0.14.0.tgz";
        sha1 = "9a0596533b877289bcad4e143982ca3d904ddc83";
      };
    }

    {
      name = "node_sass___node_sass_4.13.1.tgz";
      path = fetchurl {
        name = "node_sass___node_sass_4.13.1.tgz";
        url  = "https://registry.yarnpkg.com/node-sass/-/node-sass-4.13.1.tgz";
        sha1 = "9db5689696bb2eec2c32b98bfea4c7a2e992d0a3";
      };
    }

    {
      name = "node_uuid___node_uuid_1.4.8.tgz";
      path = fetchurl {
        name = "node_uuid___node_uuid_1.4.8.tgz";
        url  = "https://registry.yarnpkg.com/node-uuid/-/node-uuid-1.4.8.tgz";
        sha1 = "b040eb0923968afabf8d32fb1f17f1167fdab907";
      };
    }

    {
      name = "node.extend___node.extend_1.1.8.tgz";
      path = fetchurl {
        name = "node.extend___node.extend_1.1.8.tgz";
        url  = "https://registry.yarnpkg.com/node.extend/-/node.extend-1.1.8.tgz";
        sha1 = "0aab3e63789f4e6d68b42bc00073ad1881243cf0";
      };
    }

    {
      name = "nopt___nopt_3.0.6.tgz";
      path = fetchurl {
        name = "nopt___nopt_3.0.6.tgz";
        url  = "https://registry.yarnpkg.com/nopt/-/nopt-3.0.6.tgz";
        sha1 = "c6465dbf08abcd4db359317f79ac68a646b28ff9";
      };
    }

    {
      name = "nopt___nopt_4.0.3.tgz";
      path = fetchurl {
        name = "nopt___nopt_4.0.3.tgz";
        url  = "https://registry.yarnpkg.com/nopt/-/nopt-4.0.3.tgz";
        sha1 = "a375cad9d02fd921278d954c2254d5aa57e15e48";
      };
    }

    {
      name = "nopt___nopt_1.0.10.tgz";
      path = fetchurl {
        name = "nopt___nopt_1.0.10.tgz";
        url  = "https://registry.yarnpkg.com/nopt/-/nopt-1.0.10.tgz";
        sha1 = "6ddd21bd2a31417b92727dd585f8a6f37608ebee";
      };
    }

    {
      name = "nopt___nopt_2.2.1.tgz";
      path = fetchurl {
        name = "nopt___nopt_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/nopt/-/nopt-2.2.1.tgz";
        sha1 = "2aa09b7d1768487b3b89a9c5aa52335bff0baea7";
      };
    }

    {
      name = "normalize_package_data___normalize_package_data_2.5.0.tgz";
      path = fetchurl {
        name = "normalize_package_data___normalize_package_data_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/normalize-package-data/-/normalize-package-data-2.5.0.tgz";
        sha1 = "e66db1838b200c1dfc233225d12cb36520e234a8";
      };
    }

    {
      name = "normalize_path___normalize_path_2.1.1.tgz";
      path = fetchurl {
        name = "normalize_path___normalize_path_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/normalize-path/-/normalize-path-2.1.1.tgz";
        sha1 = "1ab28b556e198363a8c1a6f7e6fa20137fe6aed9";
      };
    }

    {
      name = "npm_bundled___npm_bundled_1.1.1.tgz";
      path = fetchurl {
        name = "npm_bundled___npm_bundled_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/npm-bundled/-/npm-bundled-1.1.1.tgz";
        sha1 = "1edd570865a94cdb1bc8220775e29466c9fb234b";
      };
    }

    {
      name = "npm_normalize_package_bin___npm_normalize_package_bin_1.0.1.tgz";
      path = fetchurl {
        name = "npm_normalize_package_bin___npm_normalize_package_bin_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/npm-normalize-package-bin/-/npm-normalize-package-bin-1.0.1.tgz";
        sha1 = "6e79a41f23fd235c0623218228da7d9c23b8f6e2";
      };
    }

    {
      name = "npm_packlist___npm_packlist_1.4.8.tgz";
      path = fetchurl {
        name = "npm_packlist___npm_packlist_1.4.8.tgz";
        url  = "https://registry.yarnpkg.com/npm-packlist/-/npm-packlist-1.4.8.tgz";
        sha1 = "56ee6cc135b9f98ad3d51c1c95da22bbb9b2ef3e";
      };
    }

    {
      name = "npmlog___npmlog_4.1.2.tgz";
      path = fetchurl {
        name = "npmlog___npmlog_4.1.2.tgz";
        url  = "https://registry.yarnpkg.com/npmlog/-/npmlog-4.1.2.tgz";
        sha1 = "08a7f2a8bf734604779a9efa4ad5cc717abb954b";
      };
    }

    {
      name = "null_check___null_check_1.0.0.tgz";
      path = fetchurl {
        name = "null_check___null_check_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/null-check/-/null-check-1.0.0.tgz";
        sha1 = "977dffd7176012b9ec30d2a39db5cf72a0439edd";
      };
    }

    {
      name = "number_is_nan___number_is_nan_1.0.1.tgz";
      path = fetchurl {
        name = "number_is_nan___number_is_nan_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/number-is-nan/-/number-is-nan-1.0.1.tgz";
        sha1 = "097b602b53422a522c1afb8790318336941a011d";
      };
    }

    {
      name = "oauth_sign___oauth_sign_0.3.0.tgz";
      path = fetchurl {
        name = "oauth_sign___oauth_sign_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/oauth-sign/-/oauth-sign-0.3.0.tgz";
        sha1 = "cb540f93bb2b22a7d5941691a288d60e8ea9386e";
      };
    }

    {
      name = "oauth_sign___oauth_sign_0.5.0.tgz";
      path = fetchurl {
        name = "oauth_sign___oauth_sign_0.5.0.tgz";
        url  = "https://registry.yarnpkg.com/oauth-sign/-/oauth-sign-0.5.0.tgz";
        sha1 = "d767f5169325620eab2e087ef0c472e773db6461";
      };
    }

    {
      name = "oauth_sign___oauth_sign_0.9.0.tgz";
      path = fetchurl {
        name = "oauth_sign___oauth_sign_0.9.0.tgz";
        url  = "https://registry.yarnpkg.com/oauth-sign/-/oauth-sign-0.9.0.tgz";
        sha1 = "47a7b016baa68b5fa0ecf3dee08a85c679ac6455";
      };
    }

    {
      name = "object_assign___object_assign_4.1.1.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_4.1.1.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-4.1.1.tgz";
        sha1 = "2109adc7965887cfc05cbbd442cac8bfbb360863";
      };
    }

    {
      name = "object_assign___object_assign_4.1.0.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_4.1.0.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-4.1.0.tgz";
        sha1 = "7a3b3d0e98063d43f4c03f2e8ae6cd51a86883a0";
      };
    }

    {
      name = "object_assign___object_assign_2.1.1.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-2.1.1.tgz";
        sha1 = "43c36e5d569ff8e4816c4efa8be02d26967c18aa";
      };
    }

    {
      name = "object_assign___object_assign_3.0.0.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-3.0.0.tgz";
        sha1 = "9bedd5ca0897949bca47e7ff408062d549f587f2";
      };
    }

    {
      name = "object_assign___object_assign_0.1.2.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-0.1.2.tgz";
        sha1 = "036992f073aff7b2db83d06b3fb3155a5ccac37f";
      };
    }

    {
      name = "object_component___object_component_0.0.3.tgz";
      path = fetchurl {
        name = "object_component___object_component_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/object-component/-/object-component-0.0.3.tgz";
        sha1 = "f0c69aa50efc95b866c186f400a33769cb2f1291";
      };
    }

    {
      name = "object_copy___object_copy_0.1.0.tgz";
      path = fetchurl {
        name = "object_copy___object_copy_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/object-copy/-/object-copy-0.1.0.tgz";
        sha1 = "7e7d858b781bd7c991a41ba975ed3812754e998c";
      };
    }

    {
      name = "object_keys___object_keys_0.4.0.tgz";
      path = fetchurl {
        name = "object_keys___object_keys_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/object-keys/-/object-keys-0.4.0.tgz";
        sha1 = "28a6aae7428dd2c3a92f3d95f21335dd204e0336";
      };
    }

    {
      name = "object_visit___object_visit_1.0.1.tgz";
      path = fetchurl {
        name = "object_visit___object_visit_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/object-visit/-/object-visit-1.0.1.tgz";
        sha1 = "f79c4493af0c5377b59fe39d395e41042dd045bb";
      };
    }

    {
      name = "object.defaults___object.defaults_1.1.0.tgz";
      path = fetchurl {
        name = "object.defaults___object.defaults_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/object.defaults/-/object.defaults-1.1.0.tgz";
        sha1 = "3a7f868334b407dea06da16d88d5cd29e435fecf";
      };
    }

    {
      name = "object.map___object.map_1.0.1.tgz";
      path = fetchurl {
        name = "object.map___object.map_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/object.map/-/object.map-1.0.1.tgz";
        sha1 = "cf83e59dc8fcc0ad5f4250e1f78b3b81bd801d37";
      };
    }

    {
      name = "object.omit___object.omit_2.0.1.tgz";
      path = fetchurl {
        name = "object.omit___object.omit_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/object.omit/-/object.omit-2.0.1.tgz";
        sha1 = "1a9c744829f39dbb858c76ca3579ae2a54ebd1fa";
      };
    }

    {
      name = "object.pick___object.pick_1.3.0.tgz";
      path = fetchurl {
        name = "object.pick___object.pick_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/object.pick/-/object.pick-1.3.0.tgz";
        sha1 = "87a10ac4c1694bd2e1cbf53591a66141fb5dd747";
      };
    }

    {
      name = "on_finished___on_finished_2.3.0.tgz";
      path = fetchurl {
        name = "on_finished___on_finished_2.3.0.tgz";
        url  = "https://registry.yarnpkg.com/on-finished/-/on-finished-2.3.0.tgz";
        sha1 = "20f1336481b083cd75337992a16971aa2d906947";
      };
    }

    {
      name = "once___once_1.4.0.tgz";
      path = fetchurl {
        name = "once___once_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/once/-/once-1.4.0.tgz";
        sha1 = "583b1aa775961d4b113ac17d9c50baef9dd76bd1";
      };
    }

    {
      name = "once___once_1.3.3.tgz";
      path = fetchurl {
        name = "once___once_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/once/-/once-1.3.3.tgz";
        sha1 = "b2e261557ce4c314ec8304f3fa82663e4297ca20";
      };
    }

    {
      name = "opn___opn_0.1.2.tgz";
      path = fetchurl {
        name = "opn___opn_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/opn/-/opn-0.1.2.tgz";
        sha1 = "c527832cfd964d52096b524d0035ecaece51db4f";
      };
    }

    {
      name = "optimist___optimist_0.6.1.tgz";
      path = fetchurl {
        name = "optimist___optimist_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/optimist/-/optimist-0.6.1.tgz";
        sha1 = "da3ea74686fa21a19a111c326e90eb15a0196686";
      };
    }

    {
      name = "optimist___optimist_0.3.7.tgz";
      path = fetchurl {
        name = "optimist___optimist_0.3.7.tgz";
        url  = "https://registry.yarnpkg.com/optimist/-/optimist-0.3.7.tgz";
        sha1 = "c90941ad59e4273328923074d2cf2e7cbc6ec0d9";
      };
    }

    {
      name = "optionator___optionator_0.8.3.tgz";
      path = fetchurl {
        name = "optionator___optionator_0.8.3.tgz";
        url  = "https://registry.yarnpkg.com/optionator/-/optionator-0.8.3.tgz";
        sha1 = "84fa1d036fe9d3c7e21d99884b601167ec8fb495";
      };
    }

    {
      name = "options___options_0.0.6.tgz";
      path = fetchurl {
        name = "options___options_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/options/-/options-0.0.6.tgz";
        sha1 = "ec22d312806bb53e731773e7cdaefcf1c643128f";
      };
    }

    {
      name = "orchestrator___orchestrator_0.3.8.tgz";
      path = fetchurl {
        name = "orchestrator___orchestrator_0.3.8.tgz";
        url  = "https://registry.yarnpkg.com/orchestrator/-/orchestrator-0.3.8.tgz";
        sha1 = "14e7e9e2764f7315fbac184e506c7aa6df94ad7e";
      };
    }

    {
      name = "ordered_ast_traverse___ordered_ast_traverse_1.1.1.tgz";
      path = fetchurl {
        name = "ordered_ast_traverse___ordered_ast_traverse_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ordered-ast-traverse/-/ordered-ast-traverse-1.1.1.tgz";
        sha1 = "6843a170bc0eee8b520cc8ddc1ddd3aa30fa057c";
      };
    }

    {
      name = "ordered_esprima_props___ordered_esprima_props_1.1.0.tgz";
      path = fetchurl {
        name = "ordered_esprima_props___ordered_esprima_props_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/ordered-esprima-props/-/ordered-esprima-props-1.1.0.tgz";
        sha1 = "a9827086df5f010aa60e9bd02b6e0335cea2ffcb";
      };
    }

    {
      name = "ordered_read_streams___ordered_read_streams_0.1.0.tgz";
      path = fetchurl {
        name = "ordered_read_streams___ordered_read_streams_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/ordered-read-streams/-/ordered-read-streams-0.1.0.tgz";
        sha1 = "fd565a9af8eb4473ba69b6ed8a34352cb552f126";
      };
    }

    {
      name = "os_browserify___os_browserify_0.1.2.tgz";
      path = fetchurl {
        name = "os_browserify___os_browserify_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/os-browserify/-/os-browserify-0.1.2.tgz";
        sha1 = "49ca0293e0b19590a5f5de10c7f265a617d8fe54";
      };
    }

    {
      name = "os_homedir___os_homedir_1.0.2.tgz";
      path = fetchurl {
        name = "os_homedir___os_homedir_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/os-homedir/-/os-homedir-1.0.2.tgz";
        sha1 = "ffbc4988336e0e833de0c168c7ef152121aa7fb3";
      };
    }

    {
      name = "os_locale___os_locale_1.4.0.tgz";
      path = fetchurl {
        name = "os_locale___os_locale_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/os-locale/-/os-locale-1.4.0.tgz";
        sha1 = "20f9f17ae29ed345e8bde583b13d2009803c14d9";
      };
    }

    {
      name = "os_tmpdir___os_tmpdir_1.0.2.tgz";
      path = fetchurl {
        name = "os_tmpdir___os_tmpdir_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/os-tmpdir/-/os-tmpdir-1.0.2.tgz";
        sha1 = "bbe67406c79aa85c5cfec766fe5734555dfa1274";
      };
    }

    {
      name = "osenv___osenv_0.1.5.tgz";
      path = fetchurl {
        name = "osenv___osenv_0.1.5.tgz";
        url  = "https://registry.yarnpkg.com/osenv/-/osenv-0.1.5.tgz";
        sha1 = "85cdfafaeb28e8677f416e287592b5f3f49ea410";
      };
    }

    {
      name = "osenv___osenv_0.0.3.tgz";
      path = fetchurl {
        name = "osenv___osenv_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/osenv/-/osenv-0.0.3.tgz";
        sha1 = "cd6ad8ddb290915ad9e22765576025d411f29cb6";
      };
    }

    {
      name = "p_throttler___p_throttler_0.0.1.tgz";
      path = fetchurl {
        name = "p_throttler___p_throttler_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/p-throttler/-/p-throttler-0.0.1.tgz";
        sha1 = "c341e3589ec843852a035e6f88e6c1e96150029b";
      };
    }

    {
      name = "package_json___package_json_1.2.0.tgz";
      path = fetchurl {
        name = "package_json___package_json_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/package-json/-/package-json-1.2.0.tgz";
        sha1 = "c8ecac094227cdf76a316874ed05e27cc939a0e0";
      };
    }

    {
      name = "pako___pako_0.2.9.tgz";
      path = fetchurl {
        name = "pako___pako_0.2.9.tgz";
        url  = "https://registry.yarnpkg.com/pako/-/pako-0.2.9.tgz";
        sha1 = "f3f7522f4ef782348da8161bad9ecfd51bf83a75";
      };
    }

    {
      name = "parents___parents_0.0.2.tgz";
      path = fetchurl {
        name = "parents___parents_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/parents/-/parents-0.0.2.tgz";
        sha1 = "67147826e497d40759aaf5ba4c99659b6034d302";
      };
    }

    {
      name = "parents___parents_0.0.3.tgz";
      path = fetchurl {
        name = "parents___parents_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/parents/-/parents-0.0.3.tgz";
        sha1 = "fa212f024d9fa6318dbb6b4ce676c8be493b9c43";
      };
    }

    {
      name = "parse_filepath___parse_filepath_1.0.2.tgz";
      path = fetchurl {
        name = "parse_filepath___parse_filepath_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/parse-filepath/-/parse-filepath-1.0.2.tgz";
        sha1 = "a632127f53aaf3d15876f5872f3ffac763d6c891";
      };
    }

    {
      name = "parse_glob___parse_glob_3.0.4.tgz";
      path = fetchurl {
        name = "parse_glob___parse_glob_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/parse-glob/-/parse-glob-3.0.4.tgz";
        sha1 = "b2c376cfb11f35513badd173ef0bb6e3a388391c";
      };
    }

    {
      name = "parse_json___parse_json_2.2.0.tgz";
      path = fetchurl {
        name = "parse_json___parse_json_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/parse-json/-/parse-json-2.2.0.tgz";
        sha1 = "f480f40434ef80741f8469099f8dea18f55a4dc9";
      };
    }

    {
      name = "parse_node_version___parse_node_version_1.0.1.tgz";
      path = fetchurl {
        name = "parse_node_version___parse_node_version_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/parse-node-version/-/parse-node-version-1.0.1.tgz";
        sha1 = "e2b5dbede00e7fa9bc363607f53327e8b073189b";
      };
    }

    {
      name = "parse_passwd___parse_passwd_1.0.0.tgz";
      path = fetchurl {
        name = "parse_passwd___parse_passwd_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/parse-passwd/-/parse-passwd-1.0.0.tgz";
        sha1 = "6d5b934a456993b23d37f40a382d6f1666a8e5c6";
      };
    }

    {
      name = "parsejson___parsejson_0.0.3.tgz";
      path = fetchurl {
        name = "parsejson___parsejson_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/parsejson/-/parsejson-0.0.3.tgz";
        sha1 = "ab7e3759f209ece99437973f7d0f1f64ae0e64ab";
      };
    }

    {
      name = "parseqs___parseqs_0.0.5.tgz";
      path = fetchurl {
        name = "parseqs___parseqs_0.0.5.tgz";
        url  = "https://registry.yarnpkg.com/parseqs/-/parseqs-0.0.5.tgz";
        sha1 = "d5208a3738e46766e291ba2ea173684921a8b89d";
      };
    }

    {
      name = "parseuri___parseuri_0.0.5.tgz";
      path = fetchurl {
        name = "parseuri___parseuri_0.0.5.tgz";
        url  = "https://registry.yarnpkg.com/parseuri/-/parseuri-0.0.5.tgz";
        sha1 = "80204a50d4dbb779bfdc6ebe2778d90e4bce320a";
      };
    }

    {
      name = "parseurl___parseurl_1.3.3.tgz";
      path = fetchurl {
        name = "parseurl___parseurl_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/parseurl/-/parseurl-1.3.3.tgz";
        sha1 = "9da19e7bee8d12dff0513ed5b76957793bc2e8d4";
      };
    }

    {
      name = "pascalcase___pascalcase_0.1.1.tgz";
      path = fetchurl {
        name = "pascalcase___pascalcase_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/pascalcase/-/pascalcase-0.1.1.tgz";
        sha1 = "b363e55e8006ca6fe21784d2db22bd15d7917f14";
      };
    }

    {
      name = "path_browserify___path_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "path_browserify___path_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-browserify/-/path-browserify-0.0.1.tgz";
        sha1 = "e6c4ddd7ed3aa27c68a20cc4e50e1a4ee83bbc4a";
      };
    }

    {
      name = "path_exists___path_exists_2.1.0.tgz";
      path = fetchurl {
        name = "path_exists___path_exists_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/path-exists/-/path-exists-2.1.0.tgz";
        sha1 = "0feb6c64f0fc518d9a754dd5efb62c7022761f4b";
      };
    }

    {
      name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
      path = fetchurl {
        name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
        sha1 = "174b9268735534ffbc7ace6bf53a5a9e1b5c5f5f";
      };
    }

    {
      name = "path_parse___path_parse_1.0.6.tgz";
      path = fetchurl {
        name = "path_parse___path_parse_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/path-parse/-/path-parse-1.0.6.tgz";
        sha1 = "d62dbb5679405d72c4737ec58600e9ddcf06d24c";
      };
    }

    {
      name = "path_platform___path_platform_0.0.1.tgz";
      path = fetchurl {
        name = "path_platform___path_platform_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-platform/-/path-platform-0.0.1.tgz";
        sha1 = "b5585d7c3c463d89aa0060d86611cf1afd617e2a";
      };
    }

    {
      name = "path_root_regex___path_root_regex_0.1.2.tgz";
      path = fetchurl {
        name = "path_root_regex___path_root_regex_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/path-root-regex/-/path-root-regex-0.1.2.tgz";
        sha1 = "bfccdc8df5b12dc52c8b43ec38d18d72c04ba96d";
      };
    }

    {
      name = "path_root___path_root_0.1.1.tgz";
      path = fetchurl {
        name = "path_root___path_root_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/path-root/-/path-root-0.1.1.tgz";
        sha1 = "9a4a6814cac1c0cd73360a95f32083c8ea4745b7";
      };
    }

    {
      name = "path_type___path_type_1.1.0.tgz";
      path = fetchurl {
        name = "path_type___path_type_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/path-type/-/path-type-1.1.0.tgz";
        sha1 = "59c44f7ee491da704da415da5a4070ba4f8fe441";
      };
    }

    {
      name = "pause_stream___pause_stream_0.0.11.tgz";
      path = fetchurl {
        name = "pause_stream___pause_stream_0.0.11.tgz";
        url  = "https://registry.yarnpkg.com/pause-stream/-/pause-stream-0.0.11.tgz";
        sha1 = "fe5a34b0cbce12b5aa6a2b403ee2e73b602f1445";
      };
    }

    {
      name = "performance_now___performance_now_2.1.0.tgz";
      path = fetchurl {
        name = "performance_now___performance_now_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/performance-now/-/performance-now-2.1.0.tgz";
        sha1 = "6309f4e0e5fa913ec1c69307ae364b4b377c9e7b";
      };
    }

    {
      name = "pify___pify_2.3.0.tgz";
      path = fetchurl {
        name = "pify___pify_2.3.0.tgz";
        url  = "https://registry.yarnpkg.com/pify/-/pify-2.3.0.tgz";
        sha1 = "ed141a6ac043a849ea588498e7dca8b15330e90c";
      };
    }

    {
      name = "pinkie_promise___pinkie_promise_2.0.1.tgz";
      path = fetchurl {
        name = "pinkie_promise___pinkie_promise_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/pinkie-promise/-/pinkie-promise-2.0.1.tgz";
        sha1 = "2135d6dfa7a358c069ac9b178776288228450ffa";
      };
    }

    {
      name = "pinkie___pinkie_2.0.4.tgz";
      path = fetchurl {
        name = "pinkie___pinkie_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/pinkie/-/pinkie-2.0.4.tgz";
        sha1 = "72556b80cfa0d48a974e80e77248e80ed4f7f870";
      };
    }

    {
      name = "posix_character_classes___posix_character_classes_0.1.1.tgz";
      path = fetchurl {
        name = "posix_character_classes___posix_character_classes_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/posix-character-classes/-/posix-character-classes-0.1.1.tgz";
        sha1 = "01eac0fe3b5af71a2a6c02feabb8c1fef7e00eab";
      };
    }

    {
      name = "prelude_ls___prelude_ls_1.1.2.tgz";
      path = fetchurl {
        name = "prelude_ls___prelude_ls_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/prelude-ls/-/prelude-ls-1.1.2.tgz";
        sha1 = "21932a549f5e52ffd9a827f570e04be62a97da54";
      };
    }

    {
      name = "prepend_http___prepend_http_1.0.4.tgz";
      path = fetchurl {
        name = "prepend_http___prepend_http_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/prepend-http/-/prepend-http-1.0.4.tgz";
        sha1 = "d4f4562b0ce3696e41ac52d0e002e57a635dc6dc";
      };
    }

    {
      name = "preserve___preserve_0.2.0.tgz";
      path = fetchurl {
        name = "preserve___preserve_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/preserve/-/preserve-0.2.0.tgz";
        sha1 = "815ed1f6ebc65926f865b310c0713bcb3315ce4b";
      };
    }

    {
      name = "pretty_hrtime___pretty_hrtime_1.0.3.tgz";
      path = fetchurl {
        name = "pretty_hrtime___pretty_hrtime_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/pretty-hrtime/-/pretty-hrtime-1.0.3.tgz";
        sha1 = "b7e3ea42435a4c9b2759d99e0f201eb195802ee1";
      };
    }

    {
      name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
      path = fetchurl {
        name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/process-nextick-args/-/process-nextick-args-2.0.1.tgz";
        sha1 = "7820d9b16120cc55ca9ae7792680ae7dba6d7fe2";
      };
    }

    {
      name = "process___process_0.7.0.tgz";
      path = fetchurl {
        name = "process___process_0.7.0.tgz";
        url  = "https://registry.yarnpkg.com/process/-/process-0.7.0.tgz";
        sha1 = "c52208161a34adf3812344ae85d3e6150469389d";
      };
    }

    {
      name = "process___process_0.5.2.tgz";
      path = fetchurl {
        name = "process___process_0.5.2.tgz";
        url  = "https://registry.yarnpkg.com/process/-/process-0.5.2.tgz";
        sha1 = "1638d8a8e34c2f440a91db95ab9aeb677fc185cf";
      };
    }

    {
      name = "process___process_0.6.0.tgz";
      path = fetchurl {
        name = "process___process_0.6.0.tgz";
        url  = "https://registry.yarnpkg.com/process/-/process-0.6.0.tgz";
        sha1 = "7dd9be80ffaaedd4cb628f1827f1cbab6dc0918f";
      };
    }

    {
      name = "promise___promise_7.3.1.tgz";
      path = fetchurl {
        name = "promise___promise_7.3.1.tgz";
        url  = "https://registry.yarnpkg.com/promise/-/promise-7.3.1.tgz";
        sha1 = "064b72602b18f90f29192b8b1bc418ffd1ebd3bf";
      };
    }

    {
      name = "promptly___promptly_0.2.1.tgz";
      path = fetchurl {
        name = "promptly___promptly_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/promptly/-/promptly-0.2.1.tgz";
        sha1 = "6444e7ca4dbd9899e7eeb5ec3922827ebdc22b3b";
      };
    }

    {
      name = "pseudomap___pseudomap_1.0.2.tgz";
      path = fetchurl {
        name = "pseudomap___pseudomap_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/pseudomap/-/pseudomap-1.0.2.tgz";
        sha1 = "f052a28da70e618917ef0a8ac34c1ae5a68286b3";
      };
    }

    {
      name = "psl___psl_1.8.0.tgz";
      path = fetchurl {
        name = "psl___psl_1.8.0.tgz";
        url  = "https://registry.yarnpkg.com/psl/-/psl-1.8.0.tgz";
        sha1 = "9326f8bcfb013adcc005fdff056acce020e51c24";
      };
    }

    {
      name = "pug_attrs___pug_attrs_2.0.4.tgz";
      path = fetchurl {
        name = "pug_attrs___pug_attrs_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/pug-attrs/-/pug-attrs-2.0.4.tgz";
        sha1 = "b2f44c439e4eb4ad5d4ef25cac20d18ad28cc336";
      };
    }

    {
      name = "pug_code_gen___pug_code_gen_2.0.2.tgz";
      path = fetchurl {
        name = "pug_code_gen___pug_code_gen_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/pug-code-gen/-/pug-code-gen-2.0.2.tgz";
        sha1 = "ad0967162aea077dcf787838d94ed14acb0217c2";
      };
    }

    {
      name = "pug_error___pug_error_1.3.3.tgz";
      path = fetchurl {
        name = "pug_error___pug_error_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/pug-error/-/pug-error-1.3.3.tgz";
        sha1 = "f342fb008752d58034c185de03602dd9ffe15fa6";
      };
    }

    {
      name = "pug_filters___pug_filters_3.1.1.tgz";
      path = fetchurl {
        name = "pug_filters___pug_filters_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/pug-filters/-/pug-filters-3.1.1.tgz";
        sha1 = "ab2cc82db9eeccf578bda89130e252a0db026aa7";
      };
    }

    {
      name = "pug_lexer___pug_lexer_4.1.0.tgz";
      path = fetchurl {
        name = "pug_lexer___pug_lexer_4.1.0.tgz";
        url  = "https://registry.yarnpkg.com/pug-lexer/-/pug-lexer-4.1.0.tgz";
        sha1 = "531cde48c7c0b1fcbbc2b85485c8665e31489cfd";
      };
    }

    {
      name = "pug_linker___pug_linker_3.0.6.tgz";
      path = fetchurl {
        name = "pug_linker___pug_linker_3.0.6.tgz";
        url  = "https://registry.yarnpkg.com/pug-linker/-/pug-linker-3.0.6.tgz";
        sha1 = "f5bf218b0efd65ce6670f7afc51658d0f82989fb";
      };
    }

    {
      name = "pug_load___pug_load_2.0.12.tgz";
      path = fetchurl {
        name = "pug_load___pug_load_2.0.12.tgz";
        url  = "https://registry.yarnpkg.com/pug-load/-/pug-load-2.0.12.tgz";
        sha1 = "d38c85eb85f6e2f704dea14dcca94144d35d3e7b";
      };
    }

    {
      name = "pug_parser___pug_parser_5.0.1.tgz";
      path = fetchurl {
        name = "pug_parser___pug_parser_5.0.1.tgz";
        url  = "https://registry.yarnpkg.com/pug-parser/-/pug-parser-5.0.1.tgz";
        sha1 = "03e7ada48b6840bd3822f867d7d90f842d0ffdc9";
      };
    }

    {
      name = "pug_runtime___pug_runtime_2.0.5.tgz";
      path = fetchurl {
        name = "pug_runtime___pug_runtime_2.0.5.tgz";
        url  = "https://registry.yarnpkg.com/pug-runtime/-/pug-runtime-2.0.5.tgz";
        sha1 = "6da7976c36bf22f68e733c359240d8ae7a32953a";
      };
    }

    {
      name = "pug_strip_comments___pug_strip_comments_1.0.4.tgz";
      path = fetchurl {
        name = "pug_strip_comments___pug_strip_comments_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/pug-strip-comments/-/pug-strip-comments-1.0.4.tgz";
        sha1 = "cc1b6de1f6e8f5931cf02ec66cdffd3f50eaf8a8";
      };
    }

    {
      name = "pug_walk___pug_walk_1.1.8.tgz";
      path = fetchurl {
        name = "pug_walk___pug_walk_1.1.8.tgz";
        url  = "https://registry.yarnpkg.com/pug-walk/-/pug-walk-1.1.8.tgz";
        sha1 = "b408f67f27912f8c21da2f45b7230c4bd2a5ea7a";
      };
    }

    {
      name = "pug___pug_2.0.4.tgz";
      path = fetchurl {
        name = "pug___pug_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/pug/-/pug-2.0.4.tgz";
        sha1 = "ee7682ec0a60494b38d48a88f05f3b0ac931377d";
      };
    }

    {
      name = "punycode___punycode_1.3.2.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.3.2.tgz";
        sha1 = "9653a036fb7c1ee42342f2325cceefea3926c48d";
      };
    }

    {
      name = "punycode___punycode_2.1.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-2.1.1.tgz";
        sha1 = "b58b010ac40c22c5657616c8d2c2c02c7bf479ec";
      };
    }

    {
      name = "punycode___punycode_1.2.4.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.2.4.tgz";
        sha1 = "54008ac972aec74175def9cba6df7fa9d3918740";
      };
    }

    {
      name = "q___q_1.5.1.tgz";
      path = fetchurl {
        name = "q___q_1.5.1.tgz";
        url  = "https://registry.yarnpkg.com/q/-/q-1.5.1.tgz";
        sha1 = "7e32f75b41381291d04611f1bf14109ac00651d7";
      };
    }

    {
      name = "q___q_0.9.7.tgz";
      path = fetchurl {
        name = "q___q_0.9.7.tgz";
        url  = "https://registry.yarnpkg.com/q/-/q-0.9.7.tgz";
        sha1 = "4de2e6cb3b29088c9e4cbc03bf9d42fb96ce2f75";
      };
    }

    {
      name = "q___q_1.0.1.tgz";
      path = fetchurl {
        name = "q___q_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/q/-/q-1.0.1.tgz";
        sha1 = "11872aeedee89268110b10a718448ffb10112a14";
      };
    }

    {
      name = "qs___qs_5.2.0.tgz";
      path = fetchurl {
        name = "qs___qs_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-5.2.0.tgz";
        sha1 = "a9f31142af468cb72b25b30136ba2456834916be";
      };
    }

    {
      name = "qs___qs_6.7.0.tgz";
      path = fetchurl {
        name = "qs___qs_6.7.0.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-6.7.0.tgz";
        sha1 = "41dc1a015e3d581f1621776be31afb2876a9b1bc";
      };
    }

    {
      name = "qs___qs_0.6.6.tgz";
      path = fetchurl {
        name = "qs___qs_0.6.6.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-0.6.6.tgz";
        sha1 = "6e015098ff51968b8a3c819001d5f2c89bc4b107";
      };
    }

    {
      name = "qs___qs_1.0.2.tgz";
      path = fetchurl {
        name = "qs___qs_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-1.0.2.tgz";
        sha1 = "50a93e2b5af6691c31bcea5dae78ee6ea1903768";
      };
    }

    {
      name = "qs___qs_2.2.5.tgz";
      path = fetchurl {
        name = "qs___qs_2.2.5.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-2.2.5.tgz";
        sha1 = "1088abaf9dcc0ae5ae45b709e6c6b5888b23923c";
      };
    }

    {
      name = "qs___qs_2.3.3.tgz";
      path = fetchurl {
        name = "qs___qs_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-2.3.3.tgz";
        sha1 = "e9e85adbe75da0bbe4c8e0476a086290f863b404";
      };
    }

    {
      name = "qs___qs_6.5.2.tgz";
      path = fetchurl {
        name = "qs___qs_6.5.2.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-6.5.2.tgz";
        sha1 = "cb3ae806e8740444584ef154ce8ee98d403f3e36";
      };
    }

    {
      name = "querystring_es3___querystring_es3_0.2.0.tgz";
      path = fetchurl {
        name = "querystring_es3___querystring_es3_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/querystring-es3/-/querystring-es3-0.2.0.tgz";
        sha1 = "c365a08a69c443accfeb3a9deab35e3f0abaa476";
      };
    }

    {
      name = "querystring___querystring_0.2.0.tgz";
      path = fetchurl {
        name = "querystring___querystring_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/querystring/-/querystring-0.2.0.tgz";
        sha1 = "b209849203bb25df820da756e747005878521620";
      };
    }

    {
      name = "randomatic___randomatic_3.1.1.tgz";
      path = fetchurl {
        name = "randomatic___randomatic_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/randomatic/-/randomatic-3.1.1.tgz";
        sha1 = "b776efc59375984e36c537b2f51a1f0aff0da1ed";
      };
    }

    {
      name = "range_parser___range_parser_1.0.3.tgz";
      path = fetchurl {
        name = "range_parser___range_parser_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/range-parser/-/range-parser-1.0.3.tgz";
        sha1 = "6872823535c692e2c2a0103826afd82c2e0ff175";
      };
    }

    {
      name = "raw_body___raw_body_2.4.0.tgz";
      path = fetchurl {
        name = "raw_body___raw_body_2.4.0.tgz";
        url  = "https://registry.yarnpkg.com/raw-body/-/raw-body-2.4.0.tgz";
        sha1 = "a1ce6fb9c9bc356ca52e89256ab59059e13d0332";
      };
    }

    {
      name = "raw_body___raw_body_2.1.7.tgz";
      path = fetchurl {
        name = "raw_body___raw_body_2.1.7.tgz";
        url  = "https://registry.yarnpkg.com/raw-body/-/raw-body-2.1.7.tgz";
        sha1 = "adfeace2e4fb3098058014d08c072dcc59758774";
      };
    }

    {
      name = "rc___rc_1.2.8.tgz";
      path = fetchurl {
        name = "rc___rc_1.2.8.tgz";
        url  = "https://registry.yarnpkg.com/rc/-/rc-1.2.8.tgz";
        sha1 = "cd924bf5200a075b83c188cd6b9e211b7fc0d3ed";
      };
    }

    {
      name = "read_all_stream___read_all_stream_3.1.0.tgz";
      path = fetchurl {
        name = "read_all_stream___read_all_stream_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/read-all-stream/-/read-all-stream-3.1.0.tgz";
        sha1 = "35c3e177f2078ef789ee4bfafa4373074eaef4fa";
      };
    }

    {
      name = "read_pkg_up___read_pkg_up_1.0.1.tgz";
      path = fetchurl {
        name = "read_pkg_up___read_pkg_up_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/read-pkg-up/-/read-pkg-up-1.0.1.tgz";
        sha1 = "9d63c13276c065918d57f002a57f40a1b643fb02";
      };
    }

    {
      name = "read_pkg___read_pkg_1.1.0.tgz";
      path = fetchurl {
        name = "read_pkg___read_pkg_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/read-pkg/-/read-pkg-1.1.0.tgz";
        sha1 = "f5ffaa5ecd29cb31c0474bca7d756b6bb29e3f28";
      };
    }

    {
      name = "read___read_1.0.7.tgz";
      path = fetchurl {
        name = "read___read_1.0.7.tgz";
        url  = "https://registry.yarnpkg.com/read/-/read-1.0.7.tgz";
        sha1 = "b3da19bd052431a97671d44a42634adf710b40c4";
      };
    }

    {
      name = "readable_stream___readable_stream_1.0.34.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_1.0.34.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-1.0.34.tgz";
        sha1 = "125820e34bc842d2f2aaafafe4c2916ee32c157c";
      };
    }

    {
      name = "readable_stream___readable_stream_1.1.14.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_1.1.14.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-1.1.14.tgz";
        sha1 = "7cf4c54ef648e3813084c636dd2079e166c081d9";
      };
    }

    {
      name = "readable_stream___readable_stream_2.3.7.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_2.3.7.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-2.3.7.tgz";
        sha1 = "1eca1cf711aef814c04f62252a36a62f6cb23b57";
      };
    }

    {
      name = "readdirp___readdirp_2.2.1.tgz";
      path = fetchurl {
        name = "readdirp___readdirp_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/readdirp/-/readdirp-2.2.1.tgz";
        sha1 = "0e87622a3325aa33e892285caf8b4e846529a525";
      };
    }

    {
      name = "readline2___readline2_0.1.1.tgz";
      path = fetchurl {
        name = "readline2___readline2_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/readline2/-/readline2-0.1.1.tgz";
        sha1 = "99443ba6e83b830ef3051bfd7dc241a82728d568";
      };
    }

    {
      name = "rechoir___rechoir_0.6.2.tgz";
      path = fetchurl {
        name = "rechoir___rechoir_0.6.2.tgz";
        url  = "https://registry.yarnpkg.com/rechoir/-/rechoir-0.6.2.tgz";
        sha1 = "85204b54dba82d5742e28c96756ef43af50e3384";
      };
    }

    {
      name = "redent___redent_1.0.0.tgz";
      path = fetchurl {
        name = "redent___redent_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/redent/-/redent-1.0.0.tgz";
        sha1 = "cf916ab1fd5f1f16dfb20822dd6ec7f730c2afde";
      };
    }

    {
      name = "redeyed___redeyed_0.4.4.tgz";
      path = fetchurl {
        name = "redeyed___redeyed_0.4.4.tgz";
        url  = "https://registry.yarnpkg.com/redeyed/-/redeyed-0.4.4.tgz";
        sha1 = "37e990a6f2b21b2a11c2e6a48fd4135698cba97f";
      };
    }

    {
      name = "regenerator_runtime___regenerator_runtime_0.11.1.tgz";
      path = fetchurl {
        name = "regenerator_runtime___regenerator_runtime_0.11.1.tgz";
        url  = "https://registry.yarnpkg.com/regenerator-runtime/-/regenerator-runtime-0.11.1.tgz";
        sha1 = "be05ad7f9bf7d22e056f9726cee5017fbf19e2e9";
      };
    }

    {
      name = "regex_cache___regex_cache_0.4.4.tgz";
      path = fetchurl {
        name = "regex_cache___regex_cache_0.4.4.tgz";
        url  = "https://registry.yarnpkg.com/regex-cache/-/regex-cache-0.4.4.tgz";
        sha1 = "75bdc58a2a1496cec48a12835bc54c8d562336dd";
      };
    }

    {
      name = "regex_not___regex_not_1.0.2.tgz";
      path = fetchurl {
        name = "regex_not___regex_not_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/regex-not/-/regex-not-1.0.2.tgz";
        sha1 = "1f4ece27e00b0b65e0247a6810e6a85d83a5752c";
      };
    }

    {
      name = "registry_url___registry_url_3.1.0.tgz";
      path = fetchurl {
        name = "registry_url___registry_url_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/registry-url/-/registry-url-3.1.0.tgz";
        sha1 = "3d4ef870f73dde1d77f0cf9a381432444e174942";
      };
    }

    {
      name = "remove_trailing_separator___remove_trailing_separator_1.1.0.tgz";
      path = fetchurl {
        name = "remove_trailing_separator___remove_trailing_separator_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/remove-trailing-separator/-/remove-trailing-separator-1.1.0.tgz";
        sha1 = "c24bce2a283adad5bc3f58e0d48249b92379d8ef";
      };
    }

    {
      name = "repeat_element___repeat_element_1.1.3.tgz";
      path = fetchurl {
        name = "repeat_element___repeat_element_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/repeat-element/-/repeat-element-1.1.3.tgz";
        sha1 = "782e0d825c0c5a3bb39731f84efee6b742e6b1ce";
      };
    }

    {
      name = "repeat_string___repeat_string_0.2.2.tgz";
      path = fetchurl {
        name = "repeat_string___repeat_string_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/repeat-string/-/repeat-string-0.2.2.tgz";
        sha1 = "c7a8d3236068362059a7e4651fc6884e8b1fb4ae";
      };
    }

    {
      name = "repeat_string___repeat_string_1.6.1.tgz";
      path = fetchurl {
        name = "repeat_string___repeat_string_1.6.1.tgz";
        url  = "https://registry.yarnpkg.com/repeat-string/-/repeat-string-1.6.1.tgz";
        sha1 = "8dcae470e1c88abc2d600fff4a776286da75e637";
      };
    }

    {
      name = "repeating___repeating_2.0.1.tgz";
      path = fetchurl {
        name = "repeating___repeating_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/repeating/-/repeating-2.0.1.tgz";
        sha1 = "5214c53a926d3552707527fbab415dbc08d06dda";
      };
    }

    {
      name = "replace_ext___replace_ext_0.0.1.tgz";
      path = fetchurl {
        name = "replace_ext___replace_ext_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/replace-ext/-/replace-ext-0.0.1.tgz";
        sha1 = "29bbd92078a739f0bcce2b4ee41e837953522924";
      };
    }

    {
      name = "replace_ext___replace_ext_1.0.0.tgz";
      path = fetchurl {
        name = "replace_ext___replace_ext_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/replace-ext/-/replace-ext-1.0.0.tgz";
        sha1 = "de63128373fcbf7c3ccfa4de5a480c45a67958eb";
      };
    }

    {
      name = "replacestream___replacestream_4.0.3.tgz";
      path = fetchurl {
        name = "replacestream___replacestream_4.0.3.tgz";
        url  = "https://registry.yarnpkg.com/replacestream/-/replacestream-4.0.3.tgz";
        sha1 = "3ee5798092be364b1cdb1484308492cb3dff2f36";
      };
    }

    {
      name = "request_progress___request_progress_0.3.1.tgz";
      path = fetchurl {
        name = "request_progress___request_progress_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/request-progress/-/request-progress-0.3.1.tgz";
        sha1 = "0721c105d8a96ac6b2ce8b2c89ae2d5ecfcf6b3a";
      };
    }

    {
      name = "request_replay___request_replay_0.2.0.tgz";
      path = fetchurl {
        name = "request_replay___request_replay_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/request-replay/-/request-replay-0.2.0.tgz";
        sha1 = "9b693a5d118b39f5c596ead5ed91a26444057f60";
      };
    }

    {
      name = "request___request_2.88.2.tgz";
      path = fetchurl {
        name = "request___request_2.88.2.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.88.2.tgz";
        sha1 = "d73c918731cb5a87da047e207234146f664d12b3";
      };
    }

    {
      name = "request___request_2.27.0.tgz";
      path = fetchurl {
        name = "request___request_2.27.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.27.0.tgz";
        sha1 = "dfb1a224dd3a5a9bade4337012503d710e538668";
      };
    }

    {
      name = "request___request_2.36.0.tgz";
      path = fetchurl {
        name = "request___request_2.36.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.36.0.tgz";
        sha1 = "28c6c04262c7b9ffdd21b9255374517ee6d943f5";
      };
    }

    {
      name = "request___request_2.40.0.tgz";
      path = fetchurl {
        name = "request___request_2.40.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.40.0.tgz";
        sha1 = "4dd670f696f1e6e842e66b4b5e839301ab9beb67";
      };
    }

    {
      name = "request___request_2.51.0.tgz";
      path = fetchurl {
        name = "request___request_2.51.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.51.0.tgz";
        sha1 = "35d00bbecc012e55f907b1bd9e0dbd577bfef26e";
      };
    }

    {
      name = "require_directory___require_directory_2.1.1.tgz";
      path = fetchurl {
        name = "require_directory___require_directory_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/require-directory/-/require-directory-2.1.1.tgz";
        sha1 = "8c64ad5fd30dab1c976e2344ffe7f792a6a6df42";
      };
    }

    {
      name = "require_main_filename___require_main_filename_1.0.1.tgz";
      path = fetchurl {
        name = "require_main_filename___require_main_filename_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/require-main-filename/-/require-main-filename-1.0.1.tgz";
        sha1 = "97f717b69d48784f5f526a6c5aa8ffdda055a4d1";
      };
    }

    {
      name = "requires_port___requires_port_1.0.0.tgz";
      path = fetchurl {
        name = "requires_port___requires_port_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/requires-port/-/requires-port-1.0.0.tgz";
        sha1 = "925d2601d39ac485e091cf0da5c6e694dc3dcaff";
      };
    }

    {
      name = "resolve_dir___resolve_dir_1.0.1.tgz";
      path = fetchurl {
        name = "resolve_dir___resolve_dir_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/resolve-dir/-/resolve-dir-1.0.1.tgz";
        sha1 = "79a40644c362be82f26effe739c9bb5382046f43";
      };
    }

    {
      name = "resolve_url___resolve_url_0.2.1.tgz";
      path = fetchurl {
        name = "resolve_url___resolve_url_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/resolve-url/-/resolve-url-0.2.1.tgz";
        sha1 = "2c637fe77c893afd2a663fe21aa9080068e2052a";
      };
    }

    {
      name = "resolve___resolve_0.6.3.tgz";
      path = fetchurl {
        name = "resolve___resolve_0.6.3.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-0.6.3.tgz";
        sha1 = "dd957982e7e736debdf53b58a4dd91754575dd46";
      };
    }

    {
      name = "resolve___resolve_1.1.7.tgz";
      path = fetchurl {
        name = "resolve___resolve_1.1.7.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-1.1.7.tgz";
        sha1 = "203114d82ad2c5ed9e8e0411b3932875e889e97b";
      };
    }

    {
      name = "resolve___resolve_1.15.1.tgz";
      path = fetchurl {
        name = "resolve___resolve_1.15.1.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-1.15.1.tgz";
        sha1 = "27bdcdeffeaf2d6244b95bb0f9f4b4653451f3e8";
      };
    }

    {
      name = "resolve___resolve_0.3.1.tgz";
      path = fetchurl {
        name = "resolve___resolve_0.3.1.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-0.3.1.tgz";
        sha1 = "34c63447c664c70598d1c9b126fc43b2a24310a4";
      };
    }

    {
      name = "ret___ret_0.1.15.tgz";
      path = fetchurl {
        name = "ret___ret_0.1.15.tgz";
        url  = "https://registry.yarnpkg.com/ret/-/ret-0.1.15.tgz";
        sha1 = "b8a4825d5bdb1fc3f6f53c2bc33f81388681c7bc";
      };
    }

    {
      name = "retry___retry_0.6.1.tgz";
      path = fetchurl {
        name = "retry___retry_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/retry/-/retry-0.6.1.tgz";
        sha1 = "fdc90eed943fde11b893554b8cc63d0e899ba918";
      };
    }

    {
      name = "rfile___rfile_1.0.0.tgz";
      path = fetchurl {
        name = "rfile___rfile_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/rfile/-/rfile-1.0.0.tgz";
        sha1 = "59708cf90ca1e74c54c3cfc5c36fdb9810435261";
      };
    }

    {
      name = "right_align___right_align_0.1.3.tgz";
      path = fetchurl {
        name = "right_align___right_align_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/right-align/-/right-align-0.1.3.tgz";
        sha1 = "61339b722fe6a3515689210d24e14c96148613ef";
      };
    }

    {
      name = "rimraf___rimraf_2.7.1.tgz";
      path = fetchurl {
        name = "rimraf___rimraf_2.7.1.tgz";
        url  = "https://registry.yarnpkg.com/rimraf/-/rimraf-2.7.1.tgz";
        sha1 = "35797f13a7fdadc566142c29d4f07ccad483e3ec";
      };
    }

    {
      name = "rimraf___rimraf_2.2.8.tgz";
      path = fetchurl {
        name = "rimraf___rimraf_2.2.8.tgz";
        url  = "https://registry.yarnpkg.com/rimraf/-/rimraf-2.2.8.tgz";
        sha1 = "e439be2aaee327321952730f99a8929e4fc50582";
      };
    }

    {
      name = "rimraf___rimraf_2.4.5.tgz";
      path = fetchurl {
        name = "rimraf___rimraf_2.4.5.tgz";
        url  = "https://registry.yarnpkg.com/rimraf/-/rimraf-2.4.5.tgz";
        sha1 = "ee710ce5d93a8fdb856fb5ea8ff0e2d75934b2da";
      };
    }

    {
      name = "ruglify___ruglify_1.0.0.tgz";
      path = fetchurl {
        name = "ruglify___ruglify_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/ruglify/-/ruglify-1.0.0.tgz";
        sha1 = "dc8930e2a9544a274301cc9972574c0d0986b675";
      };
    }

    {
      name = "run_sequence___run_sequence_1.1.5.tgz";
      path = fetchurl {
        name = "run_sequence___run_sequence_1.1.5.tgz";
        url  = "https://registry.yarnpkg.com/run-sequence/-/run-sequence-1.1.5.tgz";
        sha1 = "556bd47eb47877349e36c9c582748897db7be4f7";
      };
    }

    {
      name = "safe_buffer___safe_buffer_5.2.0.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.0.tgz";
        sha1 = "b74daec49b1148f88c64b68d49b1e815c1f2f519";
      };
    }

    {
      name = "safe_buffer___safe_buffer_5.1.2.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.1.2.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.1.2.tgz";
        sha1 = "991ec69d296e0313747d59bdfd2b745c35f8828d";
      };
    }

    {
      name = "safe_regex___safe_regex_1.1.0.tgz";
      path = fetchurl {
        name = "safe_regex___safe_regex_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/safe-regex/-/safe-regex-1.1.0.tgz";
        sha1 = "40a3669f3b077d1e943d44629e157dd48023bf2e";
      };
    }

    {
      name = "safer_buffer___safer_buffer_2.1.2.tgz";
      path = fetchurl {
        name = "safer_buffer___safer_buffer_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/safer-buffer/-/safer-buffer-2.1.2.tgz";
        sha1 = "44fa161b0187b9549dd84bb91802f9bd8385cd6a";
      };
    }

    {
      name = "sass_graph___sass_graph_2.2.4.tgz";
      path = fetchurl {
        name = "sass_graph___sass_graph_2.2.4.tgz";
        url  = "https://registry.yarnpkg.com/sass-graph/-/sass-graph-2.2.4.tgz";
        sha1 = "13fbd63cd1caf0908b9fd93476ad43a51d1e0b49";
      };
    }

    {
      name = "sax___sax_1.2.4.tgz";
      path = fetchurl {
        name = "sax___sax_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/sax/-/sax-1.2.4.tgz";
        sha1 = "2816234e2378bddc4e5354fab5caa895df7100d9";
      };
    }

    {
      name = "scss_tokenizer___scss_tokenizer_0.2.3.tgz";
      path = fetchurl {
        name = "scss_tokenizer___scss_tokenizer_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/scss-tokenizer/-/scss-tokenizer-0.2.3.tgz";
        sha1 = "8eb06db9a9723333824d3f5530641149847ce5d1";
      };
    }

    {
      name = "semver_diff___semver_diff_2.1.0.tgz";
      path = fetchurl {
        name = "semver_diff___semver_diff_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/semver-diff/-/semver-diff-2.1.0.tgz";
        sha1 = "4bbb8437c8d37e4b0cf1a68fd726ec6d645d6d36";
      };
    }

    {
      name = "semver___semver_5.7.1.tgz";
      path = fetchurl {
        name = "semver___semver_5.7.1.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-5.7.1.tgz";
        sha1 = "a954f931aeba508d307bbf069eff0c01c96116f7";
      };
    }

    {
      name = "semver___semver_4.3.6.tgz";
      path = fetchurl {
        name = "semver___semver_4.3.6.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-4.3.6.tgz";
        sha1 = "300bc6e0e86374f7ba61068b5b1ecd57fc6532da";
      };
    }

    {
      name = "semver___semver_2.3.2.tgz";
      path = fetchurl {
        name = "semver___semver_2.3.2.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-2.3.2.tgz";
        sha1 = "b9848f25d6cf36333073ec9ef8856d42f1233e52";
      };
    }

    {
      name = "semver___semver_5.3.0.tgz";
      path = fetchurl {
        name = "semver___semver_5.3.0.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-5.3.0.tgz";
        sha1 = "9b2ce5d3de02d17c6012ad326aa6b4d0cf54f94f";
      };
    }

    {
      name = "send___send_0.13.2.tgz";
      path = fetchurl {
        name = "send___send_0.13.2.tgz";
        url  = "https://registry.yarnpkg.com/send/-/send-0.13.2.tgz";
        sha1 = "765e7607c8055452bba6f0b052595350986036de";
      };
    }

    {
      name = "sequencify___sequencify_0.0.7.tgz";
      path = fetchurl {
        name = "sequencify___sequencify_0.0.7.tgz";
        url  = "https://registry.yarnpkg.com/sequencify/-/sequencify-0.0.7.tgz";
        sha1 = "90cff19d02e07027fd767f5ead3e7b95d1e7380c";
      };
    }

    {
      name = "serve_static___serve_static_1.10.3.tgz";
      path = fetchurl {
        name = "serve_static___serve_static_1.10.3.tgz";
        url  = "https://registry.yarnpkg.com/serve-static/-/serve-static-1.10.3.tgz";
        sha1 = "ce5a6ecd3101fed5ec09827dac22a9c29bfb0535";
      };
    }

    {
      name = "set_blocking___set_blocking_2.0.0.tgz";
      path = fetchurl {
        name = "set_blocking___set_blocking_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/set-blocking/-/set-blocking-2.0.0.tgz";
        sha1 = "045f9782d011ae9a6803ddd382b24392b3d890f7";
      };
    }

    {
      name = "set_value___set_value_2.0.1.tgz";
      path = fetchurl {
        name = "set_value___set_value_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/set-value/-/set-value-2.0.1.tgz";
        sha1 = "a18d40530e6f07de4228c7defe4227af8cad005b";
      };
    }

    {
      name = "setprototypeof___setprototypeof_1.1.1.tgz";
      path = fetchurl {
        name = "setprototypeof___setprototypeof_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/setprototypeof/-/setprototypeof-1.1.1.tgz";
        sha1 = "7e95acb24aa92f5885e0abef5ba131330d4ae683";
      };
    }

    {
      name = "shallow_copy___shallow_copy_0.0.1.tgz";
      path = fetchurl {
        name = "shallow_copy___shallow_copy_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/shallow-copy/-/shallow-copy-0.0.1.tgz";
        sha1 = "415f42702d73d810330292cc5ee86eae1a11a170";
      };
    }

    {
      name = "shell_quote___shell_quote_0.0.1.tgz";
      path = fetchurl {
        name = "shell_quote___shell_quote_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/shell-quote/-/shell-quote-0.0.1.tgz";
        sha1 = "1a41196f3c0333c482323593d6886ecf153dd986";
      };
    }

    {
      name = "shell_quote___shell_quote_1.4.3.tgz";
      path = fetchurl {
        name = "shell_quote___shell_quote_1.4.3.tgz";
        url  = "https://registry.yarnpkg.com/shell-quote/-/shell-quote-1.4.3.tgz";
        sha1 = "952c44e0b1ed9013ef53958179cc643e8777466b";
      };
    }

    {
      name = "sigmund___sigmund_1.0.1.tgz";
      path = fetchurl {
        name = "sigmund___sigmund_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/sigmund/-/sigmund-1.0.1.tgz";
        sha1 = "3ff21f198cad2175f9f3b781853fd94d0d19b590";
      };
    }

    {
      name = "signal_exit___signal_exit_3.0.3.tgz";
      path = fetchurl {
        name = "signal_exit___signal_exit_3.0.3.tgz";
        url  = "https://registry.yarnpkg.com/signal-exit/-/signal-exit-3.0.3.tgz";
        sha1 = "a1410c2edd8f077b08b4e253c8eacfcaf057461c";
      };
    }

    {
      name = "simple_fmt___simple_fmt_0.1.0.tgz";
      path = fetchurl {
        name = "simple_fmt___simple_fmt_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/simple-fmt/-/simple-fmt-0.1.0.tgz";
        sha1 = "191bf566a59e6530482cb25ab53b4a8dc85c3a6b";
      };
    }

    {
      name = "simple_is___simple_is_0.2.0.tgz";
      path = fetchurl {
        name = "simple_is___simple_is_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/simple-is/-/simple-is-0.2.0.tgz";
        sha1 = "2abb75aade39deb5cc815ce10e6191164850baf0";
      };
    }

    {
      name = "snapdragon_node___snapdragon_node_2.1.1.tgz";
      path = fetchurl {
        name = "snapdragon_node___snapdragon_node_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/snapdragon-node/-/snapdragon-node-2.1.1.tgz";
        sha1 = "6c175f86ff14bdb0724563e8f3c1b021a286853b";
      };
    }

    {
      name = "snapdragon_util___snapdragon_util_3.0.1.tgz";
      path = fetchurl {
        name = "snapdragon_util___snapdragon_util_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/snapdragon-util/-/snapdragon-util-3.0.1.tgz";
        sha1 = "f956479486f2acd79700693f6f7b805e45ab56e2";
      };
    }

    {
      name = "snapdragon___snapdragon_0.8.2.tgz";
      path = fetchurl {
        name = "snapdragon___snapdragon_0.8.2.tgz";
        url  = "https://registry.yarnpkg.com/snapdragon/-/snapdragon-0.8.2.tgz";
        sha1 = "64922e7c565b0e14204ba1aa7d6964278d25182d";
      };
    }

    {
      name = "sntp___sntp_0.2.4.tgz";
      path = fetchurl {
        name = "sntp___sntp_0.2.4.tgz";
        url  = "https://registry.yarnpkg.com/sntp/-/sntp-0.2.4.tgz";
        sha1 = "fb885f18b0f3aad189f824862536bceeec750900";
      };
    }

    {
      name = "socket.io_adapter___socket.io_adapter_0.5.0.tgz";
      path = fetchurl {
        name = "socket.io_adapter___socket.io_adapter_0.5.0.tgz";
        url  = "https://registry.yarnpkg.com/socket.io-adapter/-/socket.io-adapter-0.5.0.tgz";
        sha1 = "cb6d4bb8bec81e1078b99677f9ced0046066bb8b";
      };
    }

    {
      name = "socket.io_client___socket.io_client_1.7.4.tgz";
      path = fetchurl {
        name = "socket.io_client___socket.io_client_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/socket.io-client/-/socket.io-client-1.7.4.tgz";
        sha1 = "ec9f820356ed99ef6d357f0756d648717bdd4281";
      };
    }

    {
      name = "socket.io_parser___socket.io_parser_2.3.1.tgz";
      path = fetchurl {
        name = "socket.io_parser___socket.io_parser_2.3.1.tgz";
        url  = "https://registry.yarnpkg.com/socket.io-parser/-/socket.io-parser-2.3.1.tgz";
        sha1 = "dd532025103ce429697326befd64005fcfe5b4a0";
      };
    }

    {
      name = "socket.io___socket.io_1.7.4.tgz";
      path = fetchurl {
        name = "socket.io___socket.io_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/socket.io/-/socket.io-1.7.4.tgz";
        sha1 = "2f7ecedc3391bf2d5c73e291fe233e6e34d4dd00";
      };
    }

    {
      name = "source_map_resolve___source_map_resolve_0.5.3.tgz";
      path = fetchurl {
        name = "source_map_resolve___source_map_resolve_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/source-map-resolve/-/source-map-resolve-0.5.3.tgz";
        sha1 = "190866bece7553e1f8f267a2ee82c606b5509a1a";
      };
    }

    {
      name = "source_map_url___source_map_url_0.4.0.tgz";
      path = fetchurl {
        name = "source_map_url___source_map_url_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/source-map-url/-/source-map-url-0.4.0.tgz";
        sha1 = "3e935d7ddd73631b97659956d55128e87b5084a3";
      };
    }

    {
      name = "source_map___source_map_0.1.34.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.1.34.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.1.34.tgz";
        sha1 = "a7cfe89aec7b1682c3b198d0acfb47d7d090566b";
      };
    }

    {
      name = "source_map___source_map_0.1.43.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.1.43.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.1.43.tgz";
        sha1 = "c24bc146ca517c1471f5dacbe2571b2b7f9e3346";
      };
    }

    {
      name = "source_map___source_map_0.4.4.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.4.4.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.4.4.tgz";
        sha1 = "eba4f5da9c0dc999de68032d8b4f76173652036b";
      };
    }

    {
      name = "source_map___source_map_0.5.7.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.5.7.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.5.7.tgz";
        sha1 = "8a039d2d1021d22d1ea14c80d8ea468ba2ef3fcc";
      };
    }

    {
      name = "source_map___source_map_0.6.1.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.6.1.tgz";
        sha1 = "74722af32e9614e9c287a8d0bbde48b5e2f1a263";
      };
    }

    {
      name = "source_map___source_map_0.2.0.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.2.0.tgz";
        sha1 = "dab73fbcfc2ba819b4de03bd6f6eaa48164b3f9d";
      };
    }

    {
      name = "source_map___source_map_0.3.0.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.3.0.tgz";
        sha1 = "8586fb9a5a005e5b501e21cd18b6f21b457ad1f9";
      };
    }

    {
      name = "sparkles___sparkles_1.0.1.tgz";
      path = fetchurl {
        name = "sparkles___sparkles_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/sparkles/-/sparkles-1.0.1.tgz";
        sha1 = "008db65edce6c50eec0c5e228e1945061dd0437c";
      };
    }

    {
      name = "spdx_correct___spdx_correct_3.1.0.tgz";
      path = fetchurl {
        name = "spdx_correct___spdx_correct_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/spdx-correct/-/spdx-correct-3.1.0.tgz";
        sha1 = "fb83e504445268f154b074e218c87c003cd31df4";
      };
    }

    {
      name = "spdx_exceptions___spdx_exceptions_2.2.0.tgz";
      path = fetchurl {
        name = "spdx_exceptions___spdx_exceptions_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/spdx-exceptions/-/spdx-exceptions-2.2.0.tgz";
        sha1 = "2ea450aee74f2a89bfb94519c07fcd6f41322977";
      };
    }

    {
      name = "spdx_expression_parse___spdx_expression_parse_3.0.0.tgz";
      path = fetchurl {
        name = "spdx_expression_parse___spdx_expression_parse_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/spdx-expression-parse/-/spdx-expression-parse-3.0.0.tgz";
        sha1 = "99e119b7a5da00e05491c9fa338b7904823b41d0";
      };
    }

    {
      name = "spdx_license_ids___spdx_license_ids_3.0.5.tgz";
      path = fetchurl {
        name = "spdx_license_ids___spdx_license_ids_3.0.5.tgz";
        url  = "https://registry.yarnpkg.com/spdx-license-ids/-/spdx-license-ids-3.0.5.tgz";
        sha1 = "3694b5804567a458d3c8045842a6358632f62654";
      };
    }

    {
      name = "split_string___split_string_3.1.0.tgz";
      path = fetchurl {
        name = "split_string___split_string_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/split-string/-/split-string-3.1.0.tgz";
        sha1 = "7cb09dda3a86585705c64b39a6466038682e8fe2";
      };
    }

    {
      name = "split___split_0.3.3.tgz";
      path = fetchurl {
        name = "split___split_0.3.3.tgz";
        url  = "https://registry.yarnpkg.com/split/-/split-0.3.3.tgz";
        sha1 = "cd0eea5e63a211dfff7eb0f091c4133e2d0dd28f";
      };
    }

    {
      name = "split___split_1.0.1.tgz";
      path = fetchurl {
        name = "split___split_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/split/-/split-1.0.1.tgz";
        sha1 = "605bd9be303aa59fb35f9229fbea0ddec9ea07d9";
      };
    }

    {
      name = "sprintf_js___sprintf_js_1.0.3.tgz";
      path = fetchurl {
        name = "sprintf_js___sprintf_js_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/sprintf-js/-/sprintf-js-1.0.3.tgz";
        sha1 = "04e6926f662895354f3dd015203633b857297e2c";
      };
    }

    {
      name = "sshpk___sshpk_1.16.1.tgz";
      path = fetchurl {
        name = "sshpk___sshpk_1.16.1.tgz";
        url  = "https://registry.yarnpkg.com/sshpk/-/sshpk-1.16.1.tgz";
        sha1 = "fb661c0bef29b39db40769ee39fa70093d6f6877";
      };
    }

    {
      name = "stable___stable_0.1.8.tgz";
      path = fetchurl {
        name = "stable___stable_0.1.8.tgz";
        url  = "https://registry.yarnpkg.com/stable/-/stable-0.1.8.tgz";
        sha1 = "836eb3c8382fe2936feaf544631017ce7d47a3cf";
      };
    }

    {
      name = "static_extend___static_extend_0.1.2.tgz";
      path = fetchurl {
        name = "static_extend___static_extend_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/static-extend/-/static-extend-0.1.2.tgz";
        sha1 = "60809c39cbff55337226fd5e0b520f341f1fb5c6";
      };
    }

    {
      name = "statuses___statuses_1.5.0.tgz";
      path = fetchurl {
        name = "statuses___statuses_1.5.0.tgz";
        url  = "https://registry.yarnpkg.com/statuses/-/statuses-1.5.0.tgz";
        sha1 = "161c7dac177659fd9811f43771fa99381478628c";
      };
    }

    {
      name = "statuses___statuses_1.2.1.tgz";
      path = fetchurl {
        name = "statuses___statuses_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/statuses/-/statuses-1.2.1.tgz";
        sha1 = "dded45cc18256d51ed40aec142489d5c61026d28";
      };
    }

    {
      name = "stdout_stream___stdout_stream_1.4.1.tgz";
      path = fetchurl {
        name = "stdout_stream___stdout_stream_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/stdout-stream/-/stdout-stream-1.4.1.tgz";
        sha1 = "5ac174cdd5cd726104aa0c0b2bd83815d8d535de";
      };
    }

    {
      name = "stream_browserify___stream_browserify_0.1.3.tgz";
      path = fetchurl {
        name = "stream_browserify___stream_browserify_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/stream-browserify/-/stream-browserify-0.1.3.tgz";
        sha1 = "95cf1b369772e27adaf46352265152689c6c4be9";
      };
    }

    {
      name = "stream_combiner___stream_combiner_0.2.2.tgz";
      path = fetchurl {
        name = "stream_combiner___stream_combiner_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/stream-combiner/-/stream-combiner-0.2.2.tgz";
        sha1 = "aec8cbac177b56b6f4fa479ced8c1912cee52858";
      };
    }

    {
      name = "stream_combiner___stream_combiner_0.0.4.tgz";
      path = fetchurl {
        name = "stream_combiner___stream_combiner_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/stream-combiner/-/stream-combiner-0.0.4.tgz";
        sha1 = "4d5e433c185261dde623ca3f44c586bcf5c4ad14";
      };
    }

    {
      name = "stream_combiner___stream_combiner_0.1.0.tgz";
      path = fetchurl {
        name = "stream_combiner___stream_combiner_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/stream-combiner/-/stream-combiner-0.1.0.tgz";
        sha1 = "0dc389a3c203f8f4d56368f95dde52eb9269b5be";
      };
    }

    {
      name = "stream_consume___stream_consume_0.1.1.tgz";
      path = fetchurl {
        name = "stream_consume___stream_consume_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/stream-consume/-/stream-consume-0.1.1.tgz";
        sha1 = "d3bdb598c2bd0ae82b8cac7ac50b1107a7996c48";
      };
    }

    {
      name = "stream_shift___stream_shift_1.0.1.tgz";
      path = fetchurl {
        name = "stream_shift___stream_shift_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/stream-shift/-/stream-shift-1.0.1.tgz";
        sha1 = "d7088281559ab2778424279b0877da3c392d5a3d";
      };
    }

    {
      name = "string_length___string_length_1.0.1.tgz";
      path = fetchurl {
        name = "string_length___string_length_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/string-length/-/string-length-1.0.1.tgz";
        sha1 = "56970fb1c38558e9e70b728bf3de269ac45adfac";
      };
    }

    {
      name = "string_width___string_width_1.0.2.tgz";
      path = fetchurl {
        name = "string_width___string_width_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/string-width/-/string-width-1.0.2.tgz";
        sha1 = "118bdf5b8cdc51a2a7e70d211e07e2b0b9b107d3";
      };
    }

    {
      name = "string_width___string_width_2.1.1.tgz";
      path = fetchurl {
        name = "string_width___string_width_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/string-width/-/string-width-2.1.1.tgz";
        sha1 = "ab93f27a8dc13d28cac815c462143a6d9012ae9e";
      };
    }

    {
      name = "string_decoder___string_decoder_0.0.1.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-0.0.1.tgz";
        sha1 = "f5472d0a8d1650ec823752d24e6fd627b39bf141";
      };
    }

    {
      name = "string_decoder___string_decoder_0.10.31.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_0.10.31.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-0.10.31.tgz";
        sha1 = "62e203bc41766c6c28c9fc84301dab1c5310fa94";
      };
    }

    {
      name = "string_decoder___string_decoder_1.1.1.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.1.1.tgz";
        sha1 = "9cf1611ba62685d7030ae9e4ba34149c3af03fc8";
      };
    }

    {
      name = "stringify_object___stringify_object_0.2.1.tgz";
      path = fetchurl {
        name = "stringify_object___stringify_object_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/stringify-object/-/stringify-object-0.2.1.tgz";
        sha1 = "b58be50b3ff5f371038c545d4332656bfded5620";
      };
    }

    {
      name = "stringmap___stringmap_0.2.2.tgz";
      path = fetchurl {
        name = "stringmap___stringmap_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/stringmap/-/stringmap-0.2.2.tgz";
        sha1 = "556c137b258f942b8776f5b2ef582aa069d7d1b1";
      };
    }

    {
      name = "stringset___stringset_0.2.1.tgz";
      path = fetchurl {
        name = "stringset___stringset_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/stringset/-/stringset-0.2.1.tgz";
        sha1 = "ef259c4e349344377fcd1c913dd2e848c9c042b5";
      };
    }

    {
      name = "stringstream___stringstream_0.0.6.tgz";
      path = fetchurl {
        name = "stringstream___stringstream_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/stringstream/-/stringstream-0.0.6.tgz";
        sha1 = "7880225b0d4ad10e30927d167a1d6f2fd3b33a72";
      };
    }

    {
      name = "strip_ansi___strip_ansi_0.3.0.tgz";
      path = fetchurl {
        name = "strip_ansi___strip_ansi_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-0.3.0.tgz";
        sha1 = "25f48ea22ca79187f3174a4db8759347bb126220";
      };
    }

    {
      name = "strip_ansi___strip_ansi_2.0.1.tgz";
      path = fetchurl {
        name = "strip_ansi___strip_ansi_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-2.0.1.tgz";
        sha1 = "df62c1aa94ed2f114e1d0f21fd1d50482b79a60e";
      };
    }

    {
      name = "strip_ansi___strip_ansi_3.0.1.tgz";
      path = fetchurl {
        name = "strip_ansi___strip_ansi_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-3.0.1.tgz";
        sha1 = "6a385fb8853d952d5ff05d0e8aaf94278dc63dcf";
      };
    }

    {
      name = "strip_ansi___strip_ansi_4.0.0.tgz";
      path = fetchurl {
        name = "strip_ansi___strip_ansi_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-4.0.0.tgz";
        sha1 = "a8479022eb1ac368a871389b635262c505ee368f";
      };
    }

    {
      name = "strip_ansi___strip_ansi_0.1.1.tgz";
      path = fetchurl {
        name = "strip_ansi___strip_ansi_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-0.1.1.tgz";
        sha1 = "39e8a98d044d150660abe4a6808acf70bb7bc991";
      };
    }

    {
      name = "strip_bom___strip_bom_1.0.0.tgz";
      path = fetchurl {
        name = "strip_bom___strip_bom_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/strip-bom/-/strip-bom-1.0.0.tgz";
        sha1 = "85b8862f3844b5a6d5ec8467a93598173a36f794";
      };
    }

    {
      name = "strip_bom___strip_bom_2.0.0.tgz";
      path = fetchurl {
        name = "strip_bom___strip_bom_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/strip-bom/-/strip-bom-2.0.0.tgz";
        sha1 = "6219a85616520491f35788bdbf1447a99c7e6b0e";
      };
    }

    {
      name = "strip_indent___strip_indent_1.0.1.tgz";
      path = fetchurl {
        name = "strip_indent___strip_indent_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/strip-indent/-/strip-indent-1.0.1.tgz";
        sha1 = "0c7962a6adefa7bbd4ac366460a638552ae1a0a2";
      };
    }

    {
      name = "strip_json_comments___strip_json_comments_2.0.1.tgz";
      path = fetchurl {
        name = "strip_json_comments___strip_json_comments_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/strip-json-comments/-/strip-json-comments-2.0.1.tgz";
        sha1 = "3c531942e908c2697c0ec344858c286c7ca0a60a";
      };
    }

    {
      name = "subarg___subarg_0.0.1.tgz";
      path = fetchurl {
        name = "subarg___subarg_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/subarg/-/subarg-0.0.1.tgz";
        sha1 = "3d56b07dacfbc45bbb63f7672b43b63e46368e3a";
      };
    }

    {
      name = "supports_color___supports_color_0.2.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-0.2.0.tgz";
        sha1 = "d92de2694eb3f67323973d7ae3d8b55b4c22190a";
      };
    }

    {
      name = "supports_color___supports_color_2.0.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-2.0.0.tgz";
        sha1 = "535d045ce6b6363fa40117084629995e9df324c7";
      };
    }

    {
      name = "supports_color___supports_color_3.2.3.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_3.2.3.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-3.2.3.tgz";
        sha1 = "65ac0504b3954171d8a64946b2ae3cbb8a5f54f6";
      };
    }

    {
      name = "supports_color___supports_color_7.1.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_7.1.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-7.1.0.tgz";
        sha1 = "68e32591df73e25ad1c4b49108a2ec507962bfd1";
      };
    }

    {
      name = "syntax_error___syntax_error_1.1.6.tgz";
      path = fetchurl {
        name = "syntax_error___syntax_error_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/syntax-error/-/syntax-error-1.1.6.tgz";
        sha1 = "b4549706d386cc1c1dc7c2423f18579b6cade710";
      };
    }

    {
      name = "tar___tar_2.2.2.tgz";
      path = fetchurl {
        name = "tar___tar_2.2.2.tgz";
        url  = "https://registry.yarnpkg.com/tar/-/tar-2.2.2.tgz";
        sha1 = "0ca8848562c7299b8b446ff6a4d60cdbb23edc40";
      };
    }

    {
      name = "tar___tar_4.4.13.tgz";
      path = fetchurl {
        name = "tar___tar_4.4.13.tgz";
        url  = "https://registry.yarnpkg.com/tar/-/tar-4.4.13.tgz";
        sha1 = "43b364bc52888d555298637b10d60790254ab525";
      };
    }

    {
      name = "tar___tar_0.1.20.tgz";
      path = fetchurl {
        name = "tar___tar_0.1.20.tgz";
        url  = "https://registry.yarnpkg.com/tar/-/tar-0.1.20.tgz";
        sha1 = "42940bae5b5f22c74483699126f9f3f27449cb13";
      };
    }

    {
      name = "ternary_stream___ternary_stream_2.1.1.tgz";
      path = fetchurl {
        name = "ternary_stream___ternary_stream_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ternary-stream/-/ternary-stream-2.1.1.tgz";
        sha1 = "4ad64b98668d796a085af2c493885a435a8a8bfc";
      };
    }

    {
      name = "textextensions___textextensions_1.0.2.tgz";
      path = fetchurl {
        name = "textextensions___textextensions_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/textextensions/-/textextensions-1.0.2.tgz";
        sha1 = "65486393ee1f2bb039a60cbba05b0b68bd9501d2";
      };
    }

    {
      name = "throttleit___throttleit_0.0.2.tgz";
      path = fetchurl {
        name = "throttleit___throttleit_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/throttleit/-/throttleit-0.0.2.tgz";
        sha1 = "cfedf88e60c00dd9697b61fdd2a8343a9b680eaf";
      };
    }

    {
      name = "through2___through2_0.4.2.tgz";
      path = fetchurl {
        name = "through2___through2_0.4.2.tgz";
        url  = "https://registry.yarnpkg.com/through2/-/through2-0.4.2.tgz";
        sha1 = "dbf5866031151ec8352bb6c4db64a2292a840b9b";
      };
    }

    {
      name = "through2___through2_0.5.1.tgz";
      path = fetchurl {
        name = "through2___through2_0.5.1.tgz";
        url  = "https://registry.yarnpkg.com/through2/-/through2-0.5.1.tgz";
        sha1 = "dfdd012eb9c700e2323fd334f38ac622ab372da7";
      };
    }

    {
      name = "through2___through2_0.6.5.tgz";
      path = fetchurl {
        name = "through2___through2_0.6.5.tgz";
        url  = "https://registry.yarnpkg.com/through2/-/through2-0.6.5.tgz";
        sha1 = "41ab9c67b29d57209071410e1d7a7a968cd3ad48";
      };
    }

    {
      name = "through2___through2_2.0.5.tgz";
      path = fetchurl {
        name = "through2___through2_2.0.5.tgz";
        url  = "https://registry.yarnpkg.com/through2/-/through2-2.0.5.tgz";
        sha1 = "01c1e39eb31d07cb7d03a96a70823260b23132cd";
      };
    }

    {
      name = "through___through_2.3.8.tgz";
      path = fetchurl {
        name = "through___through_2.3.8.tgz";
        url  = "https://registry.yarnpkg.com/through/-/through-2.3.8.tgz";
        sha1 = "0dd4c9ffaabc357960b1b724115d7e0e86a2e1f5";
      };
    }

    {
      name = "through___through_2.2.7.tgz";
      path = fetchurl {
        name = "through___through_2.2.7.tgz";
        url  = "https://registry.yarnpkg.com/through/-/through-2.2.7.tgz";
        sha1 = "6e8e21200191d4eb6a99f6f010df46aa1c6eb2bd";
      };
    }

    {
      name = "tildify___tildify_1.2.0.tgz";
      path = fetchurl {
        name = "tildify___tildify_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/tildify/-/tildify-1.2.0.tgz";
        sha1 = "dcec03f55dca9b7aa3e5b04f21817eb56e63588a";
      };
    }

    {
      name = "time_stamp___time_stamp_1.1.0.tgz";
      path = fetchurl {
        name = "time_stamp___time_stamp_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/time-stamp/-/time-stamp-1.1.0.tgz";
        sha1 = "764a5a11af50561921b133f3b44e618687e0f5c3";
      };
    }

    {
      name = "timed_out___timed_out_2.0.0.tgz";
      path = fetchurl {
        name = "timed_out___timed_out_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/timed-out/-/timed-out-2.0.0.tgz";
        sha1 = "f38b0ae81d3747d628001f41dafc652ace671c0a";
      };
    }

    {
      name = "timers_browserify___timers_browserify_1.0.3.tgz";
      path = fetchurl {
        name = "timers_browserify___timers_browserify_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/timers-browserify/-/timers-browserify-1.0.3.tgz";
        sha1 = "ffba70c9c12eed916fd67318e629ac6f32295551";
      };
    }

    {
      name = "timers_ext___timers_ext_0.1.7.tgz";
      path = fetchurl {
        name = "timers_ext___timers_ext_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/timers-ext/-/timers-ext-0.1.7.tgz";
        sha1 = "6f57ad8578e07a3fb9f91d9387d65647555e25c6";
      };
    }

    {
      name = "tmp___tmp_0.0.23.tgz";
      path = fetchurl {
        name = "tmp___tmp_0.0.23.tgz";
        url  = "https://registry.yarnpkg.com/tmp/-/tmp-0.0.23.tgz";
        sha1 = "de874aa5e974a85f0a32cdfdbd74663cb3bd9c74";
      };
    }

    {
      name = "tmp___tmp_0.0.33.tgz";
      path = fetchurl {
        name = "tmp___tmp_0.0.33.tgz";
        url  = "https://registry.yarnpkg.com/tmp/-/tmp-0.0.33.tgz";
        sha1 = "6d34335889768d21b2bcda0aa277ced3b1bfadf9";
      };
    }

    {
      name = "to_array___to_array_0.1.4.tgz";
      path = fetchurl {
        name = "to_array___to_array_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/to-array/-/to-array-0.1.4.tgz";
        sha1 = "17e6c11f73dd4f3d74cda7a4ff3238e9ad9bf890";
      };
    }

    {
      name = "to_fast_properties___to_fast_properties_1.0.3.tgz";
      path = fetchurl {
        name = "to_fast_properties___to_fast_properties_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/to-fast-properties/-/to-fast-properties-1.0.3.tgz";
        sha1 = "b83571fa4d8c25b82e231b06e3a3055de4ca1a47";
      };
    }

    {
      name = "to_object_path___to_object_path_0.3.0.tgz";
      path = fetchurl {
        name = "to_object_path___to_object_path_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/to-object-path/-/to-object-path-0.3.0.tgz";
        sha1 = "297588b7b0e7e0ac08e04e672f85c1f4999e17af";
      };
    }

    {
      name = "to_regex_range___to_regex_range_2.1.1.tgz";
      path = fetchurl {
        name = "to_regex_range___to_regex_range_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/to-regex-range/-/to-regex-range-2.1.1.tgz";
        sha1 = "7c80c17b9dfebe599e27367e0d4dd5590141db38";
      };
    }

    {
      name = "to_regex___to_regex_3.0.2.tgz";
      path = fetchurl {
        name = "to_regex___to_regex_3.0.2.tgz";
        url  = "https://registry.yarnpkg.com/to-regex/-/to-regex-3.0.2.tgz";
        sha1 = "13cfdd9b336552f30b51f33a8ae1b42a7a7599ce";
      };
    }

    {
      name = "toidentifier___toidentifier_1.0.0.tgz";
      path = fetchurl {
        name = "toidentifier___toidentifier_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/toidentifier/-/toidentifier-1.0.0.tgz";
        sha1 = "7e1be3470f1e77948bc43d94a3c8f4d7752ba553";
      };
    }

    {
      name = "token_stream___token_stream_0.0.1.tgz";
      path = fetchurl {
        name = "token_stream___token_stream_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/token-stream/-/token-stream-0.0.1.tgz";
        sha1 = "ceeefc717a76c4316f126d0b9dbaa55d7e7df01a";
      };
    }

    {
      name = "touch___touch_0.0.2.tgz";
      path = fetchurl {
        name = "touch___touch_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/touch/-/touch-0.0.2.tgz";
        sha1 = "a65a777795e5cbbe1299499bdc42281ffb21b5f4";
      };
    }

    {
      name = "tough_cookie___tough_cookie_4.0.0.tgz";
      path = fetchurl {
        name = "tough_cookie___tough_cookie_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/tough-cookie/-/tough-cookie-4.0.0.tgz";
        sha1 = "d822234eeca882f991f0f908824ad2622ddbece4";
      };
    }

    {
      name = "tough_cookie___tough_cookie_2.5.0.tgz";
      path = fetchurl {
        name = "tough_cookie___tough_cookie_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/tough-cookie/-/tough-cookie-2.5.0.tgz";
        sha1 = "cd9fb2a0aa1d5a12b473bd9fb96fa3dcff65ade2";
      };
    }

    {
      name = "traverse___traverse_0.3.9.tgz";
      path = fetchurl {
        name = "traverse___traverse_0.3.9.tgz";
        url  = "https://registry.yarnpkg.com/traverse/-/traverse-0.3.9.tgz";
        sha1 = "717b8f220cc0bb7b44e40514c22b2e8bbc70d8b9";
      };
    }

    {
      name = "trim_newlines___trim_newlines_1.0.0.tgz";
      path = fetchurl {
        name = "trim_newlines___trim_newlines_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/trim-newlines/-/trim-newlines-1.0.0.tgz";
        sha1 = "5887966bb582a4503a41eb524f7d35011815a613";
      };
    }

    {
      name = "true_case_path___true_case_path_1.0.3.tgz";
      path = fetchurl {
        name = "true_case_path___true_case_path_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/true-case-path/-/true-case-path-1.0.3.tgz";
        sha1 = "f813b5a8c86b40da59606722b144e3225799f47d";
      };
    }

    {
      name = "tryor___tryor_0.1.2.tgz";
      path = fetchurl {
        name = "tryor___tryor_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/tryor/-/tryor-0.1.2.tgz";
        sha1 = "8145e4ca7caff40acde3ccf946e8b8bb75b4172b";
      };
    }

    {
      name = "tty_browserify___tty_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "tty_browserify___tty_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/tty-browserify/-/tty-browserify-0.0.1.tgz";
        sha1 = "3f05251ee17904dfd0677546670db9651682b811";
      };
    }

    {
      name = "tunnel_agent___tunnel_agent_0.6.0.tgz";
      path = fetchurl {
        name = "tunnel_agent___tunnel_agent_0.6.0.tgz";
        url  = "https://registry.yarnpkg.com/tunnel-agent/-/tunnel-agent-0.6.0.tgz";
        sha1 = "27a5dea06b36b04a0a9966774b290868f0fc40fd";
      };
    }

    {
      name = "tunnel_agent___tunnel_agent_0.3.0.tgz";
      path = fetchurl {
        name = "tunnel_agent___tunnel_agent_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/tunnel-agent/-/tunnel-agent-0.3.0.tgz";
        sha1 = "ad681b68f5321ad2827c4cfb1b7d5df2cfe942ee";
      };
    }

    {
      name = "tunnel_agent___tunnel_agent_0.4.3.tgz";
      path = fetchurl {
        name = "tunnel_agent___tunnel_agent_0.4.3.tgz";
        url  = "https://registry.yarnpkg.com/tunnel-agent/-/tunnel-agent-0.4.3.tgz";
        sha1 = "6373db76909fe570e08d73583365ed828a74eeeb";
      };
    }

    {
      name = "tweetnacl___tweetnacl_0.14.5.tgz";
      path = fetchurl {
        name = "tweetnacl___tweetnacl_0.14.5.tgz";
        url  = "https://registry.yarnpkg.com/tweetnacl/-/tweetnacl-0.14.5.tgz";
        sha1 = "5ae68177f192d4456269d108afa93ff8743f4f64";
      };
    }

    {
      name = "type_check___type_check_0.3.2.tgz";
      path = fetchurl {
        name = "type_check___type_check_0.3.2.tgz";
        url  = "https://registry.yarnpkg.com/type-check/-/type-check-0.3.2.tgz";
        sha1 = "5884cab512cf1d355e3fb784f30804b2b520db72";
      };
    }

    {
      name = "type_is___type_is_1.6.18.tgz";
      path = fetchurl {
        name = "type_is___type_is_1.6.18.tgz";
        url  = "https://registry.yarnpkg.com/type-is/-/type-is-1.6.18.tgz";
        sha1 = "4e552cd05df09467dcbc4ef739de89f2cf37c131";
      };
    }

    {
      name = "type___type_1.2.0.tgz";
      path = fetchurl {
        name = "type___type_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/type/-/type-1.2.0.tgz";
        sha1 = "848dd7698dafa3e54a6c479e759c4bc3f18847a0";
      };
    }

    {
      name = "type___type_2.0.0.tgz";
      path = fetchurl {
        name = "type___type_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/type/-/type-2.0.0.tgz";
        sha1 = "5f16ff6ef2eb44f260494dae271033b29c09a9c3";
      };
    }

    {
      name = "typedarray___typedarray_0.0.6.tgz";
      path = fetchurl {
        name = "typedarray___typedarray_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/typedarray/-/typedarray-0.0.6.tgz";
        sha1 = "867ac74e3864187b1d3d47d996a78ec5c8830777";
      };
    }

    {
      name = "uglify_js___uglify_js_2.5.0.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-2.5.0.tgz";
        sha1 = "4ab5d65a4730ecb7a4fb62d3f499e2054d98fba1";
      };
    }

    {
      name = "uglify_js___uglify_js_2.8.29.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_2.8.29.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-2.8.29.tgz";
        sha1 = "29c5733148057bb4e1f75df35b7a9cb72e6a59dd";
      };
    }

    {
      name = "uglify_js___uglify_js_3.8.1.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_3.8.1.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-3.8.1.tgz";
        sha1 = "43bb15ce6f545eaa0a64c49fd29375ea09fa0f93";
      };
    }

    {
      name = "uglify_js___uglify_js_2.2.5.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_2.2.5.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-2.2.5.tgz";
        sha1 = "a6e02a70d839792b9780488b7b8b184c095c99c7";
      };
    }

    {
      name = "uglify_js___uglify_js_2.3.6.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_2.3.6.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-2.3.6.tgz";
        sha1 = "fa0984770b428b7a9b2a8058f46355d14fef211a";
      };
    }

    {
      name = "uglify_js___uglify_js_2.4.24.tgz";
      path = fetchurl {
        name = "uglify_js___uglify_js_2.4.24.tgz";
        url  = "https://registry.yarnpkg.com/uglify-js/-/uglify-js-2.4.24.tgz";
        sha1 = "fad5755c1e1577658bb06ff9ab6e548c95bebd6e";
      };
    }

    {
      name = "uglify_save_license___uglify_save_license_0.4.1.tgz";
      path = fetchurl {
        name = "uglify_save_license___uglify_save_license_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/uglify-save-license/-/uglify-save-license-0.4.1.tgz";
        sha1 = "95726c17cc6fd171c3617e3bf4d8d82aa8c4cce1";
      };
    }

    {
      name = "uglify_to_browserify___uglify_to_browserify_1.0.2.tgz";
      path = fetchurl {
        name = "uglify_to_browserify___uglify_to_browserify_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/uglify-to-browserify/-/uglify-to-browserify-1.0.2.tgz";
        sha1 = "6e0924d6bda6b5afe349e39a6d632850a0f882b7";
      };
    }

    {
      name = "ultron___ultron_1.0.2.tgz";
      path = fetchurl {
        name = "ultron___ultron_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/ultron/-/ultron-1.0.2.tgz";
        sha1 = "ace116ab557cd197386a4e88f4685378c8b2e4fa";
      };
    }

    {
      name = "umd___umd_2.0.0.tgz";
      path = fetchurl {
        name = "umd___umd_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/umd/-/umd-2.0.0.tgz";
        sha1 = "749683b0d514728ae0e1b6195f5774afc0ad4f8f";
      };
    }

    {
      name = "unc_path_regex___unc_path_regex_0.1.2.tgz";
      path = fetchurl {
        name = "unc_path_regex___unc_path_regex_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/unc-path-regex/-/unc-path-regex-0.1.2.tgz";
        sha1 = "e73dd3d7b0d7c5ed86fbac6b0ae7d8c6a69d50fa";
      };
    }

    {
      name = "underscore.string___underscore.string_2.4.0.tgz";
      path = fetchurl {
        name = "underscore.string___underscore.string_2.4.0.tgz";
        url  = "https://registry.yarnpkg.com/underscore.string/-/underscore.string-2.4.0.tgz";
        sha1 = "8cdd8fbac4e2d2ea1e7e2e8097c42f442280f85b";
      };
    }

    {
      name = "underscore___underscore_1.7.0.tgz";
      path = fetchurl {
        name = "underscore___underscore_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/underscore/-/underscore-1.7.0.tgz";
        sha1 = "6bbaf0877500d36be34ecaa584e0db9fef035209";
      };
    }

    {
      name = "union_value___union_value_1.0.1.tgz";
      path = fetchurl {
        name = "union_value___union_value_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/union-value/-/union-value-1.0.1.tgz";
        sha1 = "0b6fe7b835aecda61c6ea4d4f02c14221e109847";
      };
    }

    {
      name = "unique_stream___unique_stream_1.0.0.tgz";
      path = fetchurl {
        name = "unique_stream___unique_stream_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/unique-stream/-/unique-stream-1.0.0.tgz";
        sha1 = "d59a4a75427447d9aa6c91e70263f8d26a4b104b";
      };
    }

    {
      name = "universalify___universalify_0.1.2.tgz";
      path = fetchurl {
        name = "universalify___universalify_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/universalify/-/universalify-0.1.2.tgz";
        sha1 = "b646f69be3942dabcecc9d6639c80dc105efaa66";
      };
    }

    {
      name = "unpipe___unpipe_1.0.0.tgz";
      path = fetchurl {
        name = "unpipe___unpipe_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/unpipe/-/unpipe-1.0.0.tgz";
        sha1 = "b2bf4ee8514aae6165b4817829d21b2ef49904ec";
      };
    }

    {
      name = "unset_value___unset_value_1.0.0.tgz";
      path = fetchurl {
        name = "unset_value___unset_value_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/unset-value/-/unset-value-1.0.0.tgz";
        sha1 = "8376873f7d2335179ffb1e6fc3a8ed0dfc8ab559";
      };
    }

    {
      name = "update_notifier___update_notifier_0.2.2.tgz";
      path = fetchurl {
        name = "update_notifier___update_notifier_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/update-notifier/-/update-notifier-0.2.2.tgz";
        sha1 = "e69b3a784b4e686a2acd98f5e66944591996e187";
      };
    }

    {
      name = "uri_js___uri_js_4.2.2.tgz";
      path = fetchurl {
        name = "uri_js___uri_js_4.2.2.tgz";
        url  = "https://registry.yarnpkg.com/uri-js/-/uri-js-4.2.2.tgz";
        sha1 = "94c540e1ff772956e2299507c010aea6c8838eb0";
      };
    }

    {
      name = "urix___urix_0.1.0.tgz";
      path = fetchurl {
        name = "urix___urix_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/urix/-/urix-0.1.0.tgz";
        sha1 = "da937f7a62e21fec1fd18d49b35c2935067a6c72";
      };
    }

    {
      name = "url___url_0.10.3.tgz";
      path = fetchurl {
        name = "url___url_0.10.3.tgz";
        url  = "https://registry.yarnpkg.com/url/-/url-0.10.3.tgz";
        sha1 = "021e4d9c7705f21bbf37d03ceb58767402774c64";
      };
    }

    {
      name = "use___use_3.1.1.tgz";
      path = fetchurl {
        name = "use___use_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/use/-/use-3.1.1.tgz";
        sha1 = "d50c8cac79a19fbc20f2911f56eb973f4e10070f";
      };
    }

    {
      name = "user_home___user_home_1.1.1.tgz";
      path = fetchurl {
        name = "user_home___user_home_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/user-home/-/user-home-1.1.1.tgz";
        sha1 = "2b5be23a32b63a7c9deb8d0f28d485724a3df190";
      };
    }

    {
      name = "useragent___useragent_2.3.0.tgz";
      path = fetchurl {
        name = "useragent___useragent_2.3.0.tgz";
        url  = "https://registry.yarnpkg.com/useragent/-/useragent-2.3.0.tgz";
        sha1 = "217f943ad540cb2128658ab23fc960f6a88c9972";
      };
    }

    {
      name = "util_deprecate___util_deprecate_1.0.2.tgz";
      path = fetchurl {
        name = "util_deprecate___util_deprecate_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/util-deprecate/-/util-deprecate-1.0.2.tgz";
        sha1 = "450d4dc9fa70de732762fbd2d4a28981419a0ccf";
      };
    }

    {
      name = "util___util_0.10.3.tgz";
      path = fetchurl {
        name = "util___util_0.10.3.tgz";
        url  = "https://registry.yarnpkg.com/util/-/util-0.10.3.tgz";
        sha1 = "7afb1afe50805246489e3db7fe0ed379336ac0f9";
      };
    }

    {
      name = "util___util_0.10.4.tgz";
      path = fetchurl {
        name = "util___util_0.10.4.tgz";
        url  = "https://registry.yarnpkg.com/util/-/util-0.10.4.tgz";
        sha1 = "3aa0125bfe668a4672de58857d3ace27ecb76901";
      };
    }

    {
      name = "utils_merge___utils_merge_1.0.1.tgz";
      path = fetchurl {
        name = "utils_merge___utils_merge_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/utils-merge/-/utils-merge-1.0.1.tgz";
        sha1 = "9f95710f50a267947b2ccc124741c1028427e713";
      };
    }

    {
      name = "uuid___uuid_2.0.3.tgz";
      path = fetchurl {
        name = "uuid___uuid_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/uuid/-/uuid-2.0.3.tgz";
        sha1 = "67e2e863797215530dff318e5bf9dcebfd47b21a";
      };
    }

    {
      name = "uuid___uuid_3.4.0.tgz";
      path = fetchurl {
        name = "uuid___uuid_3.4.0.tgz";
        url  = "https://registry.yarnpkg.com/uuid/-/uuid-3.4.0.tgz";
        sha1 = "b23e4358afa8a202fe7a100af1f5f883f02007ee";
      };
    }

    {
      name = "uuid___uuid_1.4.2.tgz";
      path = fetchurl {
        name = "uuid___uuid_1.4.2.tgz";
        url  = "https://registry.yarnpkg.com/uuid/-/uuid-1.4.2.tgz";
        sha1 = "453019f686966a6df83cdc5244e7c990ecc332fc";
      };
    }

    {
      name = "v8flags___v8flags_2.1.1.tgz";
      path = fetchurl {
        name = "v8flags___v8flags_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/v8flags/-/v8flags-2.1.1.tgz";
        sha1 = "aab1a1fa30d45f88dd321148875ac02c0b55e5b4";
      };
    }

    {
      name = "validate_npm_package_license___validate_npm_package_license_3.0.4.tgz";
      path = fetchurl {
        name = "validate_npm_package_license___validate_npm_package_license_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/validate-npm-package-license/-/validate-npm-package-license-3.0.4.tgz";
        sha1 = "fc91f6b9c7ba15c857f4cb2c5defeec39d4f410a";
      };
    }

    {
      name = "verror___verror_1.10.0.tgz";
      path = fetchurl {
        name = "verror___verror_1.10.0.tgz";
        url  = "https://registry.yarnpkg.com/verror/-/verror-1.10.0.tgz";
        sha1 = "3a105ca17053af55d6e270c1f8288682e18da400";
      };
    }

    {
      name = "vinyl_fs___vinyl_fs_0.3.14.tgz";
      path = fetchurl {
        name = "vinyl_fs___vinyl_fs_0.3.14.tgz";
        url  = "https://registry.yarnpkg.com/vinyl-fs/-/vinyl-fs-0.3.14.tgz";
        sha1 = "9a6851ce1cac1c1cea5fe86c0931d620c2cfa9e6";
      };
    }

    {
      name = "vinyl_sourcemaps_apply___vinyl_sourcemaps_apply_0.1.4.tgz";
      path = fetchurl {
        name = "vinyl_sourcemaps_apply___vinyl_sourcemaps_apply_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/vinyl-sourcemaps-apply/-/vinyl-sourcemaps-apply-0.1.4.tgz";
        sha1 = "c5fcbd43e2f238423c2dc98bddd6f79b72bc345b";
      };
    }

    {
      name = "vinyl_sourcemaps_apply___vinyl_sourcemaps_apply_0.2.1.tgz";
      path = fetchurl {
        name = "vinyl_sourcemaps_apply___vinyl_sourcemaps_apply_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/vinyl-sourcemaps-apply/-/vinyl-sourcemaps-apply-0.2.1.tgz";
        sha1 = "ab6549d61d172c2b1b87be5c508d239c8ef87705";
      };
    }

    {
      name = "vinyl___vinyl_0.2.3.tgz";
      path = fetchurl {
        name = "vinyl___vinyl_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/vinyl/-/vinyl-0.2.3.tgz";
        sha1 = "bca938209582ec5a49ad538a00fa1f125e513252";
      };
    }

    {
      name = "vinyl___vinyl_0.4.6.tgz";
      path = fetchurl {
        name = "vinyl___vinyl_0.4.6.tgz";
        url  = "https://registry.yarnpkg.com/vinyl/-/vinyl-0.4.6.tgz";
        sha1 = "2f356c87a550a255461f36bbeb2a5ba8bf784847";
      };
    }

    {
      name = "vinyl___vinyl_0.5.3.tgz";
      path = fetchurl {
        name = "vinyl___vinyl_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/vinyl/-/vinyl-0.5.3.tgz";
        sha1 = "b0455b38fc5e0cf30d4325132e461970c2091cde";
      };
    }

    {
      name = "vinyl___vinyl_1.2.0.tgz";
      path = fetchurl {
        name = "vinyl___vinyl_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/vinyl/-/vinyl-1.2.0.tgz";
        sha1 = "5c88036cf565e5df05558bfc911f8656df218884";
      };
    }

    {
      name = "vinyl___vinyl_2.2.0.tgz";
      path = fetchurl {
        name = "vinyl___vinyl_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/vinyl/-/vinyl-2.2.0.tgz";
        sha1 = "d85b07da96e458d25b2ffe19fece9f2caa13ed86";
      };
    }

    {
      name = "vm_browserify___vm_browserify_0.0.4.tgz";
      path = fetchurl {
        name = "vm_browserify___vm_browserify_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/vm-browserify/-/vm-browserify-0.0.4.tgz";
        sha1 = "5d7ea45bbef9e4a6ff65f95438e0a87c357d5a73";
      };
    }

    {
      name = "void_elements___void_elements_2.0.1.tgz";
      path = fetchurl {
        name = "void_elements___void_elements_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/void-elements/-/void-elements-2.0.1.tgz";
        sha1 = "c066afb582bb1cb4128d60ea92392e94d5e9dbec";
      };
    }

    {
      name = "websocket_driver___websocket_driver_0.7.3.tgz";
      path = fetchurl {
        name = "websocket_driver___websocket_driver_0.7.3.tgz";
        url  = "https://registry.yarnpkg.com/websocket-driver/-/websocket-driver-0.7.3.tgz";
        sha1 = "a2d4e0d4f4f116f1e6297eba58b05d430100e9f9";
      };
    }

    {
      name = "websocket_extensions___websocket_extensions_0.1.3.tgz";
      path = fetchurl {
        name = "websocket_extensions___websocket_extensions_0.1.3.tgz";
        url  = "https://registry.yarnpkg.com/websocket-extensions/-/websocket-extensions-0.1.3.tgz";
        sha1 = "5d2ff22977003ec687a4b87073dfbbac146ccf29";
      };
    }

    {
      name = "which_module___which_module_1.0.0.tgz";
      path = fetchurl {
        name = "which_module___which_module_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/which-module/-/which-module-1.0.0.tgz";
        sha1 = "bba63ca861948994ff307736089e3b96026c2a4f";
      };
    }

    {
      name = "which___which_1.3.1.tgz";
      path = fetchurl {
        name = "which___which_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/which/-/which-1.3.1.tgz";
        sha1 = "a45043d54f5805316da8d62f9f50918d3da70b0a";
      };
    }

    {
      name = "which___which_1.0.9.tgz";
      path = fetchurl {
        name = "which___which_1.0.9.tgz";
        url  = "https://registry.yarnpkg.com/which/-/which-1.0.9.tgz";
        sha1 = "460c1da0f810103d0321a9b633af9e575e64486f";
      };
    }

    {
      name = "wide_align___wide_align_1.1.3.tgz";
      path = fetchurl {
        name = "wide_align___wide_align_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/wide-align/-/wide-align-1.1.3.tgz";
        sha1 = "ae074e6bdc0c14a431e804e624549c633b000457";
      };
    }

    {
      name = "window_size___window_size_0.1.0.tgz";
      path = fetchurl {
        name = "window_size___window_size_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/window-size/-/window-size-0.1.0.tgz";
        sha1 = "5438cd2ea93b202efa3a19fe8887aee7c94f9c9d";
      };
    }

    {
      name = "with___with_5.1.1.tgz";
      path = fetchurl {
        name = "with___with_5.1.1.tgz";
        url  = "https://registry.yarnpkg.com/with/-/with-5.1.1.tgz";
        sha1 = "fa4daa92daf32c4ea94ed453c81f04686b575dfe";
      };
    }

    {
      name = "word_wrap___word_wrap_1.2.3.tgz";
      path = fetchurl {
        name = "word_wrap___word_wrap_1.2.3.tgz";
        url  = "https://registry.yarnpkg.com/word-wrap/-/word-wrap-1.2.3.tgz";
        sha1 = "610636f6b1f703891bd34771ccb17fb93b47079c";
      };
    }

    {
      name = "wordwrap___wordwrap_0.0.2.tgz";
      path = fetchurl {
        name = "wordwrap___wordwrap_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/wordwrap/-/wordwrap-0.0.2.tgz";
        sha1 = "b79669bb42ecb409f83d583cad52ca17eaa1643f";
      };
    }

    {
      name = "wordwrap___wordwrap_1.0.0.tgz";
      path = fetchurl {
        name = "wordwrap___wordwrap_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/wordwrap/-/wordwrap-1.0.0.tgz";
        sha1 = "27584810891456a4171c8d0226441ade90cbcaeb";
      };
    }

    {
      name = "wordwrap___wordwrap_0.0.3.tgz";
      path = fetchurl {
        name = "wordwrap___wordwrap_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/wordwrap/-/wordwrap-0.0.3.tgz";
        sha1 = "a3d5da6cd5c0bc0008d37234bbaf1bed63059107";
      };
    }

    {
      name = "wrap_ansi___wrap_ansi_2.1.0.tgz";
      path = fetchurl {
        name = "wrap_ansi___wrap_ansi_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/wrap-ansi/-/wrap-ansi-2.1.0.tgz";
        sha1 = "d8fc3d284dd05794fe84973caecdd1cf824fdd85";
      };
    }

    {
      name = "wrappy___wrappy_1.0.2.tgz";
      path = fetchurl {
        name = "wrappy___wrappy_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/wrappy/-/wrappy-1.0.2.tgz";
        sha1 = "b5243d8f3ec1aa35f1364605bc0d1036e30ab69f";
      };
    }

    {
      name = "ws___ws_1.1.5.tgz";
      path = fetchurl {
        name = "ws___ws_1.1.5.tgz";
        url  = "https://registry.yarnpkg.com/ws/-/ws-1.1.5.tgz";
        sha1 = "cbd9e6e75e09fc5d2c90015f21f0c40875e0dd51";
      };
    }

    {
      name = "wtf_8___wtf_8_1.0.0.tgz";
      path = fetchurl {
        name = "wtf_8___wtf_8_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/wtf-8/-/wtf-8-1.0.0.tgz";
        sha1 = "392d8ba2d0f1c34d1ee2d630f15d0efb68e1048a";
      };
    }

    {
      name = "xdg_basedir___xdg_basedir_1.0.1.tgz";
      path = fetchurl {
        name = "xdg_basedir___xdg_basedir_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/xdg-basedir/-/xdg-basedir-1.0.1.tgz";
        sha1 = "14ff8f63a4fdbcb05d5b6eea22b36f3033b9f04e";
      };
    }

    {
      name = "xmlhttprequest_ssl___xmlhttprequest_ssl_1.5.3.tgz";
      path = fetchurl {
        name = "xmlhttprequest_ssl___xmlhttprequest_ssl_1.5.3.tgz";
        url  = "https://registry.yarnpkg.com/xmlhttprequest-ssl/-/xmlhttprequest-ssl-1.5.3.tgz";
        sha1 = "185a888c04eca46c3e4070d99f7b49de3528992d";
      };
    }

    {
      name = "xtend___xtend_4.0.2.tgz";
      path = fetchurl {
        name = "xtend___xtend_4.0.2.tgz";
        url  = "https://registry.yarnpkg.com/xtend/-/xtend-4.0.2.tgz";
        sha1 = "bb72779f5fa465186b1f438f674fa347fdb5db54";
      };
    }

    {
      name = "xtend___xtend_3.0.0.tgz";
      path = fetchurl {
        name = "xtend___xtend_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/xtend/-/xtend-3.0.0.tgz";
        sha1 = "5cce7407baf642cba7becda568111c493f59665a";
      };
    }

    {
      name = "xtend___xtend_2.1.2.tgz";
      path = fetchurl {
        name = "xtend___xtend_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/xtend/-/xtend-2.1.2.tgz";
        sha1 = "6efecc2a4dad8e6962c4901b337ce7ba87b5d28b";
      };
    }

    {
      name = "y18n___y18n_3.2.1.tgz";
      path = fetchurl {
        name = "y18n___y18n_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/y18n/-/y18n-3.2.1.tgz";
        sha1 = "6d15fba884c08679c0d77e88e7759e811e07fa41";
      };
    }

    {
      name = "yallist___yallist_2.1.2.tgz";
      path = fetchurl {
        name = "yallist___yallist_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/yallist/-/yallist-2.1.2.tgz";
        sha1 = "1c11f9218f076089a47dd512f93c6699a6a81d52";
      };
    }

    {
      name = "yallist___yallist_3.1.1.tgz";
      path = fetchurl {
        name = "yallist___yallist_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/yallist/-/yallist-3.1.1.tgz";
        sha1 = "dbb7daf9bfd8bac9ab45ebf602b8cbad0d5d08fd";
      };
    }

    {
      name = "yargs_parser___yargs_parser_5.0.0.tgz";
      path = fetchurl {
        name = "yargs_parser___yargs_parser_5.0.0.tgz";
        url  = "https://registry.yarnpkg.com/yargs-parser/-/yargs-parser-5.0.0.tgz";
        sha1 = "275ecf0d7ffe05c77e64e7c86e4cd94bf0e1228a";
      };
    }

    {
      name = "yargs___yargs_7.1.0.tgz";
      path = fetchurl {
        name = "yargs___yargs_7.1.0.tgz";
        url  = "https://registry.yarnpkg.com/yargs/-/yargs-7.1.0.tgz";
        sha1 = "6ba318eb16961727f5d284f8ea003e8d6154d0c8";
      };
    }

    {
      name = "yargs___yargs_3.10.0.tgz";
      path = fetchurl {
        name = "yargs___yargs_3.10.0.tgz";
        url  = "https://registry.yarnpkg.com/yargs/-/yargs-3.10.0.tgz";
        sha1 = "f7ee7bd857dd7c1d2d38c0e74efbd681d1431fd1";
      };
    }

    {
      name = "yargs___yargs_3.5.4.tgz";
      path = fetchurl {
        name = "yargs___yargs_3.5.4.tgz";
        url  = "https://registry.yarnpkg.com/yargs/-/yargs-3.5.4.tgz";
        sha1 = "d8aff8f665e94c34bd259bdebd1bfaf0ddd35361";
      };
    }

    {
      name = "yeast___yeast_0.1.2.tgz";
      path = fetchurl {
        name = "yeast___yeast_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/yeast/-/yeast-0.1.2.tgz";
        sha1 = "008e06d8094320c372dbc2f8ed76a0ca6c8ac419";
      };
    }
  ];
}
