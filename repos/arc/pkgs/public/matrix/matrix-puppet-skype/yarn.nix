{ fetchurl, linkFarm, runCommandNoCC, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_types_bson___bson_1.0.11.tgz";
      path = fetchurl {
        name = "_types_bson___bson_1.0.11.tgz";
        url  = "https://registry.yarnpkg.com/@types/bson/-/bson-1.0.11.tgz";
        sha1 = "c95ad69bb0b3f5c33b4bb6cc86d86cafb273335c";
      };
    }
    {
      name = "_types_caseless___caseless_0.12.2.tgz";
      path = fetchurl {
        name = "_types_caseless___caseless_0.12.2.tgz";
        url  = "https://registry.yarnpkg.com/@types/caseless/-/caseless-0.12.2.tgz";
        sha1 = "f65d3d6389e01eeb458bd54dc8f52b95a9463bc8";
      };
    }
    {
      name = "_types_cheerio___cheerio_0.22.12.tgz";
      path = fetchurl {
        name = "_types_cheerio___cheerio_0.22.12.tgz";
        url  = "https://registry.yarnpkg.com/@types/cheerio/-/cheerio-0.22.12.tgz";
        sha1 = "93c050401d4935a5376e8b352965f7458bed5340";
      };
    }
    {
      name = "_types_form_data___form_data_2.5.0.tgz";
      path = fetchurl {
        name = "_types_form_data___form_data_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/@types/form-data/-/form-data-2.5.0.tgz";
        sha1 = "5025f7433016f923348434c40006d9a797c1b0e8";
      };
    }
    {
      name = "_types_lodash___lodash_4.14.136.tgz";
      path = fetchurl {
        name = "_types_lodash___lodash_4.14.136.tgz";
        url  = "https://registry.yarnpkg.com/@types/lodash/-/lodash-4.14.136.tgz";
        sha1 = "413e85089046b865d960c9ff1d400e04c31ab60f";
      };
    }
    {
      name = "_types_node___node_12.6.2.tgz";
      path = fetchurl {
        name = "_types_node___node_12.6.2.tgz";
        url  = "https://registry.yarnpkg.com/@types/node/-/node-12.6.2.tgz";
        sha1 = "a5ccec6abb6060d5f20d256fb03ed743e9774999";
      };
    }
    {
      name = "_types_object_inspect___object_inspect_1.4.0.tgz";
      path = fetchurl {
        name = "_types_object_inspect___object_inspect_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/@types/object-inspect/-/object-inspect-1.4.0.tgz";
        sha1 = "649d85af82d9d47f165add37586fd1665bdd5c1a";
      };
    }
    {
      name = "_types_request___request_2.48.2.tgz";
      path = fetchurl {
        name = "_types_request___request_2.48.2.tgz";
        url  = "https://registry.yarnpkg.com/@types/request/-/request-2.48.2.tgz";
        sha1 = "936374cbe1179d7ed529fc02543deb4597450fed";
      };
    }
    {
      name = "_types_tough_cookie___tough_cookie_2.3.5.tgz";
      path = fetchurl {
        name = "_types_tough_cookie___tough_cookie_2.3.5.tgz";
        url  = "https://registry.yarnpkg.com/@types/tough-cookie/-/tough-cookie-2.3.5.tgz";
        sha1 = "9da44ed75571999b65c37b60c9b2b88db54c585d";
      };
    }
    {
      name = "_types_unorm___unorm_1.3.27.tgz";
      path = fetchurl {
        name = "_types_unorm___unorm_1.3.27.tgz";
        url  = "https://registry.yarnpkg.com/@types/unorm/-/unorm-1.3.27.tgz";
        sha1 = "60bdb3bb2e5c9ebe6d082df3a13ca992302cca7a";
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
      name = "accepts___accepts_1.3.7.tgz";
      path = fetchurl {
        name = "accepts___accepts_1.3.7.tgz";
        url  = "https://registry.yarnpkg.com/accepts/-/accepts-1.3.7.tgz";
        sha1 = "531bc726517a3b2b41f850021c6cc15eaab507cd";
      };
    }
    {
      name = "ajv___ajv_6.10.1.tgz";
      path = fetchurl {
        name = "ajv___ajv_6.10.1.tgz";
        url  = "https://registry.yarnpkg.com/ajv/-/ajv-6.10.1.tgz";
        sha1 = "ebf8d3af22552df9dd049bfbe50cc2390e823593";
      };
    }
    {
      name = "another_json___another_json_0.2.0.tgz";
      path = fetchurl {
        name = "another_json___another_json_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/another-json/-/another-json-0.2.0.tgz";
        sha1 = "b5f4019c973b6dd5c6506a2d93469cb6d32aeedc";
      };
    }
    {
      name = "ansi_styles___ansi_styles_3.2.1.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-3.2.1.tgz";
        sha1 = "41fbb20243e50b12be0f04b8dedbf07520ce841d";
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
      name = "array_flatten___array_flatten_1.1.1.tgz";
      path = fetchurl {
        name = "array_flatten___array_flatten_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/array-flatten/-/array-flatten-1.1.1.tgz";
        sha1 = "9a5f699051b1e7073328f2a008968b64ea2955d2";
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
      name = "async_file___async_file_2.0.2.tgz";
      path = fetchurl {
        name = "async_file___async_file_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/async-file/-/async-file-2.0.2.tgz";
        sha1 = "02ad07856ac3717e836b20aec5a4cfe00c46df23";
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
      name = "async___async_3.1.0.tgz";
      path = fetchurl {
        name = "async___async_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-3.1.0.tgz";
        sha1 = "42b3b12ae1b74927b5217d8c0016baaf62463772";
      };
    }
    {
      name = "async___async_2.6.2.tgz";
      path = fetchurl {
        name = "async___async_2.6.2.tgz";
        url  = "https://registry.yarnpkg.com/async/-/async-2.6.2.tgz";
        sha1 = "18330ea7e6e313887f5d2f2a904bac6fe4dd5381";
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
      name = "aws_sign2___aws_sign2_0.7.0.tgz";
      path = fetchurl {
        name = "aws_sign2___aws_sign2_0.7.0.tgz";
        url  = "https://registry.yarnpkg.com/aws-sign2/-/aws-sign2-0.7.0.tgz";
        sha1 = "b46e890934a9591f2d2f6f86d7e6a9f1b3fe76a8";
      };
    }
    {
      name = "aws4___aws4_1.8.0.tgz";
      path = fetchurl {
        name = "aws4___aws4_1.8.0.tgz";
        url  = "https://registry.yarnpkg.com/aws4/-/aws4-1.8.0.tgz";
        sha1 = "f0e003d9ca9e7f59c7a508945d7b2ef9a04a542f";
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
      name = "balanced_match___balanced_match_1.0.0.tgz";
      path = fetchurl {
        name = "balanced_match___balanced_match_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/balanced-match/-/balanced-match-1.0.0.tgz";
        sha1 = "89b4d199ab2bee49de164ea02b89ce462d71b767";
      };
    }
    {
      name = "base_x___base_x_3.0.6.tgz";
      path = fetchurl {
        name = "base_x___base_x_3.0.6.tgz";
        url  = "https://registry.yarnpkg.com/base-x/-/base-x-3.0.6.tgz";
        sha1 = "de047ec95f5f7b99ae63d830a2a894c96538b2cd";
      };
    }
    {
      name = "basic_auth___basic_auth_2.0.1.tgz";
      path = fetchurl {
        name = "basic_auth___basic_auth_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/basic-auth/-/basic-auth-2.0.1.tgz";
        sha1 = "b998279bf47ce38344b4f3cf916d4679bbf51e3a";
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
      name = "big_integer___big_integer_1.6.44.tgz";
      path = fetchurl {
        name = "big_integer___big_integer_1.6.44.tgz";
        url  = "https://registry.yarnpkg.com/big-integer/-/big-integer-1.6.44.tgz";
        sha1 = "4ee9ae5f5839fc11ade338fea216b4513454a539";
      };
    }
    {
      name = "binary_search_tree___binary_search_tree_0.2.5.tgz";
      path = fetchurl {
        name = "binary_search_tree___binary_search_tree_0.2.5.tgz";
        url  = "https://registry.yarnpkg.com/binary-search-tree/-/binary-search-tree-0.2.5.tgz";
        sha1 = "7dbb3b210fdca082450dad2334c304af39bdc784";
      };
    }
    {
      name = "bintrees___bintrees_1.0.1.tgz";
      path = fetchurl {
        name = "bintrees___bintrees_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/bintrees/-/bintrees-1.0.1.tgz";
        sha1 = "0e655c9b9c2435eaab68bf4027226d2b55a34524";
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
      name = "bluebird___bluebird_3.5.5.tgz";
      path = fetchurl {
        name = "bluebird___bluebird_3.5.5.tgz";
        url  = "https://registry.yarnpkg.com/bluebird/-/bluebird-3.5.5.tgz";
        sha1 = "a8d0afd73251effbbd5fe384a77d73003c17a71f";
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
      name = "boolbase___boolbase_1.0.0.tgz";
      path = fetchurl {
        name = "boolbase___boolbase_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/boolbase/-/boolbase-1.0.0.tgz";
        sha1 = "68dff5fbe60c51eb37725ea9e3ed310dcc1e776e";
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
      name = "browser_request___browser_request_0.3.3.tgz";
      path = fetchurl {
        name = "browser_request___browser_request_0.3.3.tgz";
        url  = "https://registry.yarnpkg.com/browser-request/-/browser-request-0.3.3.tgz";
        sha1 = "9ece5b5aca89a29932242e18bf933def9876cc17";
      };
    }
    {
      name = "bs58___bs58_4.0.1.tgz";
      path = fetchurl {
        name = "bs58___bs58_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/bs58/-/bs58-4.0.1.tgz";
        sha1 = "be161e76c354f6f788ae4071f63f34e8c4f0a42a";
      };
    }
    {
      name = "bson___bson_1.1.1.tgz";
      path = fetchurl {
        name = "bson___bson_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/bson/-/bson-1.1.1.tgz";
        sha1 = "4330f5e99104c4e751e7351859e2d408279f2f13";
      };
    }
    {
      name = "buffer_from___buffer_from_1.1.1.tgz";
      path = fetchurl {
        name = "buffer_from___buffer_from_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.1.tgz";
        sha1 = "32713bc028f75c02fdb710d7c7bcec1f2c6070ef";
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
      name = "caseless___caseless_0.12.0.tgz";
      path = fetchurl {
        name = "caseless___caseless_0.12.0.tgz";
        url  = "https://registry.yarnpkg.com/caseless/-/caseless-0.12.0.tgz";
        sha1 = "1b681c21ff84033c826543090689420d187151dc";
      };
    }
    {
      name = "chalk___chalk_2.4.2.tgz";
      path = fetchurl {
        name = "chalk___chalk_2.4.2.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-2.4.2.tgz";
        sha1 = "cd42541677a54333cf541a49108c1432b44c9424";
      };
    }
    {
      name = "cheerio___cheerio_1.0.0_rc.3.tgz";
      path = fetchurl {
        name = "cheerio___cheerio_1.0.0_rc.3.tgz";
        url  = "https://registry.yarnpkg.com/cheerio/-/cheerio-1.0.0-rc.3.tgz";
        sha1 = "094636d425b2e9c0f4eb91a46c05630c9a1a8bf6";
      };
    }
    {
      name = "color_convert___color_convert_1.9.3.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_1.9.3.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-1.9.3.tgz";
        sha1 = "bb71850690e1f136567de629d2d5471deda4c1e8";
      };
    }
    {
      name = "color_name___color_name_1.1.3.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.3.tgz";
        sha1 = "a7d0558bd89c42f795dd42328f740831ca53bc25";
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
      name = "color_string___color_string_1.5.3.tgz";
      path = fetchurl {
        name = "color_string___color_string_1.5.3.tgz";
        url  = "https://registry.yarnpkg.com/color-string/-/color-string-1.5.3.tgz";
        sha1 = "c9bbc5f01b58b5492f3d6857459cb6590ce204cc";
      };
    }
    {
      name = "color___color_3.0.0.tgz";
      path = fetchurl {
        name = "color___color_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/color/-/color-3.0.0.tgz";
        sha1 = "d920b4328d534a3ac8295d68f7bd4ba6c427be9a";
      };
    }
    {
      name = "colornames___colornames_1.1.1.tgz";
      path = fetchurl {
        name = "colornames___colornames_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/colornames/-/colornames-1.1.1.tgz";
        sha1 = "f8889030685c7c4ff9e2a559f5077eb76a816f96";
      };
    }
    {
      name = "colors___colors_1.3.3.tgz";
      path = fetchurl {
        name = "colors___colors_1.3.3.tgz";
        url  = "https://registry.yarnpkg.com/colors/-/colors-1.3.3.tgz";
        sha1 = "39e005d546afe01e01f9c4ca8fa50f686a01205d";
      };
    }
    {
      name = "colorspace___colorspace_1.1.2.tgz";
      path = fetchurl {
        name = "colorspace___colorspace_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/colorspace/-/colorspace-1.1.2.tgz";
        sha1 = "e0128950d082b86a2168580796a0aa5d6c68d8c5";
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
      name = "concat_map___concat_map_0.0.1.tgz";
      path = fetchurl {
        name = "concat_map___concat_map_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/concat-map/-/concat-map-0.0.1.tgz";
        sha1 = "d8a96bd77fd68df7793a73036a3ba0d5405d477b";
      };
    }
    {
      name = "concat_stream___concat_stream_1.6.2.tgz";
      path = fetchurl {
        name = "concat_stream___concat_stream_1.6.2.tgz";
        url  = "https://registry.yarnpkg.com/concat-stream/-/concat-stream-1.6.2.tgz";
        sha1 = "904bdf194cd3122fc675c77fc4ac3d4ff0fd1a34";
      };
    }
    {
      name = "content_disposition___content_disposition_0.5.3.tgz";
      path = fetchurl {
        name = "content_disposition___content_disposition_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/content-disposition/-/content-disposition-0.5.3.tgz";
        sha1 = "e130caf7e7279087c5616c2007d0485698984fbd";
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
      name = "cookie_signature___cookie_signature_1.0.6.tgz";
      path = fetchurl {
        name = "cookie_signature___cookie_signature_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/cookie-signature/-/cookie-signature-1.0.6.tgz";
        sha1 = "e303a882b342cc3ee8ca513a79999734dab3ae2c";
      };
    }
    {
      name = "cookie___cookie_0.4.0.tgz";
      path = fetchurl {
        name = "cookie___cookie_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/cookie/-/cookie-0.4.0.tgz";
        sha1 = "beb437e7022b3b6d49019d088665303ebe9c14ba";
      };
    }
    {
      name = "core_js___core_js_2.6.9.tgz";
      path = fetchurl {
        name = "core_js___core_js_2.6.9.tgz";
        url  = "https://registry.yarnpkg.com/core-js/-/core-js-2.6.9.tgz";
        sha1 = "6b4b214620c834152e179323727fc19741b084f2";
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
      name = "css_select___css_select_1.2.0.tgz";
      path = fetchurl {
        name = "css_select___css_select_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/css-select/-/css-select-1.2.0.tgz";
        sha1 = "2b3a110539c5355f1cd8d314623e870b121ec858";
      };
    }
    {
      name = "css_what___css_what_2.1.3.tgz";
      path = fetchurl {
        name = "css_what___css_what_2.1.3.tgz";
        url  = "https://registry.yarnpkg.com/css-what/-/css-what-2.1.3.tgz";
        sha1 = "a6d7604573365fe74686c3f311c56513d88285f2";
      };
    }
    {
      name = "cycle___cycle_1.0.3.tgz";
      path = fetchurl {
        name = "cycle___cycle_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/cycle/-/cycle-1.0.3.tgz";
        sha1 = "21e80b2be8580f98b468f379430662b046c34ad2";
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
      name = "debug___debug_2.6.9.tgz";
      path = fetchurl {
        name = "debug___debug_2.6.9.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-2.6.9.tgz";
        sha1 = "5d128515df134ff327e90a4c93f4e077a536341f";
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
      name = "depd___depd_1.1.2.tgz";
      path = fetchurl {
        name = "depd___depd_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/depd/-/depd-1.1.2.tgz";
        sha1 = "9bcd52e14c097763e749b274c4346ed2e560b5a9";
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
      name = "diagnostics___diagnostics_1.1.1.tgz";
      path = fetchurl {
        name = "diagnostics___diagnostics_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/diagnostics/-/diagnostics-1.1.1.tgz";
        sha1 = "cab6ac33df70c9d9a727490ae43ac995a769b22a";
      };
    }
    {
      name = "dom_serializer___dom_serializer_0.1.1.tgz";
      path = fetchurl {
        name = "dom_serializer___dom_serializer_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/dom-serializer/-/dom-serializer-0.1.1.tgz";
        sha1 = "1ec4059e284babed36eec2941d4a970a189ce7c0";
      };
    }
    {
      name = "domelementtype___domelementtype_1.3.1.tgz";
      path = fetchurl {
        name = "domelementtype___domelementtype_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/domelementtype/-/domelementtype-1.3.1.tgz";
        sha1 = "d048c44b37b0d10a7f2a3d5fee3f4333d790481f";
      };
    }
    {
      name = "domhandler___domhandler_2.4.2.tgz";
      path = fetchurl {
        name = "domhandler___domhandler_2.4.2.tgz";
        url  = "https://registry.yarnpkg.com/domhandler/-/domhandler-2.4.2.tgz";
        sha1 = "8805097e933d65e85546f726d60f5eb88b44f803";
      };
    }
    {
      name = "domutils___domutils_1.5.1.tgz";
      path = fetchurl {
        name = "domutils___domutils_1.5.1.tgz";
        url  = "https://registry.yarnpkg.com/domutils/-/domutils-1.5.1.tgz";
        sha1 = "dcd8488a26f563d61079e48c9f7b7e32373682cf";
      };
    }
    {
      name = "domutils___domutils_1.7.0.tgz";
      path = fetchurl {
        name = "domutils___domutils_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/domutils/-/domutils-1.7.0.tgz";
        sha1 = "56ea341e834e06e6748af7a1cb25da67ea9f8c2a";
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
      name = "enabled___enabled_1.0.2.tgz";
      path = fetchurl {
        name = "enabled___enabled_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/enabled/-/enabled-1.0.2.tgz";
        sha1 = "965f6513d2c2d1c5f4652b64a2e3396467fc2f93";
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
      name = "entities___entities_1.1.2.tgz";
      path = fetchurl {
        name = "entities___entities_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/entities/-/entities-1.1.2.tgz";
        sha1 = "bdfa735299664dfafd34529ed4f8522a275fea56";
      };
    }
    {
      name = "env_variable___env_variable_0.0.5.tgz";
      path = fetchurl {
        name = "env_variable___env_variable_0.0.5.tgz";
        url  = "https://registry.yarnpkg.com/env-variable/-/env-variable-0.0.5.tgz";
        sha1 = "913dd830bef11e96a039c038d4130604eba37f88";
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
      name = "esprima___esprima_4.0.1.tgz";
      path = fetchurl {
        name = "esprima___esprima_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/esprima/-/esprima-4.0.1.tgz";
        sha1 = "13b04cdb3e6c5d19df91ab6987a8695619b0aa71";
      };
    }
    {
      name = "etag___etag_1.8.1.tgz";
      path = fetchurl {
        name = "etag___etag_1.8.1.tgz";
        url  = "https://registry.yarnpkg.com/etag/-/etag-1.8.1.tgz";
        sha1 = "41ae2eeb65efa62268aebfea83ac7d79299b0887";
      };
    }
    {
      name = "express___express_4.17.1.tgz";
      path = fetchurl {
        name = "express___express_4.17.1.tgz";
        url  = "https://registry.yarnpkg.com/express/-/express-4.17.1.tgz";
        sha1 = "4491fc38605cf51f8629d39c2b5d026f98a4c134";
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
      name = "fast_deep_equal___fast_deep_equal_2.0.1.tgz";
      path = fetchurl {
        name = "fast_deep_equal___fast_deep_equal_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/fast-deep-equal/-/fast-deep-equal-2.0.1.tgz";
        sha1 = "7b05218ddf9667bf7f370bf7fdb2cb15fdd0aa49";
      };
    }
    {
      name = "fast_json_stable_stringify___fast_json_stable_stringify_2.0.0.tgz";
      path = fetchurl {
        name = "fast_json_stable_stringify___fast_json_stable_stringify_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fast-json-stable-stringify/-/fast-json-stable-stringify-2.0.0.tgz";
        sha1 = "d5142c0caee6b1189f87d3a76111064f86c8bbf2";
      };
    }
    {
      name = "fast_safe_stringify___fast_safe_stringify_2.0.6.tgz";
      path = fetchurl {
        name = "fast_safe_stringify___fast_safe_stringify_2.0.6.tgz";
        url  = "https://registry.yarnpkg.com/fast-safe-stringify/-/fast-safe-stringify-2.0.6.tgz";
        sha1 = "04b26106cc56681f51a044cfc0d76cf0008ac2c2";
      };
    }
    {
      name = "fecha___fecha_2.3.3.tgz";
      path = fetchurl {
        name = "fecha___fecha_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/fecha/-/fecha-2.3.3.tgz";
        sha1 = "948e74157df1a32fd1b12c3a3c3cdcb6ec9d96cd";
      };
    }
    {
      name = "file_stream_rotator___file_stream_rotator_0.4.1.tgz";
      path = fetchurl {
        name = "file_stream_rotator___file_stream_rotator_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/file-stream-rotator/-/file-stream-rotator-0.4.1.tgz";
        sha1 = "09f67b86d6ea589d20b7852c51c59de55d916d6d";
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
      name = "fluent_ffmpeg___fluent_ffmpeg_2.1.2.tgz";
      path = fetchurl {
        name = "fluent_ffmpeg___fluent_ffmpeg_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/fluent-ffmpeg/-/fluent-ffmpeg-2.1.2.tgz";
        sha1 = "c952de2240f812ebda0aa8006d7776ee2acf7d74";
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
      name = "form_data___form_data_2.5.0.tgz";
      path = fetchurl {
        name = "form_data___form_data_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/form-data/-/form-data-2.5.0.tgz";
        sha1 = "094ec359dc4b55e7d62e0db4acd76e89fe874d37";
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
      name = "forwarded___forwarded_0.1.2.tgz";
      path = fetchurl {
        name = "forwarded___forwarded_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/forwarded/-/forwarded-0.1.2.tgz";
        sha1 = "98c23dab1175657b8c0573e8ceccd91b0ff18c84";
      };
    }
    {
      name = "fresh___fresh_0.5.2.tgz";
      path = fetchurl {
        name = "fresh___fresh_0.5.2.tgz";
        url  = "https://registry.yarnpkg.com/fresh/-/fresh-0.5.2.tgz";
        sha1 = "3d8cadd90d976569fa835ab1f8e4b23a105605a7";
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
      name = "generate_function___generate_function_2.3.1.tgz";
      path = fetchurl {
        name = "generate_function___generate_function_2.3.1.tgz";
        url  = "https://registry.yarnpkg.com/generate-function/-/generate-function-2.3.1.tgz";
        sha1 = "f069617690c10c868e73b8465746764f97c3479f";
      };
    }
    {
      name = "generate_object_property___generate_object_property_1.2.0.tgz";
      path = fetchurl {
        name = "generate_object_property___generate_object_property_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/generate-object-property/-/generate-object-property-1.2.0.tgz";
        sha1 = "9c0e1c40308ce804f4783618b937fa88f99d50d0";
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
      name = "glob___glob_7.1.4.tgz";
      path = fetchurl {
        name = "glob___glob_7.1.4.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-7.1.4.tgz";
        sha1 = "aa608a2f6c577ad357e1ae5a5c26d9a8d1969255";
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
      name = "has_flag___has_flag_3.0.0.tgz";
      path = fetchurl {
        name = "has_flag___has_flag_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-flag/-/has-flag-3.0.0.tgz";
        sha1 = "b5d454dc2199ae225699f3467e5a07f3b955bafd";
      };
    }
    {
      name = "html_entities___html_entities_1.2.1.tgz";
      path = fetchurl {
        name = "html_entities___html_entities_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/html-entities/-/html-entities-1.2.1.tgz";
        sha1 = "0df29351f0721163515dfb9e5543e5f6eed5162f";
      };
    }
    {
      name = "htmlparser2___htmlparser2_3.10.1.tgz";
      path = fetchurl {
        name = "htmlparser2___htmlparser2_3.10.1.tgz";
        url  = "https://registry.yarnpkg.com/htmlparser2/-/htmlparser2-3.10.1.tgz";
        sha1 = "bd679dc3f59897b6a34bb10749c855bb53a9392f";
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
      name = "http_errors___http_errors_1.7.3.tgz";
      path = fetchurl {
        name = "http_errors___http_errors_1.7.3.tgz";
        url  = "https://registry.yarnpkg.com/http-errors/-/http-errors-1.7.3.tgz";
        sha1 = "6c619e4f9c60308c38519498c14fbb10aacebb06";
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
      name = "iconv_lite___iconv_lite_0.4.24.tgz";
      path = fetchurl {
        name = "iconv_lite___iconv_lite_0.4.24.tgz";
        url  = "https://registry.yarnpkg.com/iconv-lite/-/iconv-lite-0.4.24.tgz";
        sha1 = "2022b4b25fbddc21d2f524974a474aafe733908b";
      };
    }
    {
      name = "image_size___image_size_0.7.4.tgz";
      path = fetchurl {
        name = "image_size___image_size_0.7.4.tgz";
        url  = "https://registry.yarnpkg.com/image-size/-/image-size-0.7.4.tgz";
        sha1 = "092c1e541a93511917bfc957a1fc7add21c72e87";
      };
    }
    {
      name = "immediate___immediate_3.0.6.tgz";
      path = fetchurl {
        name = "immediate___immediate_3.0.6.tgz";
        url  = "https://registry.yarnpkg.com/immediate/-/immediate-3.0.6.tgz";
        sha1 = "9db1dbd0faf8de6fbe0f5dd5e56bb606280de69b";
      };
    }
    {
      name = "incident___incident_3.2.0.tgz";
      path = fetchurl {
        name = "incident___incident_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/incident/-/incident-3.2.0.tgz";
        sha1 = "448f14ab46d52512240efc7466a5b0a0f3bd89ab";
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
      name = "inherits___inherits_2.0.4.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.4.tgz";
        sha1 = "0fa2c64f932917c3433a0ded55363aae37416b7c";
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
      name = "ipaddr.js___ipaddr.js_1.9.0.tgz";
      path = fetchurl {
        name = "ipaddr.js___ipaddr.js_1.9.0.tgz";
        url  = "https://registry.yarnpkg.com/ipaddr.js/-/ipaddr.js-1.9.0.tgz";
        sha1 = "37df74e430a0e47550fe54a2defe30d8acd95f65";
      };
    }
    {
      name = "is_arrayish___is_arrayish_0.3.2.tgz";
      path = fetchurl {
        name = "is_arrayish___is_arrayish_0.3.2.tgz";
        url  = "https://registry.yarnpkg.com/is-arrayish/-/is-arrayish-0.3.2.tgz";
        sha1 = "4574a2ae56f7ab206896fb431eaeed066fdf8f03";
      };
    }
    {
      name = "is_my_ip_valid___is_my_ip_valid_1.0.0.tgz";
      path = fetchurl {
        name = "is_my_ip_valid___is_my_ip_valid_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-my-ip-valid/-/is-my-ip-valid-1.0.0.tgz";
        sha1 = "7b351b8e8edd4d3995d4d066680e664d94696824";
      };
    }
    {
      name = "is_my_json_valid___is_my_json_valid_2.20.0.tgz";
      path = fetchurl {
        name = "is_my_json_valid___is_my_json_valid_2.20.0.tgz";
        url  = "https://registry.yarnpkg.com/is-my-json-valid/-/is-my-json-valid-2.20.0.tgz";
        sha1 = "1345a6fca3e8daefc10d0fa77067f54cedafd59a";
      };
    }
    {
      name = "is_property___is_property_1.0.2.tgz";
      path = fetchurl {
        name = "is_property___is_property_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/is-property/-/is-property-1.0.2.tgz";
        sha1 = "57fe1c4e48474edd65b09911f26b1cd4095dda84";
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
      name = "isarray___isarray_1.0.0.tgz";
      path = fetchurl {
        name = "isarray___isarray_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/isarray/-/isarray-1.0.0.tgz";
        sha1 = "bb935d48582cba168c06834957a54a3e07124f11";
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
      name = "isstream___isstream_0.1.2.tgz";
      path = fetchurl {
        name = "isstream___isstream_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/isstream/-/isstream-0.1.2.tgz";
        sha1 = "47e63f7af55afa6f92e1500e690eb8b8529c099a";
      };
    }
    {
      name = "js_sha256___js_sha256_0.9.0.tgz";
      path = fetchurl {
        name = "js_sha256___js_sha256_0.9.0.tgz";
        url  = "https://registry.yarnpkg.com/js-sha256/-/js-sha256-0.9.0.tgz";
        sha1 = "0b89ac166583e91ef9123644bd3c5334ce9d0966";
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
      name = "jsonpointer___jsonpointer_4.0.1.tgz";
      path = fetchurl {
        name = "jsonpointer___jsonpointer_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/jsonpointer/-/jsonpointer-4.0.1.tgz";
        sha1 = "4fd92cb34e0e9db3c89c8622ecf51f9b978c6cb9";
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
      name = "kryo___kryo_0.6.1.tgz";
      path = fetchurl {
        name = "kryo___kryo_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/kryo/-/kryo-0.6.1.tgz";
        sha1 = "5fd1ab6cb30b67840357bc363fadd7d2d1980eb0";
      };
    }
    {
      name = "kuler___kuler_1.0.1.tgz";
      path = fetchurl {
        name = "kuler___kuler_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/kuler/-/kuler-1.0.1.tgz";
        sha1 = "ef7c784f36c9fb6e16dd3150d152677b2b0228a6";
      };
    }
    {
      name = "lie___lie_3.1.1.tgz";
      path = fetchurl {
        name = "lie___lie_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/lie/-/lie-3.1.1.tgz";
        sha1 = "9a436b2cc7746ca59de7a41fa469b3efb76bd87e";
      };
    }
    {
      name = "localforage___localforage_1.7.3.tgz";
      path = fetchurl {
        name = "localforage___localforage_1.7.3.tgz";
        url  = "https://registry.yarnpkg.com/localforage/-/localforage-1.7.3.tgz";
        sha1 = "0082b3ca9734679e1bd534995bdd3b24cf10f204";
      };
    }
    {
      name = "lodash___lodash_4.17.14.tgz";
      path = fetchurl {
        name = "lodash___lodash_4.17.14.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-4.17.14.tgz";
        sha1 = "9ce487ae66c96254fe20b599f21b6816028078ba";
      };
    }
    {
      name = "logform___logform_1.10.0.tgz";
      path = fetchurl {
        name = "logform___logform_1.10.0.tgz";
        url  = "https://registry.yarnpkg.com/logform/-/logform-1.10.0.tgz";
        sha1 = "c9d5598714c92b546e23f4e78147c40f1e02012e";
      };
    }
    {
      name = "logform___logform_2.1.2.tgz";
      path = fetchurl {
        name = "logform___logform_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/logform/-/logform-2.1.2.tgz";
        sha1 = "957155ebeb67a13164069825ce67ddb5bb2dd360";
      };
    }
    {
      name = "loglevel___loglevel_1.6.1.tgz";
      path = fetchurl {
        name = "loglevel___loglevel_1.6.1.tgz";
        url  = "https://registry.yarnpkg.com/loglevel/-/loglevel-1.6.1.tgz";
        sha1 = "e0fc95133b6ef276cdc8887cdaf24aa6f156f8fa";
      };
    }
    {
      name = "matrix_appservice_bridge___matrix_appservice_bridge_1.9.0.tgz";
      path = fetchurl {
        name = "matrix_appservice_bridge___matrix_appservice_bridge_1.9.0.tgz";
        url  = "https://registry.yarnpkg.com/matrix-appservice-bridge/-/matrix-appservice-bridge-1.9.0.tgz";
        sha1 = "240c0f01b57d623bec113e79c0f6708631b21ac2";
      };
    }
    {
      name = "matrix_appservice___matrix_appservice_0.3.5.tgz";
      path = fetchurl {
        name = "matrix_appservice___matrix_appservice_0.3.5.tgz";
        url  = "https://registry.yarnpkg.com/matrix-appservice/-/matrix-appservice-0.3.5.tgz";
        sha1 = "41479f3aabe3582d72e32a6815f44cc624833ce1";
      };
    }
    {
      name = "matrix_js_sdk___matrix_js_sdk_1.2.0.tgz";
      path = fetchurl {
        name = "matrix_js_sdk___matrix_js_sdk_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/matrix-js-sdk/-/matrix-js-sdk-1.2.0.tgz";
        sha1 = "1e18f7bead2b31f1b6886299f3198f545eb7d19e";
      };
    }
    {
      name = "matrix_js_sdk___matrix_js_sdk_2.1.1.tgz";
      path = fetchurl {
        name = "matrix_js_sdk___matrix_js_sdk_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/matrix-js-sdk/-/matrix-js-sdk-2.1.1.tgz";
        sha1 = "c4d9ed81e18e2c2fce9fff168fdf41f37c390b6a";
      };
    }
    {
    name = "matrix-puppet-bridge";
    path =
      let
        repo = builtins.fetchGit {
          url = "https://github.com/arcnmx/matrix-puppet-bridge";
          ref = "0124de95411129f049b2dd6fd77ad3139054d7c2";
          rev = "0124de95411129f049b2dd6fd77ad3139054d7c2";
        };
      in
        runCommandNoCC "matrix-puppet-bridge" { buildInputs = [gnutar]; } ''
          # Set u+w because tar-fs can't unpack archives with read-only dirs
          # https://github.com/mafintosh/tar-fs/issues/79
          tar cf $out --mode u+w -C ${repo} .
        '';
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
      name = "merge_descriptors___merge_descriptors_1.0.1.tgz";
      path = fetchurl {
        name = "merge_descriptors___merge_descriptors_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/merge-descriptors/-/merge-descriptors-1.0.1.tgz";
        sha1 = "b00aaa556dd8b44568150ec9d1b953f3f90cbb61";
      };
    }
    {
      name = "methods___methods_1.1.2.tgz";
      path = fetchurl {
        name = "methods___methods_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/methods/-/methods-1.1.2.tgz";
        sha1 = "5529a4d67654134edcc5266656835b0f851afcee";
      };
    }
    {
      name = "mime_db___mime_db_1.40.0.tgz";
      path = fetchurl {
        name = "mime_db___mime_db_1.40.0.tgz";
        url  = "https://registry.yarnpkg.com/mime-db/-/mime-db-1.40.0.tgz";
        sha1 = "a65057e998db090f732a68f6c276d387d4126c32";
      };
    }
    {
      name = "mime_types___mime_types_2.1.24.tgz";
      path = fetchurl {
        name = "mime_types___mime_types_2.1.24.tgz";
        url  = "https://registry.yarnpkg.com/mime-types/-/mime-types-2.1.24.tgz";
        sha1 = "b6f8d0b3e951efb77dedeca194cff6d16f676f81";
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
      name = "minimatch___minimatch_3.0.4.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-3.0.4.tgz";
        sha1 = "5166e286457f03306064be5497e8dbb0c3d32083";
      };
    }
    {
      name = "minimist___minimist_0.0.8.tgz";
      path = fetchurl {
        name = "minimist___minimist_0.0.8.tgz";
        url  = "https://registry.yarnpkg.com/minimist/-/minimist-0.0.8.tgz";
        sha1 = "857fcabfc3397d2625b8228262e86aa7a011b05d";
      };
    }
    {
      name = "mkdirp___mkdirp_0.5.1.tgz";
      path = fetchurl {
        name = "mkdirp___mkdirp_0.5.1.tgz";
        url  = "https://registry.yarnpkg.com/mkdirp/-/mkdirp-0.5.1.tgz";
        sha1 = "30057438eac6cf7f8c4767f38648d6697d75c903";
      };
    }
    {
      name = "moment___moment_2.24.0.tgz";
      path = fetchurl {
        name = "moment___moment_2.24.0.tgz";
        url  = "https://registry.yarnpkg.com/moment/-/moment-2.24.0.tgz";
        sha1 = "0d055d53f5052aa653c9f6eb68bb5d12bf5c2b5b";
      };
    }
    {
      name = "morgan___morgan_1.9.1.tgz";
      path = fetchurl {
        name = "morgan___morgan_1.9.1.tgz";
        url  = "https://registry.yarnpkg.com/morgan/-/morgan-1.9.1.tgz";
        sha1 = "0a8d16734a1d9afbc824b99df87e738e58e2da59";
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
      name = "ms___ms_2.1.1.tgz";
      path = fetchurl {
        name = "ms___ms_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-2.1.1.tgz";
        sha1 = "30a5864eb3ebb0a66f2ebe6d727af06a09d86e0a";
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
      name = "mute_stream___mute_stream_0.0.8.tgz";
      path = fetchurl {
        name = "mute_stream___mute_stream_0.0.8.tgz";
        url  = "https://registry.yarnpkg.com/mute-stream/-/mute-stream-0.0.8.tgz";
        sha1 = "1630c42b2251ff81e2a283de96a5497ea92e5e0d";
      };
    }
    {
      name = "nedb___nedb_1.8.0.tgz";
      path = fetchurl {
        name = "nedb___nedb_1.8.0.tgz";
        url  = "https://registry.yarnpkg.com/nedb/-/nedb-1.8.0.tgz";
        sha1 = "0e3502cd82c004d5355a43c9e55577bd7bd91d88";
      };
    }
    {
      name = "needle___needle_1.6.0.tgz";
      path = fetchurl {
        name = "needle___needle_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/needle/-/needle-1.6.0.tgz";
        sha1 = "f52a5858972121618e002f8e6384cadac22d624f";
      };
    }
    {
      name = "negotiator___negotiator_0.6.2.tgz";
      path = fetchurl {
        name = "negotiator___negotiator_0.6.2.tgz";
        url  = "https://registry.yarnpkg.com/negotiator/-/negotiator-0.6.2.tgz";
        sha1 = "feacf7ccf525a77ae9634436a64883ffeca346fb";
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
      name = "nth_check___nth_check_1.0.2.tgz";
      path = fetchurl {
        name = "nth_check___nth_check_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/nth-check/-/nth-check-1.0.2.tgz";
        sha1 = "b2bd295c37e3dd58a3bf0700376663ba4d9cf05c";
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
      name = "object_hash___object_hash_1.3.1.tgz";
      path = fetchurl {
        name = "object_hash___object_hash_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/object-hash/-/object-hash-1.3.1.tgz";
        sha1 = "fde452098a951cb145f039bb7d455449ddc126df";
      };
    }
    {
      name = "object_inspect___object_inspect_1.6.0.tgz";
      path = fetchurl {
        name = "object_inspect___object_inspect_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/object-inspect/-/object-inspect-1.6.0.tgz";
        sha1 = "c70b6cbf72f274aab4c34c0c82f5167bf82cf15b";
      };
    }
    {
      name = "https___packages.matrix.org_npm_olm_olm_3.0.0.tgz";
      path = fetchurl {
        name = "https___packages.matrix.org_npm_olm_olm_3.0.0.tgz";
        url  = "https://packages.matrix.org/npm/olm/olm-3.0.0.tgz";
        sha1 = "4a6f5e83c5c4d05a268246a5db9bdf0e720311b1";
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
      name = "on_headers___on_headers_1.0.2.tgz";
      path = fetchurl {
        name = "on_headers___on_headers_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/on-headers/-/on-headers-1.0.2.tgz";
        sha1 = "772b0ae6aaa525c399e489adfad90c403eb3c28f";
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
      name = "one_time___one_time_0.0.4.tgz";
      path = fetchurl {
        name = "one_time___one_time_0.0.4.tgz";
        url  = "https://registry.yarnpkg.com/one-time/-/one-time-0.0.4.tgz";
        sha1 = "f8cdf77884826fe4dff93e3a9cc37b1e4480742e";
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
      name = "parse5___parse5_3.0.3.tgz";
      path = fetchurl {
        name = "parse5___parse5_3.0.3.tgz";
        url  = "https://registry.yarnpkg.com/parse5/-/parse5-3.0.3.tgz";
        sha1 = "042f792ffdd36851551cf4e9e066b3874ab45b5c";
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
      name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
      path = fetchurl {
        name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
        sha1 = "174b9268735534ffbc7ace6bf53a5a9e1b5c5f5f";
      };
    }
    {
      name = "path_to_regexp___path_to_regexp_0.1.7.tgz";
      path = fetchurl {
        name = "path_to_regexp___path_to_regexp_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/path-to-regexp/-/path-to-regexp-0.1.7.tgz";
        sha1 = "df604178005f522f15eb4490e7247a1bfaa67f8c";
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
      name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
      path = fetchurl {
        name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/process-nextick-args/-/process-nextick-args-2.0.1.tgz";
        sha1 = "7820d9b16120cc55ca9ae7792680ae7dba6d7fe2";
      };
    }
    {
      name = "prom_client___prom_client_11.5.3.tgz";
      path = fetchurl {
        name = "prom_client___prom_client_11.5.3.tgz";
        url  = "https://registry.yarnpkg.com/prom-client/-/prom-client-11.5.3.tgz";
        sha1 = "5fedfce1083bac6c2b223738e966d0e1643756f8";
      };
    }
    {
      name = "proxy_addr___proxy_addr_2.0.5.tgz";
      path = fetchurl {
        name = "proxy_addr___proxy_addr_2.0.5.tgz";
        url  = "https://registry.yarnpkg.com/proxy-addr/-/proxy-addr-2.0.5.tgz";
        sha1 = "34cbd64a2d81f4b1fd21e76f9f06c8a45299ee34";
      };
    }
    {
      name = "psl___psl_1.2.0.tgz";
      path = fetchurl {
        name = "psl___psl_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/psl/-/psl-1.2.0.tgz";
        sha1 = "df12b5b1b3a30f51c329eacbdef98f3a6e136dc6";
      };
    }
    {
      name = "punycode___punycode_1.4.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.4.1.tgz";
        sha1 = "c0d5a63b2718800ad8e1eb0fa5269c84dd41845e";
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
      name = "qs___qs_6.7.0.tgz";
      path = fetchurl {
        name = "qs___qs_6.7.0.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-6.7.0.tgz";
        sha1 = "41dc1a015e3d581f1621776be31afb2876a9b1bc";
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
      name = "range_parser___range_parser_1.2.1.tgz";
      path = fetchurl {
        name = "range_parser___range_parser_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/range-parser/-/range-parser-1.2.1.tgz";
        sha1 = "3cf37023d199e1c24d1a55b84800c2f3e6468031";
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
      name = "read___read_1.0.7.tgz";
      path = fetchurl {
        name = "read___read_1.0.7.tgz";
        url  = "https://registry.yarnpkg.com/read/-/read-1.0.7.tgz";
        sha1 = "b3da19bd052431a97671d44a42634adf710b40c4";
      };
    }
    {
      name = "readable_stream___readable_stream_2.3.6.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_2.3.6.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-2.3.6.tgz";
        sha1 = "b11c27d88b8ff1fbe070643cf94b0c79ae1b0aaf";
      };
    }
    {
      name = "readable_stream___readable_stream_3.4.0.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_3.4.0.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-3.4.0.tgz";
        sha1 = "a51c26754658e0a3c21dbf59163bd45ba6f447fc";
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
      name = "request___request_2.88.0.tgz";
      path = fetchurl {
        name = "request___request_2.88.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.88.0.tgz";
        sha1 = "9c2fca4f7d35b592efe57c7f0a55e81052124fef";
      };
    }
    {
      name = "rimraf___rimraf_2.6.3.tgz";
      path = fetchurl {
        name = "rimraf___rimraf_2.6.3.tgz";
        url  = "https://registry.yarnpkg.com/rimraf/-/rimraf-2.6.3.tgz";
        sha1 = "b2d104fe0d8fb27cf9e0a1cda8262dd3833c6cab";
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
      name = "safe_buffer___safe_buffer_5.2.0.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.0.tgz";
        sha1 = "b74daec49b1148f88c64b68d49b1e815c1f2f519";
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
      name = "semver___semver_6.2.0.tgz";
      path = fetchurl {
        name = "semver___semver_6.2.0.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-6.2.0.tgz";
        sha1 = "4d813d9590aaf8a9192693d6c85b9344de5901db";
      };
    }
    {
      name = "send___send_0.17.1.tgz";
      path = fetchurl {
        name = "send___send_0.17.1.tgz";
        url  = "https://registry.yarnpkg.com/send/-/send-0.17.1.tgz";
        sha1 = "c1d8b059f7900f7466dd4938bdc44e11ddb376c8";
      };
    }
    {
      name = "serve_static___serve_static_1.14.1.tgz";
      path = fetchurl {
        name = "serve_static___serve_static_1.14.1.tgz";
        url  = "https://registry.yarnpkg.com/serve-static/-/serve-static-1.14.1.tgz";
        sha1 = "666e636dc4f010f7ef29970a88a674320898b2f9";
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
      name = "simple_swizzle___simple_swizzle_0.2.2.tgz";
      path = fetchurl {
        name = "simple_swizzle___simple_swizzle_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/simple-swizzle/-/simple-swizzle-0.2.2.tgz";
        sha1 = "a4da6b635ffcccca33f70d17cb92592de95e557a";
      };
    }
    {
      name = "skype_http___skype_http_0.0.15.tgz";
      path = fetchurl {
        name = "skype_http___skype_http_0.0.15.tgz";
        url  = "https://registry.yarnpkg.com/skype-http/-/skype-http-0.0.15.tgz";
        sha1 = "1b15f521031777b9115c9248f62227380dc50f8d";
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
      name = "stack_trace___stack_trace_0.0.10.tgz";
      path = fetchurl {
        name = "stack_trace___stack_trace_0.0.10.tgz";
        url  = "https://registry.yarnpkg.com/stack-trace/-/stack-trace-0.0.10.tgz";
        sha1 = "547c70b347e8d32b4e108ea1a2a159e5fdde19c0";
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
      name = "string_decoder___string_decoder_1.2.0.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.2.0.tgz";
        sha1 = "fe86e738b19544afe70469243b2a1ee9240eae8d";
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
      name = "striptags___striptags_3.1.1.tgz";
      path = fetchurl {
        name = "striptags___striptags_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/striptags/-/striptags-3.1.1.tgz";
        sha1 = "c8c3e7fdd6fb4bb3a32a3b752e5b5e3e38093ebd";
      };
    }
    {
      name = "supports_color___supports_color_5.5.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_5.5.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-5.5.0.tgz";
        sha1 = "e2e69a44ac8772f78a1ec0b35b689df6530efc8f";
      };
    }
    {
      name = "tdigest___tdigest_0.1.1.tgz";
      path = fetchurl {
        name = "tdigest___tdigest_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/tdigest/-/tdigest-0.1.1.tgz";
        sha1 = "2e3cb2c39ea449e55d1e6cd91117accca4588021";
      };
    }
    {
      name = "tempfile___tempfile_1.1.1.tgz";
      path = fetchurl {
        name = "tempfile___tempfile_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/tempfile/-/tempfile-1.1.1.tgz";
        sha1 = "5bcc4eaecc4ab2c707d8bc11d99ccc9a2cb287f2";
      };
    }
    {
      name = "text_hex___text_hex_1.0.0.tgz";
      path = fetchurl {
        name = "text_hex___text_hex_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/text-hex/-/text-hex-1.0.0.tgz";
        sha1 = "69dc9c1b17446ee79a92bf5b884bb4b9127506f5";
      };
    }
    {
      name = "tmp_promise___tmp_promise_1.1.0.tgz";
      path = fetchurl {
        name = "tmp_promise___tmp_promise_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/tmp-promise/-/tmp-promise-1.1.0.tgz";
        sha1 = "bb924d239029157b9bc1d506a6aa341f8b13e64c";
      };
    }
    {
      name = "tmp___tmp_0.1.0.tgz";
      path = fetchurl {
        name = "tmp___tmp_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/tmp/-/tmp-0.1.0.tgz";
        sha1 = "ee434a4e22543082e294ba6201dcc6eafefa2877";
      };
    }
    {
      name = "tmp___tmp_0.0.31.tgz";
      path = fetchurl {
        name = "tmp___tmp_0.0.31.tgz";
        url  = "https://registry.yarnpkg.com/tmp/-/tmp-0.0.31.tgz";
        sha1 = "8f38ab9438e17315e5dbd8b3657e8bfb277ae4a7";
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
      name = "tough_cookie___tough_cookie_2.5.0.tgz";
      path = fetchurl {
        name = "tough_cookie___tough_cookie_2.5.0.tgz";
        url  = "https://registry.yarnpkg.com/tough-cookie/-/tough-cookie-2.5.0.tgz";
        sha1 = "cd9fb2a0aa1d5a12b473bd9fb96fa3dcff65ade2";
      };
    }
    {
      name = "tough_cookie___tough_cookie_2.4.3.tgz";
      path = fetchurl {
        name = "tough_cookie___tough_cookie_2.4.3.tgz";
        url  = "https://registry.yarnpkg.com/tough-cookie/-/tough-cookie-2.4.3.tgz";
        sha1 = "53f36da3f47783b0925afa06ff9f3b165280f781";
      };
    }
    {
      name = "triple_beam___triple_beam_1.3.0.tgz";
      path = fetchurl {
        name = "triple_beam___triple_beam_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/triple-beam/-/triple-beam-1.3.0.tgz";
        sha1 = "a595214c7298db8339eeeee083e4d10bd8cb8dd9";
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
      name = "tweetnacl___tweetnacl_0.14.5.tgz";
      path = fetchurl {
        name = "tweetnacl___tweetnacl_0.14.5.tgz";
        url  = "https://registry.yarnpkg.com/tweetnacl/-/tweetnacl-0.14.5.tgz";
        sha1 = "5ae68177f192d4456269d108afa93ff8743f4f64";
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
      name = "typedarray___typedarray_0.0.6.tgz";
      path = fetchurl {
        name = "typedarray___typedarray_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/typedarray/-/typedarray-0.0.6.tgz";
        sha1 = "867ac74e3864187b1d3d47d996a78ec5c8830777";
      };
    }
    {
      name = "underscore___underscore_1.4.4.tgz";
      path = fetchurl {
        name = "underscore___underscore_1.4.4.tgz";
        url  = "https://registry.yarnpkg.com/underscore/-/underscore-1.4.4.tgz";
        sha1 = "61a6a32010622afa07963bf325203cf12239d604";
      };
    }
    {
      name = "unhomoglyph___unhomoglyph_1.0.2.tgz";
      path = fetchurl {
        name = "unhomoglyph___unhomoglyph_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/unhomoglyph/-/unhomoglyph-1.0.2.tgz";
        sha1 = "d69e5f5a6a1c6b211941a0889b81eba86595c253";
      };
    }
    {
      name = "unorm___unorm_1.6.0.tgz";
      path = fetchurl {
        name = "unorm___unorm_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/unorm/-/unorm-1.6.0.tgz";
        sha1 = "029b289661fba714f1a9af439eb51d9b16c205af";
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
      name = "uri_js___uri_js_4.2.2.tgz";
      path = fetchurl {
        name = "uri_js___uri_js_4.2.2.tgz";
        url  = "https://registry.yarnpkg.com/uri-js/-/uri-js-4.2.2.tgz";
        sha1 = "94c540e1ff772956e2299507c010aea6c8838eb0";
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
      name = "uuid___uuid_3.3.2.tgz";
      path = fetchurl {
        name = "uuid___uuid_3.3.2.tgz";
        url  = "https://registry.yarnpkg.com/uuid/-/uuid-3.3.2.tgz";
        sha1 = "1b4af4955eb3077c501c23872fc6513811587131";
      };
    }
    {
      name = "vary___vary_1.1.2.tgz";
      path = fetchurl {
        name = "vary___vary_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/vary/-/vary-1.1.2.tgz";
        sha1 = "2299f02c6ded30d4a5961b0b9f74524a18f634fc";
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
      name = "which___which_1.3.1.tgz";
      path = fetchurl {
        name = "which___which_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/which/-/which-1.3.1.tgz";
        sha1 = "a45043d54f5805316da8d62f9f50918d3da70b0a";
      };
    }
    {
      name = "winston_compat___winston_compat_0.1.4.tgz";
      path = fetchurl {
        name = "winston_compat___winston_compat_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/winston-compat/-/winston-compat-0.1.4.tgz";
        sha1 = "599b4ce807ffe728713ecc25ede3f6b89425b739";
      };
    }
    {
      name = "winston_daily_rotate_file___winston_daily_rotate_file_3.10.0.tgz";
      path = fetchurl {
        name = "winston_daily_rotate_file___winston_daily_rotate_file_3.10.0.tgz";
        url  = "https://registry.yarnpkg.com/winston-daily-rotate-file/-/winston-daily-rotate-file-3.10.0.tgz";
        sha1 = "c49047d227f82a1f191c8298772aaeb7b67d5906";
      };
    }
    {
      name = "winston_transport___winston_transport_4.3.0.tgz";
      path = fetchurl {
        name = "winston_transport___winston_transport_4.3.0.tgz";
        url  = "https://registry.yarnpkg.com/winston-transport/-/winston-transport-4.3.0.tgz";
        sha1 = "df68c0c202482c448d9b47313c07304c2d7c2c66";
      };
    }
    {
      name = "winston___winston_3.2.1.tgz";
      path = fetchurl {
        name = "winston___winston_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/winston/-/winston-3.2.1.tgz";
        sha1 = "63061377976c73584028be2490a1846055f77f07";
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
      name = "xtend___xtend_4.0.2.tgz";
      path = fetchurl {
        name = "xtend___xtend_4.0.2.tgz";
        url  = "https://registry.yarnpkg.com/xtend/-/xtend-4.0.2.tgz";
        sha1 = "bb72779f5fa465186b1f438f674fa347fdb5db54";
      };
    }
  ];
}
