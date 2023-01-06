{ fetchurl }:
let
  fetchCosmo = { file, sha256 }: fetchurl {
    inherit sha256;
    url = "https://justine.storage.googleapis.com/cosmotests/2/${file}";
  };
in
[
  (fetchCosmo {
    file = "_timespec_test.com.dbg.gz";
    sha256 = "fa12339aded86054bf0302eb4b046b16efd98b09262143058754516545bd0850";
  })
  (fetchCosmo {
    file = "_timespec_test.com.gz";
    sha256 = "c3b7a7ba984ce739aa18162e22278a9c09c83a8e8f5f8efc83ae1998b9bbf157";
  })
  (fetchCosmo {
    file = "a64l_test.com.dbg.gz";
    sha256 = "982088e75a02f0a4a232f58787dbf903c9beb4974b0cf104109e5c44ca05cf78";
  })
  (fetchCosmo {
    file = "a64l_test.com.gz";
    sha256 = "357d44b371c926ffe75f13d0032d631f4c6fed7c7c0c2db435b8df0e9f2d65ba";
  })
  (fetchCosmo {
    file = "abort_test.com.dbg.gz";
    sha256 = "34ad05dd7a1bb1dae333eb71abf331deabb4241ad45365bcfcbf483c4f52407d";
  })
  (fetchCosmo {
    file = "abort_test.com.gz";
    sha256 = "22e4212e190a087649fa492a7b657627e45522c2cb4385f446313374af039cae";
  })
  (fetchCosmo {
    file = "access_test.com.dbg.gz";
    sha256 = "068d2f7f40f0342735165150619758d562a67646c3ef1174adb474aa559d9a8b";
  })
  (fetchCosmo {
    file = "access_test.com.gz";
    sha256 = "8b8e02bcb2d33347352fa1938af581bc44875736985cc5db388b9aa225fcba54";
  })
  (fetchCosmo {
    file = "acos_test.com.dbg.gz";
    sha256 = "eafa0f999536532a267e1bce8167ea68dd4b8ac458520900605c2cebf3e86212";
  })
  (fetchCosmo {
    file = "acos_test.com.gz";
    sha256 = "7a16aef2623076ed9b044e818cd5747a513ae2696def6be7ae9acd55b4c56967";
  })
  (fetchCosmo {
    file = "acosh_test.com.dbg.gz";
    sha256 = "9d61ccb14173e9d8260a681891e4d071a20fca8eed10fdb073648a40e067bffb";
  })
  (fetchCosmo {
    file = "acosh_test.com.gz";
    sha256 = "7014d4a2ccc0309b460ba104d16363be3b4407d4c68463b080a0be924a223069";
  })
  (fetchCosmo {
    file = "alaw_test.com.dbg.gz";
    sha256 = "72bc44ff7ac030961463e7754b9401c796fc7cb2785cf5364b55a556ea82116f";
  })
  (fetchCosmo {
    file = "alaw_test.com.gz";
    sha256 = "dd24f1f8b0ce26c9c2220d5d656dfee04cb0e2603186b377f468d84dd65f676f";
  })
  (fetchCosmo {
    file = "alu_test.com.dbg.gz";
    sha256 = "63dcd6c6319ecf0c435f625a81916dfe300ba5d2cc04f5e4a22aece0a3d0d79e";
  })
  (fetchCosmo {
    file = "alu_test.com.gz";
    sha256 = "3c0ff6cfea18e9a090b9daf53565060ca17c11b2fc51eda22d880a3664c70969";
  })
  (fetchCosmo {
    file = "appendresourcereport_test.com.dbg.gz";
    sha256 = "25532fa6b62bef9b6bcf1c659c54de8aefeace6fec037453bd543369ddc7222b";
  })
  (fetchCosmo {
    file = "appendresourcereport_test.com.gz";
    sha256 = "78ffae83701234644a838a5b113bf13b6afbe21eb676a3f4edb66f3621d2477f";
  })
  (fetchCosmo {
    file = "arch_prctl_test.com.dbg.gz";
    sha256 = "e9c76b6970e1683170ea6b578a2d784e8071248ac0ee0ec22c8f0a5e4b2ed1f3";
  })
  (fetchCosmo {
    file = "arch_prctl_test.com.gz";
    sha256 = "a5962f5fb4f7bfa873f3462c2cf79de7afed0b337b9a05ddc4b501280746c66c";
  })
  (fetchCosmo {
    file = "arena_test.com.dbg.gz";
    sha256 = "5ff1492cb39bcf225832c23d57c442caa43b98f19e7a5dd16011fc07f082f156";
  })
  (fetchCosmo {
    file = "arena_test.com.gz";
    sha256 = "453e4581f27ad4126c2d41a0161dea5266d7dd4d52fea4c89850c12e3e90918f";
  })
  (fetchCosmo {
    file = "argon2_test.com.dbg.gz";
    sha256 = "595e206c54898dc9aec0a2d53c0430df2922e297284ba00b3b918628e30eb130";
  })
  (fetchCosmo {
    file = "argon2_test.com.gz";
    sha256 = "a841ae0fedb12e241f0705abd40acae0289f42ddd652685681ba1d883f7c3d72";
  })
  (fetchCosmo {
    file = "args_test.com.dbg.gz";
    sha256 = "6373d461ea37dc728ec3009727615f0b60b00c7977a7152b6def3171b018ffd2";
  })
  (fetchCosmo {
    file = "args_test.com.gz";
    sha256 = "28635607ed1d0acdfc3f60ec4d6eb8aaa93e841efc7a565701617e15b8ebcae0";
  })
  (fetchCosmo {
    file = "arraylist_test.com.dbg.gz";
    sha256 = "80fbbf4a9fa6e0fc12b74d537ec59157cd78d3c52977bdfda2008861d0c4ddf5";
  })
  (fetchCosmo {
    file = "arraylist_test.com.gz";
    sha256 = "1f2c82e6cbaaf1a4c2689a5ef80d540fafdb92df39bb7f67d336e2432168bbc7";
  })
  (fetchCosmo {
    file = "asan_test.com.dbg.gz";
    sha256 = "5b2988255729a6ad830332ab1638943e406bce1a788f307905cea705401bb2d9";
  })
  (fetchCosmo {
    file = "asan_test.com.gz";
    sha256 = "32839f149c14c03462f0b0e20e058ee84537878ba63d219b89e18404be5c3997";
  })
  (fetchCosmo {
    file = "asin_test.com.dbg.gz";
    sha256 = "35b0623096815acbb7368e6601c3332986846701986978ea3ea536edf405807e";
  })
  (fetchCosmo {
    file = "asin_test.com.gz";
    sha256 = "a04c4c425038603ab019eb204a3a93c016389be4124cbefb9c9328a165e5afe2";
  })
  (fetchCosmo {
    file = "asinh_test.com.dbg.gz";
    sha256 = "95bee87bfc7d8e711cea21ad4c6266c4309e2db29db6d4bc57a3f844dff862d0";
  })
  (fetchCosmo {
    file = "asinh_test.com.gz";
    sha256 = "04c8ca48a79725053ce4d1e2c6d1e780eaa2a000670d5755e769447cc5664ef8";
  })
  (fetchCosmo {
    file = "asmdown_test.com.dbg.gz";
    sha256 = "e747fae8e36d2ce3949e185eb6bda987354b69fe3ed74165e1d611356f1b5bd2";
  })
  (fetchCosmo {
    file = "asmdown_test.com.gz";
    sha256 = "64723fde003e6181edcec818d29bd3f12b7b48e30e290ff228ea3c9c419f6836";
  })
  (fetchCosmo {
    file = "atan2_test.com.dbg.gz";
    sha256 = "ced5aea2869020e039ab537177c22d92dfeb0d379dbc06838203c09893327b68";
  })
  (fetchCosmo {
    file = "atan2_test.com.gz";
    sha256 = "e7bd88efe2006b4da980aa62610da79f5fc9960f76aed122e9ee3bb43b877085";
  })
  (fetchCosmo {
    file = "atan2l_test.com.dbg.gz";
    sha256 = "3622689fe93671bdf6f658a5cd59b0e7f02b70e414b64582b664add3188f3f1d";
  })
  (fetchCosmo {
    file = "atan2l_test.com.gz";
    sha256 = "40f8cef79643346a68694036a44c357c887a514df98ab69d84b0fe0f03741e6a";
  })
  (fetchCosmo {
    file = "atan_test.com.dbg.gz";
    sha256 = "3ea187c5bb2f7426e5a12ce10c6632abaf33c8c8d70fc85b4972104f5669eb10";
  })
  (fetchCosmo {
    file = "atan_test.com.gz";
    sha256 = "ad9cce522b51d0ca2260e44c9eb1f54d9af5e072d6886e80ceed6ceb8462c191";
  })
  (fetchCosmo {
    file = "atanh_test.com.dbg.gz";
    sha256 = "62302916e428e3fea613839a175958a8113fa271ed097625360ab5fa1c5609d4";
  })
  (fetchCosmo {
    file = "atanh_test.com.gz";
    sha256 = "c139ad097ba3f49b6b3a73423e30300439010723fd5e3e4e95b2e7eecd0bf1f6";
  })
  (fetchCosmo {
    file = "atanl_test.com.dbg.gz";
    sha256 = "2a75bda2e3b24d048f912404a03b8cc39a5362978b945f481f4fcaeede71a44d";
  })
  (fetchCosmo {
    file = "atanl_test.com.gz";
    sha256 = "0f325b80be7495b275ab7434266156620f352ddc95cd00244550e4481b4b5899";
  })
  (fetchCosmo {
    file = "atoi_test.com.dbg.gz";
    sha256 = "e004edefa7a8d663dfe11c4b0b83db50d8a82f60d5d27a88148ab342118c7bd9";
  })
  (fetchCosmo {
    file = "atoi_test.com.gz";
    sha256 = "4fe27818721ae622163deda1807de2c7e9518509fe34fecedea864e071387a19";
  })
  (fetchCosmo {
    file = "backtrace_test.com.dbg.gz";
    sha256 = "7e813c31dd843dfac077b060ce2dac58bd202050d786c1110bfa2d371f567a0a";
  })
  (fetchCosmo {
    file = "backtrace_test.com.gz";
    sha256 = "7765421e7a4482987987395fbf9b4100481e24000873861ec4cc9392f68c54ea";
  })
  (fetchCosmo {
    file = "basename_test.com.dbg.gz";
    sha256 = "eb43fd8323e71358b51d181040d72b7436ed800185e288455da42c0ee94dc66e";
  })
  (fetchCosmo {
    file = "basename_test.com.gz";
    sha256 = "622bb8e8c63813a7e35d6b6936ea18175db51d5acd1b30f3625dc58a27367058";
  })
  (fetchCosmo {
    file = "bextra_test.com.dbg.gz";
    sha256 = "55bb4effc5aaadd8894d87071d1cb8ef2b3750dd0b25255caa893c759281cd92";
  })
  (fetchCosmo {
    file = "bextra_test.com.gz";
    sha256 = "f119bfaa8656abd4910116c2cc848f9f9b8f744bc7925539029c6655558629fb";
  })
  (fetchCosmo {
    file = "bilinearscale_test.com.dbg.gz";
    sha256 = "266470a52146d2f4f826b1dce97c30e595733db8193283c27e405d474bec9820";
  })
  (fetchCosmo {
    file = "bilinearscale_test.com.gz";
    sha256 = "7f2a3fb0c2e0e5c044098a4f70ed22297be58e7a9016e03120b060ce32f4feb2";
  })
  (fetchCosmo {
    file = "bisectcarleft_test.com.dbg.gz";
    sha256 = "778c6447439d6a4fede508caec4efd1ef5a884583ac53ad0eef7b41f86b4388f";
  })
  (fetchCosmo {
    file = "bisectcarleft_test.com.gz";
    sha256 = "3f6a472986af28c2843ca136b81c5b8f2076d1c8e3589ebe73a316bc3813ddd6";
  })
  (fetchCosmo {
    file = "bitreverse_test.com.dbg.gz";
    sha256 = "44a3a0d9d8e178d2051320f5f788ec92727bfd901e96dd63bd52855a75756c45";
  })
  (fetchCosmo {
    file = "bitreverse_test.com.gz";
    sha256 = "8a29e1489a7eea7cde052ff365d1d3cc4007931650aded9fa1e45cd4f7ddbb78";
  })
  (fetchCosmo {
    file = "bitscan_test.com.dbg.gz";
    sha256 = "f22d82cb3b4f093350f970c0a93466054310536ffa3736ca5f7537ae6b1e0777";
  })
  (fetchCosmo {
    file = "bitscan_test.com.gz";
    sha256 = "ff47676e77c86e30dd2a494a147a03480cfd6972d62297d8820c7bd815d91bdb";
  })
  (fetchCosmo {
    file = "blake2_test.com.dbg.gz";
    sha256 = "ab740fa25d488c61f8d3c97d85a6d7ed245eda7db46c021e504a5d7dd67dd52b";
  })
  (fetchCosmo {
    file = "blake2_test.com.gz";
    sha256 = "ba75e9c763e6b9e04d27eac3d19756d2042665a35ebe660ba53755ce9930159a";
  })
  (fetchCosmo {
    file = "brk_test.com.dbg.gz";
    sha256 = "ffa8c9b9e3ee55f6ff070188a61cc4867629494b3e3c92ca6f39eb6723fc9d06";
  })
  (fetchCosmo {
    file = "brk_test.com.gz";
    sha256 = "5d8096d29734b06a5a89090a4777f4d0d327cf40e8d7ea531bf23ca096c0cf06";
  })
  (fetchCosmo {
    file = "bsr_test.com.dbg.gz";
    sha256 = "9692fbb184a838e114a91f7fae1a7372bd282b15066528d438ad8d2392de949a";
  })
  (fetchCosmo {
    file = "bsr_test.com.gz";
    sha256 = "2bfba82ff99edd0016c4653fd45695659246c8d767d67365c185d7625801fc4b";
  })
  (fetchCosmo {
    file = "bsu_test.com.dbg.gz";
    sha256 = "11ec6f7ca41a0b8a0ffb75c91c9c0c9c447ef07c5ccb5301037602071b401640";
  })
  (fetchCosmo {
    file = "bsu_test.com.gz";
    sha256 = "60560521f307362fea76aadd318e54722b410938913e451277c07dc589eb2d01";
  })
  (fetchCosmo {
    file = "bzero_test.com.dbg.gz";
    sha256 = "935e583ffb6cde1456d4cd8168f0cf784cdb835e3fec6505caa0712032504d57";
  })
  (fetchCosmo {
    file = "bzero_test.com.gz";
    sha256 = "ce50b8bfe5c17c672b582c0f64fb04e33f92b05abed6140ea25b95f42f803ea7";
  })
  (fetchCosmo {
    file = "cas_test.com.dbg.gz";
    sha256 = "c74e74ccd83fd5d1b2f3c2130c4fe1f8ec5751811aaf212c06d3daa085a4370b";
  })
  (fetchCosmo {
    file = "cas_test.com.gz";
    sha256 = "a06f56d1130decbede78e016c12b3ad0e0009d5d71c7cfda3fb0e7a543f4aaf5";
  })
  (fetchCosmo {
    file = "cbrt_test.com.dbg.gz";
    sha256 = "e2c0da571c8caf7107cacb81b3ee5527ecc74f39f3d1069dd411e0516b18edbd";
  })
  (fetchCosmo {
    file = "cbrt_test.com.gz";
    sha256 = "bb32cefe57adf35db078b350e088d05377a83a0925de3cc2b50c76eaba8b5334";
  })
  (fetchCosmo {
    file = "ceil_test.com.dbg.gz";
    sha256 = "80a722ccb8fb04e804a41a01cd0316897bedace988e0f9b05c4ed62f4bc78c32";
  })
  (fetchCosmo {
    file = "ceil_test.com.gz";
    sha256 = "b50e1b1a43ddd8c87625315947970ad2830403b8579d9489f449af2a76d40503";
  })
  (fetchCosmo {
    file = "cescapec_test.com.dbg.gz";
    sha256 = "a9cf870b8e7b27ed36e654af59985e9081988ce53b0410d9e0d88e1192834e50";
  })
  (fetchCosmo {
    file = "cescapec_test.com.gz";
    sha256 = "8b924769300d339d075b770c7f624f198ce0dc6bd6591745ca8a1e5f4197abc5";
  })
  (fetchCosmo {
    file = "chdir_test.com.dbg.gz";
    sha256 = "e19cf73faa244759f6e82faff92838e266534b827917e8c1d340ea04560a7b5b";
  })
  (fetchCosmo {
    file = "chdir_test.com.gz";
    sha256 = "69c4bf086b8634f0d8180f137074082aa34b60207d3d3874645cc21ca4f1f961";
  })
  (fetchCosmo {
    file = "classifypath_test.com.dbg.gz";
    sha256 = "e775f5a676ea102c6b19625ccd64f4832c1dbe4ecb6df23bcc79c13fd99ec463";
  })
  (fetchCosmo {
    file = "classifypath_test.com.gz";
    sha256 = "dd5004f6767fa4133e48a35b63de4225755be4f9e726aef1b6ce00e360d8f8d3";
  })
  (fetchCosmo {
    file = "clock_getres_test.com.dbg.gz";
    sha256 = "d08518297f0755c34e23efa6104fb95e46aabaf87eef18ecae0d3a18c2bbc5c7";
  })
  (fetchCosmo {
    file = "clock_getres_test.com.gz";
    sha256 = "d02ec8db1289abe22801fba032c5e34dce679757de6af32cbe0bc54d404df102";
  })
  (fetchCosmo {
    file = "clock_gettime_test.com.dbg.gz";
    sha256 = "eb4ede5bd65e9baeb0e291b5d4cb05b038336e8725c89f4479a2ed8931b5bc58";
  })
  (fetchCosmo {
    file = "clock_gettime_test.com.gz";
    sha256 = "8ef8e429de8463e7996a78f521694ac603ba6e6f04d5d309c1a0f962aded8fe4";
  })
  (fetchCosmo {
    file = "clock_nanosleep_test.com.dbg.gz";
    sha256 = "2d7fb960fdb5a237a3124e4f7690f25182419813d72780ed85c9cbb12320204d";
  })
  (fetchCosmo {
    file = "clock_nanosleep_test.com.gz";
    sha256 = "18229e4793a4b2259d9cbee49f35cddaf584895aacf5da8fb602535c7c49dba1";
  })
  (fetchCosmo {
    file = "clone_test.com.dbg.gz";
    sha256 = "5b668bc58fcb5487005ca4955ad231cc9b752248236b7ca353a9760b6beccb25";
  })
  (fetchCosmo {
    file = "clone_test.com.gz";
    sha256 = "5a0bd0b24e59a5455c5215ee1c1b3a9f0b541583e619c04eee7373d76e4dcb46";
  })
  (fetchCosmo {
    file = "closefrom_test.com.dbg.gz";
    sha256 = "8669576e16e5b4c679a00adfc90f5fbc36a7bb6cd403bcbd3ecef7c15d1e4b55";
  })
  (fetchCosmo {
    file = "closefrom_test.com.gz";
    sha256 = "b1c921218bcff2800994f5ac456d103245f3b69a33e8d5793a68ab785e1c5d05";
  })
  (fetchCosmo {
    file = "commandv_test.com.dbg.gz";
    sha256 = "a222485868f7657545a8d80220963600682f9c8e5bb440d6dadc7f41b2942140";
  })
  (fetchCosmo {
    file = "commandv_test.com.gz";
    sha256 = "20471cadc2c36cbe2873b41a1afd0cf458f95c196b4f2b3886e4bff1cc0658d5";
  })
  (fetchCosmo {
    file = "comparednsnames_test.com.dbg.gz";
    sha256 = "defa40e435c97f32eddbd0847e698646a77f90dea62368f90df0791d3ea26d38";
  })
  (fetchCosmo {
    file = "comparednsnames_test.com.gz";
    sha256 = "d075469b2674731ee551f782de44e5878a7a6ef4c0d3adb9a95f220762abeeaf";
  })
  (fetchCosmo {
    file = "complex_test.com.dbg.gz";
    sha256 = "0fb2476848c1cc9415ac8d69a33f9fda8d74321a85a96943795d1ae1dc7b6587";
  })
  (fetchCosmo {
    file = "complex_test.com.gz";
    sha256 = "83ff8d48e8eedccf1bee680d01fff3305201254db5ce7be6cde39976afbb8d7c";
  })
  (fetchCosmo {
    file = "convoindex_test.com.dbg.gz";
    sha256 = "f0e6852e77edf7da16d61603a500dca2aaa21302bc5c414a734df950a00be3eb";
  })
  (fetchCosmo {
    file = "convoindex_test.com.gz";
    sha256 = "bcbaf8f248b9a8063208aee1c71ce578abf4e56eeabc7c4230485a0f3e6f148c";
  })
  (fetchCosmo {
    file = "copy_file_range_test.com.dbg.gz";
    sha256 = "0a1951ec14ece54f79cbae0e1f0118e11960fd7c6a510796076ea648f8c760fd";
  })
  (fetchCosmo {
    file = "copy_file_range_test.com.gz";
    sha256 = "a3aa9d2a395a995ff807fc65e2762486c558c00869e908217688aed335c21c25";
  })
  (fetchCosmo {
    file = "copysign_test.com.dbg.gz";
    sha256 = "9c6d84ac6cf730341ec3c265a7627ba80e17f5fd6b63885f42dc835ab3ba2a13";
  })
  (fetchCosmo {
    file = "copysign_test.com.gz";
    sha256 = "c4ef5a596afa9edce6060bb1cf33e212adc584aa79597306f78a6bb77b8dd4d3";
  })
  (fetchCosmo {
    file = "cos_test.com.dbg.gz";
    sha256 = "9b996a21d476ef36f5a2b3e68ade6b28c992b289d80cbd75dc7549b12037d9dd";
  })
  (fetchCosmo {
    file = "cos_test.com.gz";
    sha256 = "74d5707fc9278a021fe0595c7cfa8dced23d01b67c8491b5f0d038ba7911a0d1";
  })
  (fetchCosmo {
    file = "cosh_test.com.dbg.gz";
    sha256 = "5fa9426db3cc97cac4b453b14344d229011a3df35a3ea081bc59961ab2673cca";
  })
  (fetchCosmo {
    file = "cosh_test.com.gz";
    sha256 = "06ad8a6b949342f9a49654eee1f8d821ced16fdc30883b9c3ed7b0ff658e2d41";
  })
  (fetchCosmo {
    file = "countbits_test.com.dbg.gz";
    sha256 = "0931c8b1a95b31ba79fb997e46de24e0f4ba0f5abd8631f929845ee26e7e2d24";
  })
  (fetchCosmo {
    file = "countbits_test.com.gz";
    sha256 = "679ddd4a5d9ad974c9b5fd9cea5aec0f53c93f61f393c531e374c911e0d3f236";
  })
  (fetchCosmo {
    file = "counter_test.com.dbg.gz";
    sha256 = "acf36a0f239a1655989d75ab9e21ed72a1ac5101870b0b9d5efeacf5dda01156";
  })
  (fetchCosmo {
    file = "counter_test.com.gz";
    sha256 = "4f2d8195128711bd57a89f607463e19b79e0b63c5dedc1c644060e36add16fde";
  })
  (fetchCosmo {
    file = "crc32_test.com.dbg.gz";
    sha256 = "1f65c501bde8591d68ffda8ebdad543183c554ed2eb75c6ee9150fe131192ea2";
  })
  (fetchCosmo {
    file = "crc32_test.com.gz";
    sha256 = "45cbe576a8422d9e7c833a58be5e2927654d41f4278a1e6d9b083253bdcf5715";
  })
  (fetchCosmo {
    file = "crc32c_test.com.dbg.gz";
    sha256 = "528ca4850bf85e04d6928afb9f411ec21172b1686c41fd7a1ee55d2731ec81ac";
  })
  (fetchCosmo {
    file = "crc32c_test.com.gz";
    sha256 = "a610fa92c4ad20c0f75b0bda95a7fb6385ba51f27aed39904b2eb52a79928466";
  })
  (fetchCosmo {
    file = "crc32z_test.com.dbg.gz";
    sha256 = "bf105b965394764931e561f66b1c97fee88943df713b7e73a08007333378b578";
  })
  (fetchCosmo {
    file = "crc32z_test.com.gz";
    sha256 = "7b06b218d2ddc84b81cf94f8bdedb9521d40e994a1bdef218b943cbc9c1b989e";
  })
  (fetchCosmo {
    file = "critbit0_test.com.dbg.gz";
    sha256 = "d535510105431718ab02cd5c0b26b5a187fec048cf474074b2363b2547736dd9";
  })
  (fetchCosmo {
    file = "critbit0_test.com.gz";
    sha256 = "a6925bc7aa799ec4d7e3139c41d937a6e8313150919c1a9c9d8e9b2a1a727354";
  })
  (fetchCosmo {
    file = "crypt_test.com.dbg.gz";
    sha256 = "8a7ee78079812b8eec204e9aa2d42e70bb3c5d43644591ca6b2f4cd26e04ba09";
  })
  (fetchCosmo {
    file = "crypt_test.com.gz";
    sha256 = "f3051bdd8a372fc268d1ed6feaf63cf4892118c3d5e6219d7ac3965dae7f465f";
  })
  (fetchCosmo {
    file = "csqrt_test.com.dbg.gz";
    sha256 = "9514c56a10dd4ec4d12d0c3fa617e0ba63a0b4188379e1e6860c6e80f08edb0a";
  })
  (fetchCosmo {
    file = "csqrt_test.com.gz";
    sha256 = "db746edc802a206f4492e36cb77ef7e114a5f68375589ac67e024f0c23331bfd";
  })
  (fetchCosmo {
    file = "cv_test.com.dbg.gz";
    sha256 = "73a267229f3e57bb3055b503359bd45d13f746638359d17521cd1b0c2b93332d";
  })
  (fetchCosmo {
    file = "cv_test.com.gz";
    sha256 = "818ca4be3091b383d30fc59ea1e6856920587598a8b316df2b32574a52dbbf85";
  })
  (fetchCosmo {
    file = "cv_wait_example_test.com.dbg.gz";
    sha256 = "fcd5aa3f02b389419ffe3ce5e353a92f7a05ac7b1fc07d7d40d2dda25ac651de";
  })
  (fetchCosmo {
    file = "cv_wait_example_test.com.gz";
    sha256 = "21552614d568300e2c5a640ce5d09dc6da91f88ef34b559f4dd5eed019039cb6";
  })
  (fetchCosmo {
    file = "daemon_test.com.dbg.gz";
    sha256 = "b9e101f31abe01184a7ddc287a867f8674b03660b580a7839618e4ff11173a61";
  })
  (fetchCosmo {
    file = "daemon_test.com.gz";
    sha256 = "3d1da0d45a074c3e7954b6d8dd48f1d1d7e609578dc2f36caff17d9240c824c5";
  })
  (fetchCosmo {
    file = "decodebase64_test.com.dbg.gz";
    sha256 = "42d8322b6f51ac749016618494b7d2e52c6cceb106cda4c946082594a4366efb";
  })
  (fetchCosmo {
    file = "decodebase64_test.com.gz";
    sha256 = "0ee7056a28076683ceea639b95c59994c61982bb9d8fdc7a1022eee051a0d78c";
  })
  (fetchCosmo {
    file = "decodelatin1_test.com.dbg.gz";
    sha256 = "be27123830ccd54d7f7a51aa86b30ecd2873dd12a1320145c9ae53e460f95ba1";
  })
  (fetchCosmo {
    file = "decodelatin1_test.com.gz";
    sha256 = "dff25ab23e92efd335424d58a8babb47b748b09ccaeac3dda5d24c4ed30ed937";
  })
  (fetchCosmo {
    file = "describeflags_test.com.dbg.gz";
    sha256 = "a449017ae2da3a6c0cef1fe95dcb778003fc82db75c7557be8e54f613e786c19";
  })
  (fetchCosmo {
    file = "describeflags_test.com.gz";
    sha256 = "66dc906949cedc1a3b72095818ad11a5cad340aab42d153a9fcb6b7fd1e25822";
  })
  (fetchCosmo {
    file = "describegidlist_test.com.dbg.gz";
    sha256 = "aaa18bf8477f97e2ce1e2feef90ff9315ac1a82bc4649abcf7fc66cbdf5d9b82";
  })
  (fetchCosmo {
    file = "describegidlist_test.com.gz";
    sha256 = "6dd8ed2169b520ecec44ef0ed705f10fc161edd1382740ec25b899bdb3c9bf01";
  })
  (fetchCosmo {
    file = "describesigset_test.com.dbg.gz";
    sha256 = "1aaa624108c672ca33d3d1773b638bcf24d32b1398c0437a3f1ed76940f55c1a";
  })
  (fetchCosmo {
    file = "describesigset_test.com.gz";
    sha256 = "529a2b88b10c6ce65e0b5edca4797a70aaa9dd91bbe895959e426ba85a648ad2";
  })
  (fetchCosmo {
    file = "describesyn_test.com.dbg.gz";
    sha256 = "3a377832ba050acb012d7986521fbdda771274d3210a65699b9d110e066c8584";
  })
  (fetchCosmo {
    file = "describesyn_test.com.gz";
    sha256 = "622c1b5f0e4b38cb30ed850bf1d9f410b1ea2be03383804230ad2b8ca586c458";
  })
  (fetchCosmo {
    file = "devrand_test.com.dbg.gz";
    sha256 = "c030012c9a7df15f8ab143fea81adb0489fe5bd96d60585395957411ec49e6d4";
  })
  (fetchCosmo {
    file = "devrand_test.com.gz";
    sha256 = "3acf250ccd56a6c6dacac55033ee3836ed1ebe8150cac496bb1b34608bcb6d8a";
  })
  (fetchCosmo {
    file = "diagnose_syscall_test.com.dbg.gz";
    sha256 = "b8b03d62918e2a43bdf2a81bce59ce1bf1ce4bd356d0a9bd529a798d17040041";
  })
  (fetchCosmo {
    file = "diagnose_syscall_test.com.gz";
    sha256 = "ed7e6b06d90ea153db108e32f64b2df2712ca7ed0519a399c149ce38a5758f9d";
  })
  (fetchCosmo {
    file = "dirname_test.com.dbg.gz";
    sha256 = "ce20bb2bbfdb12bbc74afe2a15b92f8e9e94735c578e9c9541dd859a056ce08a";
  })
  (fetchCosmo {
    file = "dirname_test.com.gz";
    sha256 = "139f1c57f929ef75b6ed31c5c2edeee4a81f9eca6af5d6bc83d4fe9407984930";
  })
  (fetchCosmo {
    file = "dirstream_test.com.dbg.gz";
    sha256 = "de9110cd7753c8012c1f62a0f3d1726859a1977c87ab2ff79178b67847941508";
  })
  (fetchCosmo {
    file = "dirstream_test.com.gz";
    sha256 = "bcf18629d26fc7325ee8b9e386add3d21b4b89e0e97ff0d4196ea710d4d5df0a";
  })
  (fetchCosmo {
    file = "disinst_test.com.dbg.gz";
    sha256 = "3b3e1fb6d5a8c24c331403bb39c0e4ee1b7ba72d11c35658a4f0c3a046197570";
  })
  (fetchCosmo {
    file = "disinst_test.com.gz";
    sha256 = "b0a85a2d21ed7c75ef892eee82d3d421fbb8ba746a182f899b223b423895e81d";
  })
  (fetchCosmo {
    file = "division_test.com.dbg.gz";
    sha256 = "888c5a8a6e9a21a9e0600e2e419c428f36d47277906827fe227b48d3645ffe64";
  })
  (fetchCosmo {
    file = "division_test.com.gz";
    sha256 = "f84e51b76b4b42682f9c4551527e342ea7163e492ce5f7bb2bc1f45eae64f91f";
  })
  (fetchCosmo {
    file = "divmul_test.com.dbg.gz";
    sha256 = "1e453a5a1912ca926aa9f58cb9809e1a97b75363f7c7a91fa65e20ae72bde60d";
  })
  (fetchCosmo {
    file = "divmul_test.com.gz";
    sha256 = "2352657fda319cc4ce8be01a27bd4d6c473c6f475baccc66bc7c8ccbf0bbcf25";
  })
  (fetchCosmo {
    file = "djbsort_test.com.dbg.gz";
    sha256 = "1e9be639a6b9a77043bfa68428537123d94ba60742c3be09f44be1fa8e3de5ba";
  })
  (fetchCosmo {
    file = "djbsort_test.com.gz";
    sha256 = "8bef821608dd4c02ab6c72736636f94966506d901a9cf6c31ae7968230361c66";
  })
  (fetchCosmo {
    file = "dll_test.com.dbg.gz";
    sha256 = "d5981e86b6f0842e74e229178c78b656dcbfe9fd64eada1d698f0f42710c24d8";
  })
  (fetchCosmo {
    file = "dll_test.com.gz";
    sha256 = "8b971b96037f68138eb651b605044de5f3a07805d6f39531b0e813f5e29e692e";
  })
  (fetchCosmo {
    file = "dnsheader_test.com.dbg.gz";
    sha256 = "e954742debdb2da636d48319eaffcbea71dac84056d83e4022c103bde201aa93";
  })
  (fetchCosmo {
    file = "dnsheader_test.com.gz";
    sha256 = "b69f392f4ec8a42035c58319fa477f46ae1a3319b1a1b437283536fcccad60f0";
  })
  (fetchCosmo {
    file = "dnsquestion_test.com.dbg.gz";
    sha256 = "dde4c771d0115fd1ffbcf42aba0fb2796b75c91af0a9d9bdfe2f624311faee52";
  })
  (fetchCosmo {
    file = "dnsquestion_test.com.gz";
    sha256 = "32c75cb6321e18255fa30c60d5f1e1ca2f309b27c721210bcee9f2fa0cb21cd9";
  })
  (fetchCosmo {
    file = "dos2errno_test.com.dbg.gz";
    sha256 = "821580e904b1e1e829566069bb63d69d8089b9f92c1f3c485f5438bca04ff1f2";
  })
  (fetchCosmo {
    file = "dos2errno_test.com.gz";
    sha256 = "ad7b70df8bfe3cd4e9e093593e91f389ba6c538f2b6ee299e9c7795a5dba013f";
  })
  (fetchCosmo {
    file = "dtoa_test.com.dbg.gz";
    sha256 = "a3e1dee2476b41f51ab0abb893d54101895309763b1460847fac3c4ecc18561e";
  })
  (fetchCosmo {
    file = "dtoa_test.com.gz";
    sha256 = "74a6a37ff6de513ee922d7dbfe6fc61ec0b764090a6498f09b3e170f56b2db78";
  })
  (fetchCosmo {
    file = "dumphexc_test.com.dbg.gz";
    sha256 = "b9c950d5caf173849cef0d06b4876edf215b44fc610d3862471ef8c67d193082";
  })
  (fetchCosmo {
    file = "dumphexc_test.com.gz";
    sha256 = "1c751e48e19db7d30ba11cb1b3c4d640dfd3803a23f5131f49ac0c75251a1748";
  })
  (fetchCosmo {
    file = "dup_test.com.dbg.gz";
    sha256 = "8c55589404c53b9c2256c8457a6eca35fd474e087bc82833b4152013d4ce3ada";
  })
  (fetchCosmo {
    file = "dup_test.com.gz";
    sha256 = "b0d44d5e2742631d92190d1c254fb0a7112f45eaef8f5089e673e3297a0616c7";
  })
  (fetchCosmo {
    file = "ecvt_test.com.dbg.gz";
    sha256 = "eb0d1f0035c5cfada08d16c7248d170a8f3063cb61f0aa42ec62b2b558044218";
  })
  (fetchCosmo {
    file = "ecvt_test.com.gz";
    sha256 = "62aca7a59cc63ab8c1e4983617d732c563fb44b2c46359151d62a09fb206b688";
  })
  (fetchCosmo {
    file = "encodebase64_test.com.dbg.gz";
    sha256 = "3c2e0556b7a50d22e9bd7ab7efabca281742b87df1ac52aca9a653f042efb1d5";
  })
  (fetchCosmo {
    file = "encodebase64_test.com.gz";
    sha256 = "96220cf7c44bcbd52bea0a98c60c7ae69b035c0cfba33a0181f31c510c2748b9";
  })
  (fetchCosmo {
    file = "encodehttpheadervalue_test.com.dbg.gz";
    sha256 = "3dbbd0449e9d181bfea6e9f09e79c1e8137bc1b2bd68d639b3f1bef75d9dca57";
  })
  (fetchCosmo {
    file = "encodehttpheadervalue_test.com.gz";
    sha256 = "4ced361c21efa3244bde457395eec7fba600da4d11b5c8332874323050c296a7";
  })
  (fetchCosmo {
    file = "encodenf32_test.com.dbg.gz";
    sha256 = "28dce62f74c28836fb40d80df468cd10e5928100c10795224b2b3cd39bb9a43c";
  })
  (fetchCosmo {
    file = "encodenf32_test.com.gz";
    sha256 = "183684169b5f21491589670ea1f11cfdc9269c156a7790f50b4521836857bd44";
  })
  (fetchCosmo {
    file = "erf_test.com.dbg.gz";
    sha256 = "f929bf2a5c1c08ca0114ab2c8df813da8e27238c9b28193eab3712238c35fc02";
  })
  (fetchCosmo {
    file = "erf_test.com.gz";
    sha256 = "024874ac43d8a823728526211ba3c632f8146c19c62a3de8ae141812f56a70d3";
  })
  (fetchCosmo {
    file = "escapehtml_test.com.dbg.gz";
    sha256 = "39359020db51ece1afb66674d29ac2ccc0664e09b757eb7ce38876dd811a75be";
  })
  (fetchCosmo {
    file = "escapehtml_test.com.gz";
    sha256 = "2b050bec54886e0015fa8285725db7899433e83d713f7cfc232454e7805043e9";
  })
  (fetchCosmo {
    file = "escapejsstringliteral_test.com.dbg.gz";
    sha256 = "ba7de5afcdd0b60e242c8ca5fd26d1c879c7e57265f4b47167b933bb23647f5a";
  })
  (fetchCosmo {
    file = "escapejsstringliteral_test.com.gz";
    sha256 = "ff19036f39314b79ba763e9d2b8efd1a028363d85d7eb1d045a2e77c47f92246";
  })
  (fetchCosmo {
    file = "escapeurlparam_test.com.dbg.gz";
    sha256 = "d40a3fce01402e5067a8f100ec365b29185643c7e22e3ba92cf54800028d6525";
  })
  (fetchCosmo {
    file = "escapeurlparam_test.com.gz";
    sha256 = "beb4ebb9980cdf184b8faff23fb205fed61f3b5d51d65895be49b2cea9e86201";
  })
  (fetchCosmo {
    file = "everest_test.com.dbg.gz";
    sha256 = "fcd3538c65fdf79298926bf60db8e192036aef20a023b8343a84e2d659118a70";
  })
  (fetchCosmo {
    file = "everest_test.com.gz";
    sha256 = "8fcd80bb2a6a387fca28e88194c7aed817df0ac8196c1a944ab4978c41df0f45";
  })
  (fetchCosmo {
    file = "execve_test.com.dbg.gz";
    sha256 = "f7fba42eda2fd4e5c3d82c26d5859aeb730fd8db12383d5562ce795d774359ec";
  })
  (fetchCosmo {
    file = "execve_test.com.gz";
    sha256 = "f2ba06720974702f0839595c48f6e133831fc57983c6b66bf4efe4e927d164d5";
  })
  (fetchCosmo {
    file = "exit_test.com.dbg.gz";
    sha256 = "9e6d84cd03dfecc50353bbbb57b7f98a83842b019c20d22c6e2886728ae50b2b";
  })
  (fetchCosmo {
    file = "exit_test.com.gz";
    sha256 = "08fe11832da07b07b93ffdeb3866833c0f387ac4fd202d5bba18758bbdf229ea";
  })
  (fetchCosmo {
    file = "exp10_test.com.dbg.gz";
    sha256 = "5a499407f67e49f8802055ad5ab2dd0b57155b8e3792eea7b152954341412d9f";
  })
  (fetchCosmo {
    file = "exp10_test.com.gz";
    sha256 = "419dfbcd489da36820a0b7ab5ef5763c79adc247a780454b3ef55ddb34a0a738";
  })
  (fetchCosmo {
    file = "exp2_test.com.dbg.gz";
    sha256 = "57581f377e8367350a78d5a6df055ff5f49d54adc275bb3a1aa384a158229438";
  })
  (fetchCosmo {
    file = "exp2_test.com.gz";
    sha256 = "3df7b8f4f1b55df55675c9ece30796d06f28962324dd02e3ea914d95e567fe5a";
  })
  (fetchCosmo {
    file = "exp2l_test.com.dbg.gz";
    sha256 = "a56b8b2a4d836a07357aa1a153ee6c1b008dd109e9fd44983e4917ced66283a7";
  })
  (fetchCosmo {
    file = "exp2l_test.com.gz";
    sha256 = "ec97de1b2f0ce4dd01c1a38fadf29b3e8fcb8b7d34411eec3d2bc6a178f1f9d1";
  })
  (fetchCosmo {
    file = "exp_test.com.dbg.gz";
    sha256 = "5b921c57f4500d272471972ce7ba39ca8852245f7903f36b5a920fd2bac145ff";
  })
  (fetchCosmo {
    file = "exp_test.com.gz";
    sha256 = "1aaa883df95c2eaa549e0f8a957f1e3d53119763732885221ef488250a2d81d8";
  })
  (fetchCosmo {
    file = "expm1_test.com.dbg.gz";
    sha256 = "bc3c4659476dba58bbd78534c8836686d24dca522ec5dbb63bb0151ae2c7df90";
  })
  (fetchCosmo {
    file = "expm1_test.com.gz";
    sha256 = "707244b76f3f0d5f234b170ef273ce9624d41d11b0be6be969ae8f97660ef4ba";
  })
  (fetchCosmo {
    file = "fabs_test.com.dbg.gz";
    sha256 = "ebe52d05e367c6871a82343fc8d133469e5041275e365c39335cc55a6fa45197";
  })
  (fetchCosmo {
    file = "fabs_test.com.gz";
    sha256 = "c0939b151a38ca4466cf24416baca690867031d6ecf572db22b1bc5db4dfdb4a";
  })
  (fetchCosmo {
    file = "fcntl_test.com.dbg.gz";
    sha256 = "53e79e4ff57961dbf8da716e3ceef7b8d7df6722867dbab07250a95da052ccbb";
  })
  (fetchCosmo {
    file = "fcntl_test.com.gz";
    sha256 = "6965b196983560ee194b7cf6d0482dbca359e7cdb24d3a5b0f45e5a20b7d54a1";
  })
  (fetchCosmo {
    file = "fexecve_test.com.dbg.gz";
    sha256 = "9a2bfd10596ad252b7bf1e16b4426bda828f3e815c8151192f953b857f492179";
  })
  (fetchCosmo {
    file = "fexecve_test.com.gz";
    sha256 = "9ef160684d51cd99cfcc5cfe4786e103a6a264af8ac3040a2a521d508cabc61d";
  })
  (fetchCosmo {
    file = "ffs_test.com.dbg.gz";
    sha256 = "c26b6688444328cb44bea36b003db023b2006e64ff3fdf5150be94e3bbaaad97";
  })
  (fetchCosmo {
    file = "ffs_test.com.gz";
    sha256 = "952325142ae09229ee367f16fd5f4defc649d2d4f3912455d3b041e99b1fa327";
  })
  (fetchCosmo {
    file = "fgetln_test.com.dbg.gz";
    sha256 = "0f39976f335ebbbd2a48166a7817198768f85e1e832022dfa2d194d61cb7097a";
  })
  (fetchCosmo {
    file = "fgetln_test.com.gz";
    sha256 = "cd05d32de9fa92095e82c63875016f88be1e27959f2c2286205ec3e2a7d4878b";
  })
  (fetchCosmo {
    file = "fgets_test.com.dbg.gz";
    sha256 = "ef772a9986faadd35dc800085b74b0451751268f6b0c3db941af42971af0aee7";
  })
  (fetchCosmo {
    file = "fgets_test.com.gz";
    sha256 = "9bb1038f2ff9c4e261611bb2ec1867720f66d299493456a022f2421f2fc3fec1";
  })
  (fetchCosmo {
    file = "fgetwc_test.com.dbg.gz";
    sha256 = "3e447feade39dec34f1375b581cbb80024dbd77478be2b2f7c77c33af1dc1fc6";
  })
  (fetchCosmo {
    file = "fgetwc_test.com.gz";
    sha256 = "c1b02407c34e04a14453df8f92d2b5efc1c9e1e56835fa269cc53d8cb4dd8e19";
  })
  (fetchCosmo {
    file = "fileexists_test.com.dbg.gz";
    sha256 = "dfbffe3ab1baec968b55715adedc52b24255945007447762e638bd6f6c894406";
  })
  (fetchCosmo {
    file = "fileexists_test.com.gz";
    sha256 = "84e5e23c7b8509fa2f944ceeb538e6b5b48c9429a426b95e3fca68e2004fda18";
  })
  (fetchCosmo {
    file = "findcontenttype_test.com.dbg.gz";
    sha256 = "9dc77af76868a67f1ec57f570ba5ae3f566d309de160811c7574971dc1d10347";
  })
  (fetchCosmo {
    file = "findcontenttype_test.com.gz";
    sha256 = "5b0b0d063c061bb5e816a02808f821786437689b6465df2f68727969af29442f";
  })
  (fetchCosmo {
    file = "fingersyn_test.com.dbg.gz";
    sha256 = "91c83b74eb7fdb1e9be4cac9da0708862be9941a1dc28aa7eae31deac049606c";
  })
  (fetchCosmo {
    file = "fingersyn_test.com.gz";
    sha256 = "4f1182402c1d8f37a8af146eef213ff35645625384dd11ebd6abfbe793a929e8";
  })
  (fetchCosmo {
    file = "floor_test.com.dbg.gz";
    sha256 = "0ee46adbe85e178438e6ab71086962084f79c2775896bef5e31e343e3ca315d9";
  })
  (fetchCosmo {
    file = "floor_test.com.gz";
    sha256 = "19e728034ecaabf7af6bb0c137821c144c12d6f57a7dc0159ebeb53965d2bbb3";
  })
  (fetchCosmo {
    file = "fmemopen_test.com.dbg.gz";
    sha256 = "90c63de8e428d93824e6bed71e794f917de91f199d0d0022fc392229edfa7adc";
  })
  (fetchCosmo {
    file = "fmemopen_test.com.gz";
    sha256 = "c3fadb837252eb9c2c6ccd9c2e1e7367cbf939462cc767241011066eed14e926";
  })
  (fetchCosmo {
    file = "fmod_test.com.dbg.gz";
    sha256 = "a3eab887743ee6c0da9fb4f95a6e9daadfd9f8b0f7fbfc373e0faf79171283ee";
  })
  (fetchCosmo {
    file = "fmod_test.com.gz";
    sha256 = "d8a66cb658cb014287270235fcdbf6558b099a357d2d8014e3fdb05de6b68d1b";
  })
  (fetchCosmo {
    file = "fmt_test.com.dbg.gz";
    sha256 = "ca665f87ab6c3ce727389e9cc4dcd78a5df10336083d756c548f468646a1f158";
  })
  (fetchCosmo {
    file = "fmt_test.com.gz";
    sha256 = "aebcc8bf062d47240b8beaaf37de823a017c90b3c3f0ef6384565f011c1e3325";
  })
  (fetchCosmo {
    file = "fork_test.com.dbg.gz";
    sha256 = "3215ac6defda3006fb65e84394340db0a7fd7c40e1969256f73580fb37e3515a";
  })
  (fetchCosmo {
    file = "fork_test.com.gz";
    sha256 = "4b108559419a474074c25956c7f89407638d6831b28f82ca418e094046b082e3";
  })
  (fetchCosmo {
    file = "formatbinary64_test.com.dbg.gz";
    sha256 = "9bb34dfcd79905192a191803153b3ef417d56da444c5caffac3e751834eecf89";
  })
  (fetchCosmo {
    file = "formatbinary64_test.com.gz";
    sha256 = "d84907df3aaa418c4773481329f2827e154e50933663a933f20cb4ca5badc44e";
  })
  (fetchCosmo {
    file = "formatflex64_test.com.dbg.gz";
    sha256 = "51ef84e3be99d7a0c4e7edc98087300d3632a9d983e665d11c3db2769edd2c18";
  })
  (fetchCosmo {
    file = "formatflex64_test.com.gz";
    sha256 = "ca0e5d4ad5eb8de0c433a4f2e8f9aba54bc1a86d74a368a7a6d9e4b2f6aebdfe";
  })
  (fetchCosmo {
    file = "formathex64_test.com.dbg.gz";
    sha256 = "afdfc9cfd0e7f84a21847eaffe6c975112c35b1cdaae9cde82e096e578dfdddd";
  })
  (fetchCosmo {
    file = "formathex64_test.com.gz";
    sha256 = "43c044e8bfde0c47966c5de7fce75faa3fe10b24a1139e5fc38aa8f9da70a610";
  })
  (fetchCosmo {
    file = "formathttpdatetime_test.com.dbg.gz";
    sha256 = "1948818dcae2c150b875001bad2eda5c2b5e75879e378fe1e52219a22a1bef74";
  })
  (fetchCosmo {
    file = "formathttpdatetime_test.com.gz";
    sha256 = "9baca7033b31f798e853902c9bb8504088f57c75a0c320602c6afa652d05c6ce";
  })
  (fetchCosmo {
    file = "formatint32_test.com.dbg.gz";
    sha256 = "ac33894de2c7904f6295e69ae27bc29530bb30d6753ef08978231bca7f206ac0";
  })
  (fetchCosmo {
    file = "formatint32_test.com.gz";
    sha256 = "fc1f834f09c14e51ffbcbc974d079494a05b8a457d01e1c262427f35e27e6c9d";
  })
  (fetchCosmo {
    file = "formatint64_test.com.dbg.gz";
    sha256 = "190ccd3b4911e0b0f73acb50291a2ad7099a3e452a45ba320988c94a7eec43f7";
  })
  (fetchCosmo {
    file = "formatint64_test.com.gz";
    sha256 = "6da02914bd7716e76e52e1eb2c918f638ffcb87cb2659c4b700af62f69a4c91a";
  })
  (fetchCosmo {
    file = "formatint64thousands_test.com.dbg.gz";
    sha256 = "8e60884f0cb117ee317e677b8b73a172f5fef7a162cdd6ee2c58698fc25cec51";
  })
  (fetchCosmo {
    file = "formatint64thousands_test.com.gz";
    sha256 = "01bafb2b005c9fd14cdac35ee168e1b37ae0b48e6ad7a8f5e5cda77e95060c55";
  })
  (fetchCosmo {
    file = "formatoctal32_test.com.dbg.gz";
    sha256 = "264ce4fe8c9ea14b320d5e1aeeb9ff33507623569cd4ef18a0402c7e7dd8b4e7";
  })
  (fetchCosmo {
    file = "formatoctal32_test.com.gz";
    sha256 = "63a408b7389ca192a6fe43d99b1b04420607417e6ad96f95c7892291589bdc5d";
  })
  (fetchCosmo {
    file = "formatoctal64_test.com.dbg.gz";
    sha256 = "444492de3007688fa3384a6b2b73a8fa00c6cf697c3fdc28465b88e52f0428a3";
  })
  (fetchCosmo {
    file = "formatoctal64_test.com.gz";
    sha256 = "b049483dff909b84f6fc247b74f07116caff39bbc90dc04bfbe3757e63807dec";
  })
  (fetchCosmo {
    file = "fputc_test.com.dbg.gz";
    sha256 = "8163ba55600d8ecd32303e34db586837012219c01b19bb1bcd56f0df32283562";
  })
  (fetchCosmo {
    file = "fputc_test.com.gz";
    sha256 = "4b3e049596d99d68cea41b93909e7ffb7255f47fe75dbd57fa47bfdaf057a3a9";
  })
  (fetchCosmo {
    file = "fputs_test.com.dbg.gz";
    sha256 = "ab033faa6ed06a7487b2eb133b8a8b9934283c0647c7c434db1fa7263e31b901";
  })
  (fetchCosmo {
    file = "fputs_test.com.gz";
    sha256 = "daf14431b790a97c4fbb85f91a5b1cca6ac257d9dfd55340b2b278eed817a82c";
  })
  (fetchCosmo {
    file = "fread_test.com.dbg.gz";
    sha256 = "e960c0130c3490886d9df7e3968aee267073e3a86fa04206d15207ae5fb1fa97";
  })
  (fetchCosmo {
    file = "fread_test.com.gz";
    sha256 = "3cb80e97dd6e61ae6fdd5a598d14cd231bcfab54855930e87f8da0ec0762c1a2";
  })
  (fetchCosmo {
    file = "freopen_test.com.dbg.gz";
    sha256 = "f4cebebcfe22cd0a33640428496b895be851a17d1a9cd417ac71ac5657598ba8";
  })
  (fetchCosmo {
    file = "freopen_test.com.gz";
    sha256 = "a14f2291219188ef0006fa965bcba961efeb5e103ef1c0f8168ba60792814278";
  })
  (fetchCosmo {
    file = "fseeko_test.com.dbg.gz";
    sha256 = "2528d7fad6bd01cd0ac284725297a13203deef7defd95ee59224f6b3a37b85df";
  })
  (fetchCosmo {
    file = "fseeko_test.com.gz";
    sha256 = "62b486ed3e9b971e7e289dff0256ccb962349f77d0e8ecfdf33ae60b32ebc2b4";
  })
  (fetchCosmo {
    file = "fsum_test.com.dbg.gz";
    sha256 = "14ed5fdcb4f78e4ed2cf2e833b91d3849a48dd4401059edc82366336a3d4fb7c";
  })
  (fetchCosmo {
    file = "fsum_test.com.gz";
    sha256 = "3bc5d2fd9195fc754049c29a88eb59f063f8eff0ecec0192521f47655d6dd4b5";
  })
  (fetchCosmo {
    file = "ftell_test.com.dbg.gz";
    sha256 = "b42311f2d4707d5e4f9d246fbf97815e06b594efcc9a47f6722335aa37e86893";
  })
  (fetchCosmo {
    file = "ftell_test.com.gz";
    sha256 = "7a36f38bedfe5d72dcc48fcec2b4d17466ce6dc23739f1e7aa9f298b5ea81b36";
  })
  (fetchCosmo {
    file = "ftruncate_test.com.dbg.gz";
    sha256 = "e81432b0a275880630b2b02298db3c65b479a05d1f7c3184d58c457ea89578db";
  })
  (fetchCosmo {
    file = "ftruncate_test.com.gz";
    sha256 = "d32f87df212ac9eac7badee0265913de3512e6f0bcb2bafa227fcd71279dfb8a";
  })
  (fetchCosmo {
    file = "fun_test.com.dbg.gz";
    sha256 = "8c748dde89cae3affc363b04677a9350381249c41c37d592739bd6a84131cb86";
  })
  (fetchCosmo {
    file = "fun_test.com.gz";
    sha256 = "4e5b72f298d61a48221295d489c8f467071180a2e1466a20f6c6bd72debe58f8";
  })
  (fetchCosmo {
    file = "fwrite_test.com.dbg.gz";
    sha256 = "4a277968122db5c0a5d019324ac1e8052e886909b31ae38747ab7e1eaedc4010";
  })
  (fetchCosmo {
    file = "fwrite_test.com.gz";
    sha256 = "a79fa764621662fc29154e36fcf48905ada3d4a0da6e5eb2d006c2b476594dc2";
  })
  (fetchCosmo {
    file = "gamma_test.com.dbg.gz";
    sha256 = "536553b8e919e1060333350691decab2302262bc484df8b7fdbd8bd74e553649";
  })
  (fetchCosmo {
    file = "gamma_test.com.gz";
    sha256 = "f99b540df2e6937a01f0314526bcc5e1d24eaf2c782cd7bd245ba4f0c8349ba8";
  })
  (fetchCosmo {
    file = "gclongjmp_test.com.dbg.gz";
    sha256 = "afe3dccecba471e00e0f7cbfb0142b28be30708fe05cf99c295eebcddd03a22e";
  })
  (fetchCosmo {
    file = "gclongjmp_test.com.gz";
    sha256 = "aa5f9999c6b6622aa0878ef8f398244a2f22fddeddb701c20600b7408af634b4";
  })
  (fetchCosmo {
    file = "getargs_test.com.dbg.gz";
    sha256 = "00f9d65d4facf3505ac40cdc06d041185b62f24bc0140e5b232058b856fbd4e4";
  })
  (fetchCosmo {
    file = "getargs_test.com.gz";
    sha256 = "6f0421dce3482bb279f83ea2a94cac5d87bdc612579ffe4c27b72f9fd35dfd82";
  })
  (fetchCosmo {
    file = "getciphersuite_test.com.dbg.gz";
    sha256 = "81c1d8bf18748b9b28bc7a1afa647e071be19a0873e76be63ad3cfa82e62db15";
  })
  (fetchCosmo {
    file = "getciphersuite_test.com.gz";
    sha256 = "ad1f90df971289e58f876ae1bcd8aefe49f9a324e5a0c791003acbe0b891117b";
  })
  (fetchCosmo {
    file = "getcontext_test.com.dbg.gz";
    sha256 = "bb926db48835ade47ea27d8d7b33568cc1b44c67919dede26305b24b6d7fdabd";
  })
  (fetchCosmo {
    file = "getcontext_test.com.gz";
    sha256 = "7cd4c3a0c505e57f1372b869affdf845fe768f2336a76b1a5fb66b5a230aa7c2";
  })
  (fetchCosmo {
    file = "getcwd_test.com.dbg.gz";
    sha256 = "7ece7b2a2bddaf50c49876461af75dc257df0f3f0c35f0a4d3ba72255cc712bd";
  })
  (fetchCosmo {
    file = "getcwd_test.com.gz";
    sha256 = "2085af3b863b6ce1581ee25d9726843b7e215d78b667d7485c54370e63cf62fd";
  })
  (fetchCosmo {
    file = "getdelim_test.com.dbg.gz";
    sha256 = "cdd45f683344b1a34d280d0c87d25546c4477d3cf599a6dffafbc89ab6f31f99";
  })
  (fetchCosmo {
    file = "getdelim_test.com.gz";
    sha256 = "95aa74ad48b1ad4029e2d030d44f392002e1d6a5d13fe5dcdfb3b8709a9fa341";
  })
  (fetchCosmo {
    file = "getdosargv_test.com.dbg.gz";
    sha256 = "50f27e4753c08c2757a680c3e6054251de75fff569a366e0c1f99e15f414837a";
  })
  (fetchCosmo {
    file = "getdosargv_test.com.gz";
    sha256 = "5513f70052e5daf495b636701229bfe2f81fb4495b427c7d36c413585111214f";
  })
  (fetchCosmo {
    file = "getdosenviron_test.com.dbg.gz";
    sha256 = "dc553d634196d2c776a67504cde496ce751b9a975d00feb18c10192894cc26fe";
  })
  (fetchCosmo {
    file = "getdosenviron_test.com.gz";
    sha256 = "959807fd31b45e14011c0173b13132987236cf12dc00b0485598daf2068b4abd";
  })
  (fetchCosmo {
    file = "getentropy_test.com.dbg.gz";
    sha256 = "81419cd84e63e22028a1ca1e42b5835cc981f6f760afeebc56893c5f763f3a0d";
  })
  (fetchCosmo {
    file = "getentropy_test.com.gz";
    sha256 = "07998d00e31521c3c70a842520c72a63275ccb01253216ccac1c0268e3f2051c";
  })
  (fetchCosmo {
    file = "getenv_test.com.dbg.gz";
    sha256 = "f5ef59ea5a83d2974035fd46f12708bd3a39368a7b2b9e4f10a384f9be0c36bd";
  })
  (fetchCosmo {
    file = "getenv_test.com.gz";
    sha256 = "33129db368f501d632dba1d87fc7ad4ad53c5176f1f1196a0087601829dfcd44";
  })
  (fetchCosmo {
    file = "getgroups_test.com.dbg.gz";
    sha256 = "eb5a566efd19663c355b8732dd0d46f4ba06eb0971b2de0b421439b4534e233e";
  })
  (fetchCosmo {
    file = "getgroups_test.com.gz";
    sha256 = "4683d4852fd5d844e503656ea4fa141a085faa6064ab396002ec725de580e2fc";
  })
  (fetchCosmo {
    file = "getintegercoefficients8_test.com.dbg.gz";
    sha256 = "3199d2ac4f26888eaf2b10ecc9d950e80599d8af87534aba2c1c50e3947d995e";
  })
  (fetchCosmo {
    file = "getintegercoefficients8_test.com.gz";
    sha256 = "c2ba4262e41e564be1d8e0cc20d75ba1343d6abfbab86e4e0a9ffa330d52e603";
  })
  (fetchCosmo {
    file = "getintegercoefficients_test.com.dbg.gz";
    sha256 = "b956792d4333ae9d25891036af5b68fad122e4c9295eebd13b561f614aa29119";
  })
  (fetchCosmo {
    file = "getintegercoefficients_test.com.gz";
    sha256 = "bb5a8c2afcce9234890f5e989e84b1c7f4fe5a78a7cd872fc439e8dec4fba7f4";
  })
  (fetchCosmo {
    file = "getitimer_test.com.dbg.gz";
    sha256 = "c41c13f1f77fdbebf6061b02908eef49b51c489232d5a05f1cbec9155488bc5f";
  })
  (fetchCosmo {
    file = "getitimer_test.com.gz";
    sha256 = "7f1c6058515039fefe6e11660ac76df04e8ec648c30ba2b1605216d8a51ab0c3";
  })
  (fetchCosmo {
    file = "getpriority_test.com.dbg.gz";
    sha256 = "c71131a80863dd7869e2e04b905d815b51661b61b909df2417f29c2b187cff5f";
  })
  (fetchCosmo {
    file = "getpriority_test.com.gz";
    sha256 = "2fb5666ad0d7e73da09d4d92ffac055c2d4b85b1a3b98c29fcb691b3f15a634e";
  })
  (fetchCosmo {
    file = "getrandom_test.com.dbg.gz";
    sha256 = "643607fde6dbda1fa5ba0bf468b170aa747c9aae96fc48c8ef2c507408e94bb5";
  })
  (fetchCosmo {
    file = "getrandom_test.com.gz";
    sha256 = "662920d1f8b1d394b742c7976803a2f285802f06a134ee5c31c0e4581ad772c9";
  })
  (fetchCosmo {
    file = "grow_test.com.dbg.gz";
    sha256 = "36ae164187fc5746fc49664a4c02636a8a86d529f2b3e7b8668ee0d1809ee8db";
  })
  (fetchCosmo {
    file = "grow_test.com.gz";
    sha256 = "2fa4b14405cfe803b46e8436656e19df5cc0fd45223d286b861ead973589a22f";
  })
  (fetchCosmo {
    file = "gz_test.com.dbg.gz";
    sha256 = "1836a84c4794e62599de88c649a5a2cdd4d7c599b5d16f10855301d75408a371";
  })
  (fetchCosmo {
    file = "gz_test.com.gz";
    sha256 = "9ecf8a237547a0440b51d9038860374d274217e302907b7cb7f9fa48d438539f";
  })
  (fetchCosmo {
    file = "halfblit_test.com.dbg.gz";
    sha256 = "872b2ae0409910ce681e177ebdaaabddcd288103429b63abe9358ee79a0519b8";
  })
  (fetchCosmo {
    file = "halfblit_test.com.gz";
    sha256 = "c464a3db220dc441257c9dc7291b8ec84286e63af6b3e906fe05136f4656b666";
  })
  (fetchCosmo {
    file = "hascontrolcodes_test.com.dbg.gz";
    sha256 = "ab02c442e0c77ba70ca8fe887ffc0032a8152dedf5872821416ce7818ae9a058";
  })
  (fetchCosmo {
    file = "hascontrolcodes_test.com.gz";
    sha256 = "5a4df550670c9f3cec776b3da21b07610007761470c7b0a9844be837b134bc53";
  })
  (fetchCosmo {
    file = "hexpcpy_test.com.dbg.gz";
    sha256 = "ac75562a2eb046383e7bce3f8fc7e27326835cb985a1eeb70d88e6349e780148";
  })
  (fetchCosmo {
    file = "hexpcpy_test.com.gz";
    sha256 = "ada42d0d612ff5ed44d71fdc525c5cdfb77147df26c69d5ddf8d413a1e05f45e";
  })
  (fetchCosmo {
    file = "highwayhash64_test.com.dbg.gz";
    sha256 = "5cf97482dcb2bb05afe52b700258273a722b7bad08153debee738e79327892fe";
  })
  (fetchCosmo {
    file = "highwayhash64_test.com.gz";
    sha256 = "bd8cbcde32718bf2618b7c142e7eaf3dbad2d819441a993b359832adb307eeef";
  })
  (fetchCosmo {
    file = "hypot_test.com.dbg.gz";
    sha256 = "a8d834b5c9be57ec1a5aded5b0b557b08a1eb95d9fab247f94383f305a8f3499";
  })
  (fetchCosmo {
    file = "hypot_test.com.gz";
    sha256 = "1071afbd62a6189cbe28a409310faf6c82ac0a44d9f79d3bd053dc0e4cfbf47b";
  })
  (fetchCosmo {
    file = "iconv_test.com.dbg.gz";
    sha256 = "a624163c1b28d07af091457058aaad91644b03d2116bc755bb6d0b45e651c792";
  })
  (fetchCosmo {
    file = "iconv_test.com.gz";
    sha256 = "e516ad38c84ec5caf12ed346cd59f0462897bfd8a171c44a9ca50c7e894f11c9";
  })
  (fetchCosmo {
    file = "illumination_test.com.dbg.gz";
    sha256 = "0261f2145220e46ccab08c50396fa8068ef269b56dc07b2099f2b7a7729c5830";
  })
  (fetchCosmo {
    file = "illumination_test.com.gz";
    sha256 = "0205aa8a7da103e2dbaf0dd808d1415dd4ba8ae45dae289ae30018f35d98477b";
  })
  (fetchCosmo {
    file = "ilogb_test.com.dbg.gz";
    sha256 = "62ac77f3d4fff95c017f4423f317b3365d4bde01e6c43607e82a61c309d998cc";
  })
  (fetchCosmo {
    file = "ilogb_test.com.gz";
    sha256 = "d67959ddc9a05853dd35d9fc52054c2abe308b9f7f643696b43f00d16e51a622";
  })
  (fetchCosmo {
    file = "imaxdiv_test.com.dbg.gz";
    sha256 = "a1ec4cb7567465b7f8826ebe23f522cd6196117ec0a70e8a4795d170475a0f03";
  })
  (fetchCosmo {
    file = "imaxdiv_test.com.gz";
    sha256 = "b2850d35fc469ce39678f1c033e9e066f5681e6f147ece0d68d9f7755a8ccb9d";
  })
  (fetchCosmo {
    file = "indentlines_test.com.dbg.gz";
    sha256 = "37006c075f4bccf55e174e5ad8476711a4d9a902422e5c86ad69bf8a63a58c2f";
  })
  (fetchCosmo {
    file = "indentlines_test.com.gz";
    sha256 = "40a7b9ecb204d828689c3affa54f32402a968f23840edeec662943d8c7dc344b";
  })
  (fetchCosmo {
    file = "inet_ntoa_test.com.dbg.gz";
    sha256 = "4ce09fe654e7a9aa2473611fa5ea2ac3b867860ff973ab962deffc750fede6d9";
  })
  (fetchCosmo {
    file = "inet_ntoa_test.com.gz";
    sha256 = "e03cc9aa842be4d3e11bf076bf632f174eb72f1d2f835d65321a1567f5e2bf98";
  })
  (fetchCosmo {
    file = "inet_ntop_test.com.dbg.gz";
    sha256 = "7949648699cb2eaaaaa3b438a2b6f7fe9338e16175356e46bd9128bd6931983e";
  })
  (fetchCosmo {
    file = "inet_ntop_test.com.gz";
    sha256 = "6022f20a32c694bad9e1e573fbac7a0dfefff75fcf5fa9d3d3671075d0e9d770";
  })
  (fetchCosmo {
    file = "inet_pton_test.com.dbg.gz";
    sha256 = "8151177fc7a6c617a7c3a55075c1818c85cfefa6c70feabbde41320c3d7812c7";
  })
  (fetchCosmo {
    file = "inet_pton_test.com.gz";
    sha256 = "7a0277f80fba647ffe7f701d898c310968812fdfe6e74d1ae091e1850ca9473e";
  })
  (fetchCosmo {
    file = "integralarithmetic_test.com.dbg.gz";
    sha256 = "867d6043fed687e653d198db1b1df2d283b8dda535849be017f31d0d932e6764";
  })
  (fetchCosmo {
    file = "integralarithmetic_test.com.gz";
    sha256 = "0389b021ac4acc3241026d52ecb582c9f4826e85e2a1a31ff4c08049dea435d3";
  })
  (fetchCosmo {
    file = "interner_test.com.dbg.gz";
    sha256 = "95b3c454d317a71ba34c62891c9601087df6618dfbc855418a716bd2b25014e6";
  })
  (fetchCosmo {
    file = "interner_test.com.gz";
    sha256 = "4797298b2e3ac6ff2e7038400a3408e3209c4aba7ac1ffc16a3307128edba26f";
  })
  (fetchCosmo {
    file = "intrin_test.com.dbg.gz";
    sha256 = "45a295c5ed4d6012d64281cae560129ab0b8bf6874016997776803c6ec85e6a2";
  })
  (fetchCosmo {
    file = "intrin_test.com.gz";
    sha256 = "22280552f77697519f7dc738daff3229143690d4440d98da7755a00dd89e7c84";
  })
  (fetchCosmo {
    file = "inv3_test.com.dbg.gz";
    sha256 = "f1b752e7051ab20d96eaed05ab6ba62da5bbebb5358358708a8b1cfa18c95165";
  })
  (fetchCosmo {
    file = "inv3_test.com.gz";
    sha256 = "f645f820ad0e5e4e3be73d722668989bf91f0d3817af26418bfee9f5a971a01f";
  })
  (fetchCosmo {
    file = "ioctl_siocgifconf_test.com.dbg.gz";
    sha256 = "533f7ea23fe63ee0a0cd25cf62bdc3de8a3c7b1f6591e8b44ed5c3242fb6e880";
  })
  (fetchCosmo {
    file = "ioctl_siocgifconf_test.com.gz";
    sha256 = "17045d46d14021c07ba95c38ed6e6b03632fbe72df88b2b48f2e4e8748295890";
  })
  (fetchCosmo {
    file = "iovs_test.com.dbg.gz";
    sha256 = "350b508db0aca82e7ded5b7beb3485a018395996786f96b154663b370e74761a";
  })
  (fetchCosmo {
    file = "iovs_test.com.gz";
    sha256 = "3fdc24276fac6c7a3b57ef6814bec2bd588c02f4fcaf8f64ca52438626150672";
  })
  (fetchCosmo {
    file = "isacceptablehost_test.com.dbg.gz";
    sha256 = "6d644607360a46d2a06d9f502e504c52c36370be876e163d7c8cc64da524eaa0";
  })
  (fetchCosmo {
    file = "isacceptablehost_test.com.gz";
    sha256 = "be2a97ff6880d64931057db43378208894a701bf1ac3b5f767de48f88c8193b2";
  })
  (fetchCosmo {
    file = "isacceptablepath_test.com.dbg.gz";
    sha256 = "ab2c6b5478497e1d048953b7966462964efe008fceb412e18dec7531be69a306";
  })
  (fetchCosmo {
    file = "isacceptablepath_test.com.gz";
    sha256 = "0b369bca7f4af28823f94fe4d3e09c05ae711a4862c4801f1bf1d7a08fd9fa23";
  })
  (fetchCosmo {
    file = "ismimetype_test.com.dbg.gz";
    sha256 = "5d066b150415da1ac1ee3d0d076ad3ba88a02f51c815710523cb8fa2cab01a4d";
  })
  (fetchCosmo {
    file = "ismimetype_test.com.gz";
    sha256 = "3f8753a2612756b72a55f661fde363804c541b51e24c1f2d066da945e5586ca9";
  })
  (fetchCosmo {
    file = "isnocompressext_test.com.dbg.gz";
    sha256 = "32f462b319f4681679cb097e570d95cc81a3871ab363bec5cd48f8a4c761b905";
  })
  (fetchCosmo {
    file = "isnocompressext_test.com.gz";
    sha256 = "820d206bda17106fe90115498a47e6ecc6188814ea00378a6debf8489fe98457";
  })
  (fetchCosmo {
    file = "iso8601_test.com.dbg.gz";
    sha256 = "7b3e9eef4c51fc44f2bf8fc178babfe4975ba7a18e994152801ff939e9c0057a";
  })
  (fetchCosmo {
    file = "iso8601_test.com.gz";
    sha256 = "8841581f8bdc43419a0b525a703e05fd043a1d12d5649eeac10a20c335870f9d";
  })
  (fetchCosmo {
    file = "isreasonablepath_test.com.dbg.gz";
    sha256 = "ddb3353b74b5ee953a94b4512bda09b56309ecc245b772f1d038f4b5d56654de";
  })
  (fetchCosmo {
    file = "isreasonablepath_test.com.gz";
    sha256 = "fe5aae804528c2d33717f28e0d6ff857c7b70f912fe2e4842ff5e39f79ce2fb5";
  })
  (fetchCosmo {
    file = "isutf8_test.com.dbg.gz";
    sha256 = "ea4c084d17065493596f8033bfc87be5266dba8a8fd70132bb3939bbf18d03a8";
  })
  (fetchCosmo {
    file = "isutf8_test.com.gz";
    sha256 = "5edc7cf6f594143a438501b6b4a3bcaf33ca4d585e91d2d4d739a0364761352a";
  })
  (fetchCosmo {
    file = "itoa64radix16_test.com.dbg.gz";
    sha256 = "a373bab161ede9da4151603ae88b14822f819c60948117b66ba01f6a33c4b746";
  })
  (fetchCosmo {
    file = "itoa64radix16_test.com.gz";
    sha256 = "0193c55eefc72f73095deae3b61e3a027119785183d49aa3b2aae428a92fb6dc";
  })
  (fetchCosmo {
    file = "itsatrap_test.com.dbg.gz";
    sha256 = "11d5deec3312269773209f65221ed0752b33694fb364224f37dae9b099a7d346";
  })
  (fetchCosmo {
    file = "itsatrap_test.com.gz";
    sha256 = "76484104a536fdd196fc154338ca2051455232799167acf05bac5c547d18b5d4";
  })
  (fetchCosmo {
    file = "javadown_test.com.dbg.gz";
    sha256 = "a60200457d52a89baa14aec2c0659b32d1e4cd27bc62355209e2aa728bc670fd";
  })
  (fetchCosmo {
    file = "javadown_test.com.gz";
    sha256 = "72190341d4d020134c769c5475220da47e8d93dc34f2524c691f4e554b7f448c";
  })
  (fetchCosmo {
    file = "joinpaths_test.com.dbg.gz";
    sha256 = "23e74d7785a9aa5ec3f40500fc9f504eb33546f8f3d82e46191005ca4fad535c";
  })
  (fetchCosmo {
    file = "joinpaths_test.com.gz";
    sha256 = "b420712bc3eb56ef55b53f901d73fe16cc57bde4ab310512f5a206be382cca68";
  })
  (fetchCosmo {
    file = "joinstrlist_test.com.dbg.gz";
    sha256 = "87241442bbb3911206d63f591964f4965af0d728cf3cb30c7a0c95cd20f87033";
  })
  (fetchCosmo {
    file = "joinstrlist_test.com.gz";
    sha256 = "9272af11b89bb6fe26596d3af56f788fa347225632f103172d6505f8a330f2ea";
  })
  (fetchCosmo {
    file = "kbase36_test.com.dbg.gz";
    sha256 = "41ecc70c1a6f6ca328682f6f83563e31628ac7ed5d963dd7b25bb66935530a47";
  })
  (fetchCosmo {
    file = "kbase36_test.com.gz";
    sha256 = "5763a473c77a5fe8964da533b24769e4ccd59c896b0f9ec2a0c5cdc744ae61ac";
  })
  (fetchCosmo {
    file = "kcp437_test.com.dbg.gz";
    sha256 = "7da2b2363c69074d79a1adeec70165ddd5b57ecbe962da088f87dbc9c783b968";
  })
  (fetchCosmo {
    file = "kcp437_test.com.gz";
    sha256 = "362e283d0bb91360351661839d768e64537050ccb5a7622af210f13f7986f65c";
  })
  (fetchCosmo {
    file = "kprintf_test.com.dbg.gz";
    sha256 = "e6582254e7fc253d655537709801055d6a4d9b11ac235605ff27e5e791688e27";
  })
  (fetchCosmo {
    file = "kprintf_test.com.gz";
    sha256 = "d8ec72756ef85677fc9465286cc4e8bbc810a938188dbd62df67783f9bc7980a";
  })
  (fetchCosmo {
    file = "ldexp_test.com.dbg.gz";
    sha256 = "a717217f384fa3c76244fd1b4ae40b8a76e7102a1786db3abd0005d013aa2d75";
  })
  (fetchCosmo {
    file = "ldexp_test.com.gz";
    sha256 = "d094242874639a913f77037307c85b2a58b89b9cba336fcd7f5ea7c584ab5321";
  })
  (fetchCosmo {
    file = "lengthuint64_test.com.dbg.gz";
    sha256 = "87414910ee5055d568149734cfd090efcf9d18d3cf669f6bfc96bd0354a16bbb";
  })
  (fetchCosmo {
    file = "lengthuint64_test.com.gz";
    sha256 = "d1e49a3a849e26a08f2136c751f2f08a8cf9fba0a9dab83e4d7ae233aedf8064";
  })
  (fetchCosmo {
    file = "lock2_test.com.dbg.gz";
    sha256 = "b687ed9f27318fbcce2660e5265ba59870d6777d82dc1ff428edc7b89209095a";
  })
  (fetchCosmo {
    file = "lock2_test.com.gz";
    sha256 = "fed1324f63894a853f2a2d42f776426dc843eec9b498a22d26197646dd72b14f";
  })
  (fetchCosmo {
    file = "lock_ofd_test.com.dbg.gz";
    sha256 = "7697adb980b37dc473b5dc4d52938fc0b2b3621cfbf72c8861cf0b05e292d341";
  })
  (fetchCosmo {
    file = "lock_ofd_test.com.gz";
    sha256 = "23a84487bcaf66491fcbd6940e8d902550e5bb1a9998e9c7633f362332ad7f88";
  })
  (fetchCosmo {
    file = "lock_test.com.dbg.gz";
    sha256 = "5773f35d0a40e615c325a714db5faa664860d97b44c6b0b2822f51abcab062de";
  })
  (fetchCosmo {
    file = "lock_test.com.gz";
    sha256 = "861de42ba4e1aada689b9243c202dd1c95f2079f02d958050afd2338c529ced5";
  })
  (fetchCosmo {
    file = "lockipc_test.com.dbg.gz";
    sha256 = "681cbccc5a938ef9ed5039d739768d31c8727e155317593d10ec0b119126aa8f";
  })
  (fetchCosmo {
    file = "lockipc_test.com.gz";
    sha256 = "df1d5582d9858cf5d1cd71e46ee4ad45b03540c3feb0181d2f349822e5081427";
  })
  (fetchCosmo {
    file = "lockscale_test.com.dbg.gz";
    sha256 = "7e0cdf8046f3081ad1077387227e49eee564e3d5daf91388f29d634796044755";
  })
  (fetchCosmo {
    file = "lockscale_test.com.gz";
    sha256 = "f07569afadc793271d9dcbce70252708699f44e61d96fda24bb9179bc0d10b47";
  })
  (fetchCosmo {
    file = "log10_test.com.dbg.gz";
    sha256 = "5a88f623901ef09283a9560fd2cce11db417e93e6d014e0ccd87606bf62bb4b9";
  })
  (fetchCosmo {
    file = "log10_test.com.gz";
    sha256 = "d647e2ad8a3f162ed600b1a2f63e2b2f3a86219d2558e569d38c8784f3ab6d63";
  })
  (fetchCosmo {
    file = "log1p_test.com.dbg.gz";
    sha256 = "7ece073d8c261ca4edebf4b6b5fbacd2c3b6ce99024ce1e3a2d13fe3169ba2c1";
  })
  (fetchCosmo {
    file = "log1p_test.com.gz";
    sha256 = "a775dac605b0efe1855a849fa7d2c4468ffb09af53876805929fb865e574c4b7";
  })
  (fetchCosmo {
    file = "log2_test.com.dbg.gz";
    sha256 = "9b172efa27854d6fae1789bda147d7091356fcfd15310d25635661217b0dd4c1";
  })
  (fetchCosmo {
    file = "log2_test.com.gz";
    sha256 = "21cf424e3e382df15a6c64b66335d7233674645536dd5d8d338ee6784c2eab19";
  })
  (fetchCosmo {
    file = "log_test.com.dbg.gz";
    sha256 = "121232703186c42eccace93d2deca105dacce7ad7fe0e7c4e4e9186b8015cadc";
  })
  (fetchCosmo {
    file = "log_test.com.gz";
    sha256 = "7603da056abe74d4c317bbc6832d040f391eec95732f637038411ac0ed4cdd8b";
  })
  (fetchCosmo {
    file = "logb_test.com.dbg.gz";
    sha256 = "7d1cc2182377196dcc5d2e2664f5a99c0088aa71dbc7878a01e53570812e815d";
  })
  (fetchCosmo {
    file = "logb_test.com.gz";
    sha256 = "424de909d19f661c4dc3d69e08a81fac76000516cb8639f4692477ae3419030c";
  })
  (fetchCosmo {
    file = "longsort_test.com.dbg.gz";
    sha256 = "00c879a9b8da282af5a984aa3360fff0d2392a2946dd6640f5c1e4708da62464";
  })
  (fetchCosmo {
    file = "longsort_test.com.gz";
    sha256 = "4b2882316d3c4450595a868adaadc5c5480ea803589fa377aa5d252108c70624";
  })
  (fetchCosmo {
    file = "lseek_test.com.dbg.gz";
    sha256 = "f72dd55bfe8b282ad371865c6818fc12777f36adc7444b2d386aad9cc9550dcf";
  })
  (fetchCosmo {
    file = "lseek_test.com.gz";
    sha256 = "c51bc452e175613673c98a1cf4838e0979c1fce894fa761becceea9f76886358";
  })
  (fetchCosmo {
    file = "lz4decode_test.com.dbg.gz";
    sha256 = "49983f4f0c48fb85d074201f4b07cbf8c63b3e059cf72331fbebe3b3eb443b43";
  })
  (fetchCosmo {
    file = "lz4decode_test.com.gz";
    sha256 = "6481095b0137cb5c6d91f1c0065bddfbe6a3c9167b1070aea259f4a883cc8f30";
  })
  (fetchCosmo {
    file = "machine_test.com.dbg.gz";
    sha256 = "4437d59fdefbcf0e2d17be65cf44ce76c1c152a6cc09a2dc798ecf29eac5993d";
  })
  (fetchCosmo {
    file = "machine_test.com.gz";
    sha256 = "f96971189fe9f88cc543a1471a9fe615351f2d4ab13b89cfbaeeef75ba1cf1f8";
  })
  (fetchCosmo {
    file = "magikarp_test.com.dbg.gz";
    sha256 = "8c717f4bb995e57a3e89909f2757d8d86324eda3d20e5d48bb29e77e83d54e10";
  })
  (fetchCosmo {
    file = "magikarp_test.com.gz";
    sha256 = "fba0d3cca5c154c039f5e6d76e07af4368a01fa48ce4c9f6ade1caeebe738219";
  })
  (fetchCosmo {
    file = "makedirs_test.com.dbg.gz";
    sha256 = "8028ddbe9ca4fe669bb9a0d5a5c999b608de64f1a3d721788752ef985e0b60e6";
  })
  (fetchCosmo {
    file = "makedirs_test.com.gz";
    sha256 = "94c3c37ddeb782140605f6824f5d9d8300e4f1ee78f8d40b93a7cd4217bbd3c8";
  })
  (fetchCosmo {
    file = "malloc_test.com.dbg.gz";
    sha256 = "03fc7c2b5ae1416f85797a00b135d2838ecbb8b5cb1cdd9a232aff0e1e079207";
  })
  (fetchCosmo {
    file = "malloc_test.com.gz";
    sha256 = "badf632181fd03358c5ceb2a8c28bca8bf0ff2482530beb789fb754eb481b1ac";
  })
  (fetchCosmo {
    file = "mbedtls_test.com.dbg.gz";
    sha256 = "9067281f5018763113d73e09e252380f4d07b1e603217a17f7b933566ee9cd66";
  })
  (fetchCosmo {
    file = "mbedtls_test.com.gz";
    sha256 = "ce50f28aa9d8221940a16b338f18866c84816c6285de8167881f0962faab2fc4";
  })
  (fetchCosmo {
    file = "measureentropy_test.com.dbg.gz";
    sha256 = "93cec08eeda7a3287a803657350fbfcc1d1e1d4a0543e6bf18e30e40bcc501b3";
  })
  (fetchCosmo {
    file = "measureentropy_test.com.gz";
    sha256 = "25f88fbc25c3ae7c7cf4338abb5f46a25bbd9f3f2c91a1b7e90b722b42c0f4d7";
  })
  (fetchCosmo {
    file = "memcasecmp_test.com.dbg.gz";
    sha256 = "3d21d6d3a464592ebdfec6f5f083f24e7272261399b105d4d0744117b31f7951";
  })
  (fetchCosmo {
    file = "memcasecmp_test.com.gz";
    sha256 = "c6fc5ec55b7eeb3864520e27bb2f16f1ba10262e3de9e721be5f824aed8e8f39";
  })
  (fetchCosmo {
    file = "memccpy_test.com.dbg.gz";
    sha256 = "178771c7b5d4b579c6d420fdaa083165fab7e8eba8d434df40905773c2f488f4";
  })
  (fetchCosmo {
    file = "memccpy_test.com.gz";
    sha256 = "14550c7423fb6dce05c023ad588cbe667a9a1fe0ef15d302899c7ee053c16a8e";
  })
  (fetchCosmo {
    file = "memcmp_test.com.dbg.gz";
    sha256 = "ca3207db06158b15c76d208e735cbc7d5d6bf3f349d65b02763bcb787a5c4504";
  })
  (fetchCosmo {
    file = "memcmp_test.com.gz";
    sha256 = "a79f0e95f350b9a5ac13c3e807fe159cf52396d779ae9bc758f6eca8dbeaa884";
  })
  (fetchCosmo {
    file = "memcpy_test.com.dbg.gz";
    sha256 = "678e68f2b86afe19a84f393c1483224c5e26ac8bbb8d29e076e1c5aafbf665b4";
  })
  (fetchCosmo {
    file = "memcpy_test.com.gz";
    sha256 = "0d9f555ec0c0939b4595eb3ff7ca6676d9edacc0f6d452b83cc5032f37c7f132";
  })
  (fetchCosmo {
    file = "memfrob_test.com.dbg.gz";
    sha256 = "1098f7d4ddc2530f58e8a3ba7371dd8e342123072011eec4b9bcd2e24d38d6c6";
  })
  (fetchCosmo {
    file = "memfrob_test.com.gz";
    sha256 = "d27a70f71fe85400f6c2b6710a973a6d5df6de64f4de3afea4d24fc6d0aea246";
  })
  (fetchCosmo {
    file = "memmem_test.com.dbg.gz";
    sha256 = "feac23ab6872dcafeb252ff46fb0fc9809e162e3682829f1a64f2291a034d0a9";
  })
  (fetchCosmo {
    file = "memmem_test.com.gz";
    sha256 = "75a04036d701af907b85778ff3a84408c459824237ae5e4ccd609c2299abbe0e";
  })
  (fetchCosmo {
    file = "memmove_test.com.dbg.gz";
    sha256 = "bf46ca95bb4657f6a4d81618d79f3f93761a8366bde8ab63ebf918c751a157ff";
  })
  (fetchCosmo {
    file = "memmove_test.com.gz";
    sha256 = "7beef583ced89f16bbb8a1dc9525417302a1e1cb3c9589177d8519a6733fe48d";
  })
  (fetchCosmo {
    file = "memory_test.com.dbg.gz";
    sha256 = "4b376d59ee97349cfe43a87b488f7138ced4e816421efedecea9826d16932b87";
  })
  (fetchCosmo {
    file = "memory_test.com.gz";
    sha256 = "f8a37334f2dfeca797e1ab76d0a94193d8a6934baec7c0d388794d33cd757fc4";
  })
  (fetchCosmo {
    file = "memrchr16_test.com.dbg.gz";
    sha256 = "24cb50cf061392ac98be278cdd0da4fe6592dbe1a38e140f06e7b13a68d2e350";
  })
  (fetchCosmo {
    file = "memrchr16_test.com.gz";
    sha256 = "078d426dfcab8964f1c3d0c0e3a40ddfeef9b6546e566639ab287050e4e19772";
  })
  (fetchCosmo {
    file = "memrchr_test.com.dbg.gz";
    sha256 = "e49645a6a0f2bad1d02693850ebdbd7a3113bae16a0dcb234c9aefec8e5af818";
  })
  (fetchCosmo {
    file = "memrchr_test.com.gz";
    sha256 = "0cd14f467c1a27d77c0dd99d6a028c2dbd686b2959f57b269ef6c06ffe5b35c9";
  })
  (fetchCosmo {
    file = "memset_test.com.dbg.gz";
    sha256 = "06ca14383b19c4435a54bd6bd32ade0175f0863cc94fd9bb338aa8206b64c6db";
  })
  (fetchCosmo {
    file = "memset_test.com.gz";
    sha256 = "23f3abb9f28959a66167b094aab97027e73a94068c41f149552c6441e6967b52";
  })
  (fetchCosmo {
    file = "memtrack_test.com.dbg.gz";
    sha256 = "ecdf844e6fb63056b53c51fd6269b70c74e03d25a00d7a45045eee40e449d995";
  })
  (fetchCosmo {
    file = "memtrack_test.com.gz";
    sha256 = "fe7d18b2ddcccbc9adb299c2370cc7ba4d1a560359f21ee77ef0ea87eaa4ee81";
  })
  (fetchCosmo {
    file = "mkdir_test.com.dbg.gz";
    sha256 = "23ba648375433aee0d8bfed50ebb426372eb962f8cfa5183240864243bd05427";
  })
  (fetchCosmo {
    file = "mkdir_test.com.gz";
    sha256 = "5c4fbcad5bf4a9ccebcf4caf824b5db7dab47a201c7dd5ffb7ee10a98f27b0c5";
  })
  (fetchCosmo {
    file = "mkntcmdline_test.com.dbg.gz";
    sha256 = "6dcae375bb9be30c8c2f868b2797ac50e24298a9ed7e06c0c16a6165c60285b6";
  })
  (fetchCosmo {
    file = "mkntcmdline_test.com.gz";
    sha256 = "970485d6fb9200a4d7f0152cd691c30535846f7697270721757de7a9b7e43ec2";
  })
  (fetchCosmo {
    file = "mkntenvblock_test.com.dbg.gz";
    sha256 = "28f1c17d098a9607eb65d1b7b9d109b98002d461b3385150c3566a1d208ddf62";
  })
  (fetchCosmo {
    file = "mkntenvblock_test.com.gz";
    sha256 = "69404f142a9907868f670953aa542e394ecb11fd278b92ae7cd5f926ecb793a0";
  })
  (fetchCosmo {
    file = "mkntpath_test.com.dbg.gz";
    sha256 = "41670f81aed64cd9c44e5c5ad76f062ee63fbd59486ac63a6c47f27b28b9455c";
  })
  (fetchCosmo {
    file = "mkntpath_test.com.gz";
    sha256 = "a76058ffb2162c25d8eaa777cff51a49a04be116b7211d659db2a336083fa565";
  })
  (fetchCosmo {
    file = "mkostempsm_test.com.dbg.gz";
    sha256 = "cfd77f94f0b019badbf12c1643444afe7cdc7eafad38fc452316e452a2266055";
  })
  (fetchCosmo {
    file = "mkostempsm_test.com.gz";
    sha256 = "901d79ceffd97e0416a32af3ac075461548eb599d925f2fc4d16f4c4987259c4";
  })
  (fetchCosmo {
    file = "mmap_test.com.dbg.gz";
    sha256 = "24320053d253f2cb5adbcd73d12642e095d5cbee58bb7f139ce2fdd32614e0f4";
  })
  (fetchCosmo {
    file = "mmap_test.com.gz";
    sha256 = "b05d3395cf82c6a714644400b07de30a2a67d7bcee5f0a4d2f95b27a964be993";
  })
  (fetchCosmo {
    file = "modrm_test.com.dbg.gz";
    sha256 = "fc573db4b44ccbb58971728a3881a9e9c78f66fae4eadf149e1f691507f68aaf";
  })
  (fetchCosmo {
    file = "modrm_test.com.gz";
    sha256 = "5e966fb3918fe6d2eaa4ca6fa37e31b445bc3d5c7c39c2826afed406388d5b8d";
  })
  (fetchCosmo {
    file = "morton_test.com.dbg.gz";
    sha256 = "bf7dd317f3afcbde44c996627fac77c5ec055287ca790f30030075f93e2a3cad";
  })
  (fetchCosmo {
    file = "morton_test.com.gz";
    sha256 = "160c688772dccf737c449983ca006509c407a78994a9e1d7b1ad1bda9f244e68";
  })
  (fetchCosmo {
    file = "mprotect_test.com.dbg.gz";
    sha256 = "b1aea0a56e12c55d0d297c5f3a1c070a5b5804c1fbde765679cd3abde1310299";
  })
  (fetchCosmo {
    file = "mprotect_test.com.gz";
    sha256 = "887951a3940d5f81be1447723a294dff6836912acbde3360674c2675d73bec4f";
  })
  (fetchCosmo {
    file = "mt19937_test.com.dbg.gz";
    sha256 = "a1dbcaf13f3085c2214c9c67445886ad030113863f6f030c0f30bea80dc9f33f";
  })
  (fetchCosmo {
    file = "mt19937_test.com.gz";
    sha256 = "cc3b746f052378521bfe0a549bd8863102685eca428f18f5716d3d7876806176";
  })
  (fetchCosmo {
    file = "mu_starvation_test.com.dbg.gz";
    sha256 = "0c8a07a0cff141083a3b65e3363e6487360f67563fe00d46ef189c9fcb567428";
  })
  (fetchCosmo {
    file = "mu_starvation_test.com.gz";
    sha256 = "d6609b53f9cc34a34d759a2a3c89b76bc186ac22d6dcc465b0163230fa6265bd";
  })
  (fetchCosmo {
    file = "mu_test.com.dbg.gz";
    sha256 = "f9f56b6a98ccc723ad85b462eaa44f57e271679c3383c7569839121f310b21d1";
  })
  (fetchCosmo {
    file = "mu_test.com.gz";
    sha256 = "63ea8c6c369a5f369213eb1dfabbd1e4ff7502601af698b8c960b5bf57ff5a27";
  })
  (fetchCosmo {
    file = "mu_wait_example_test.com.dbg.gz";
    sha256 = "2d2c16ad4232c57fae9c61f92eae71ff8e3a95d18dd86e0f8cc3d7cb28bcfd91";
  })
  (fetchCosmo {
    file = "mu_wait_example_test.com.gz";
    sha256 = "2f42b030167daa9a289eb4eb59a491d8858cdee0923d2a944e02a98319e76bad";
  })
  (fetchCosmo {
    file = "mu_wait_test.com.dbg.gz";
    sha256 = "e363510691ef19c4f470dc763f2ddbb64b82291b40b9879d7ade45afd82ea591";
  })
  (fetchCosmo {
    file = "mu_wait_test.com.gz";
    sha256 = "e287ef4069462f445d41ade63e743ebfcc94dd033ca5792c606d7602b5a099d0";
  })
  (fetchCosmo {
    file = "mulaw_test.com.dbg.gz";
    sha256 = "2117d369da1ceae17ea9833d8e0e7b3a12f54b825567dd78e66f990c1738f88f";
  })
  (fetchCosmo {
    file = "mulaw_test.com.gz";
    sha256 = "8f2e08d87dc5e7ad697f8af42bcdb644f9ee06a1c6dad3d3b5cf8d81c9812ec9";
  })
  (fetchCosmo {
    file = "munmap_test.com.dbg.gz";
    sha256 = "e2732488512bfdf5b18bcc7ee1f566d74005c2343106eebbe98b393e8c54bde9";
  })
  (fetchCosmo {
    file = "munmap_test.com.gz";
    sha256 = "b580b36cf546aa2e5c19c5ef11325acc8093509c9dba04e54abf6370fc0c5e4f";
  })
  (fetchCosmo {
    file = "nanosleep_test.com.dbg.gz";
    sha256 = "6fe7a594c63e74113eca70602d42cb5f49bfe46706133c0d675940ca27907069";
  })
  (fetchCosmo {
    file = "nanosleep_test.com.gz";
    sha256 = "5421b2ba4d696c0da2ece1cefaee111c7bbe593da72eaa8b60bbc436949ceb57";
  })
  (fetchCosmo {
    file = "nointernet_test.com.dbg.gz";
    sha256 = "527922ebf5dbde376e87aa746aeb744f541a25a40aa0770074b4ab4af21ea72c";
  })
  (fetchCosmo {
    file = "nointernet_test.com.gz";
    sha256 = "40a24431c60b7141b79d09c10b04212deaf01a55ee07ac4a47150aabb4cb96d4";
  })
  (fetchCosmo {
    file = "note_test.com.dbg.gz";
    sha256 = "22531925190f88f7675c19b8a1bba52cc39234f9476c1feb716a1c3b6e5648e7";
  })
  (fetchCosmo {
    file = "note_test.com.gz";
    sha256 = "9f9666e9c5d2cf64ca27e1eafa9a48eb966b594f3ae27d39b6a0d74d64d748b1";
  })
  (fetchCosmo {
    file = "nsync_test.com.dbg.gz";
    sha256 = "3aef603bbcbf6a22da89c6f4dd6e52e154fe4acb566a34dc7b6e18456853ddba";
  })
  (fetchCosmo {
    file = "nsync_test.com.gz";
    sha256 = "723dd2b96eca1f635cf44871402f135017c5650f8bc0440df8804a65a7401cd4";
  })
  (fetchCosmo {
    file = "omg_test.com.dbg.gz";
    sha256 = "feb631fcf7458db82e540e5466fad83e3a93a1d77f8adcb986d4b3f1f7e21e9f";
  })
  (fetchCosmo {
    file = "omg_test.com.gz";
    sha256 = "10a3c29664bdd636510d3e61d213b9d341477ca31f48e192ac4f63677a7fcb88";
  })
  (fetchCosmo {
    file = "once_test.com.dbg.gz";
    sha256 = "fd5e11ce578626211d4495c74901f99faa4429cefd0db0875aa302c855c36342";
  })
  (fetchCosmo {
    file = "once_test.com.gz";
    sha256 = "1b217834a7bc4348baf7791bcd68469146cdeab8467286dd94ca8413e151ef72";
  })
  (fetchCosmo {
    file = "open_test.com.dbg.gz";
    sha256 = "5cbf1d5be4a126b8c1a06b6fa5f2364a1a66d9633a8e4b9097e573288afeb891";
  })
  (fetchCosmo {
    file = "open_test.com.gz";
    sha256 = "34d836a1b8378f4e190dd4505d8ec1bf416a3c451dd89733e16312104e6df042";
  })
  (fetchCosmo {
    file = "openbsd_test.com.dbg.gz";
    sha256 = "4fe25c901a408a337d62719811ce1bd4e9c2b2397fed1abbefb7fae19d0dd26f";
  })
  (fetchCosmo {
    file = "openbsd_test.com.gz";
    sha256 = "f34302823886055024e0189241b8ffb29be17574c40235b42b2df93d244fba51";
  })
  (fetchCosmo {
    file = "palandprintf_test.com.dbg.gz";
    sha256 = "464976f25befa044fb89a9e0bf683de0d010b8eff52a9e47acecee3008708972";
  })
  (fetchCosmo {
    file = "palandprintf_test.com.gz";
    sha256 = "b64b567c4b546325342688ae6607d1ef8d3101422c91b99c33ac9176407d8240";
  })
  (fetchCosmo {
    file = "palignr_test.com.dbg.gz";
    sha256 = "6276fd7147e9a03b52d62e85a4c87afa5d0505a72c885cd708072f8c7b1c2801";
  })
  (fetchCosmo {
    file = "palignr_test.com.gz";
    sha256 = "b52fcf7facaad60cd19f24d8f7e66110fe7ec67ec92b0c5191a8df0f6765eec8";
  })
  (fetchCosmo {
    file = "parsecidr_test.com.dbg.gz";
    sha256 = "e98015908d15524fafe10e85d815845a1e703b03fed6066084bb5112edd789df";
  })
  (fetchCosmo {
    file = "parsecidr_test.com.gz";
    sha256 = "fbb174a638b1122a5e08a6238d159a96864ea87ac5e1cd4a1f5cc3ca3adf9f88";
  })
  (fetchCosmo {
    file = "parsecontentlength_test.com.dbg.gz";
    sha256 = "4110fa235a840dde9780ba56bd6231e0d5f4429158ddf8f25a0413cee2311946";
  })
  (fetchCosmo {
    file = "parsecontentlength_test.com.gz";
    sha256 = "bb63e29bb6d3da4f24d51766b7a0b4b9c47212d23427514f4c514ecb52d14915";
  })
  (fetchCosmo {
    file = "parseforwarded_test.com.dbg.gz";
    sha256 = "0483d5c584beb743eb4ab0f6915c839cb9c03c7a337d7e3af4457195c8a50e18";
  })
  (fetchCosmo {
    file = "parseforwarded_test.com.gz";
    sha256 = "687f0394a718e12469922266f046c7c90b56784f69eafeb2e0e04a6f66338377";
  })
  (fetchCosmo {
    file = "parsehoststxt_test.com.dbg.gz";
    sha256 = "c00df83837b663674e98809b42c450ab27da1b74320382d81faee42fc3105bee";
  })
  (fetchCosmo {
    file = "parsehoststxt_test.com.gz";
    sha256 = "6707b83867b3d2c6dc556a0d20f2f2056ec9248f3e950dceb139b6bb0c831950";
  })
  (fetchCosmo {
    file = "parsehttpdatetime_test.com.dbg.gz";
    sha256 = "3440e0fd7a7073d841aeb5937385b12f2f9ca89e065fb5daabf3f397eeecf0bf";
  })
  (fetchCosmo {
    file = "parsehttpdatetime_test.com.gz";
    sha256 = "ad660ae0ec5eae2fc63c18a06c85cd3a84df65d4c0fdf5a1d212a7e92454f1f5";
  })
  (fetchCosmo {
    file = "parsehttpmessage_test.com.dbg.gz";
    sha256 = "de918e4e54577478d1856152fe20a20e85bd5db27769fd8a3cc65ba6fcced308";
  })
  (fetchCosmo {
    file = "parsehttpmessage_test.com.gz";
    sha256 = "2f0721c17b97f109b613a7c92b014e0e75b2cdcfd5cd32cbab2fe5077127df47";
  })
  (fetchCosmo {
    file = "parsehttprange_test.com.dbg.gz";
    sha256 = "c2c0fe5aaca3000987621e6130a1a5777222eb355a0f79877332719264b975e7";
  })
  (fetchCosmo {
    file = "parsehttprange_test.com.gz";
    sha256 = "3797782745735c9b222abc1e643ebb05e2a583fb3a9559908eb88febec99fc81";
  })
  (fetchCosmo {
    file = "parseip_test.com.dbg.gz";
    sha256 = "0da62f37490b820b986d2ce16e843ecc51d881911f291b268daa95c2a1fd32ef";
  })
  (fetchCosmo {
    file = "parseip_test.com.gz";
    sha256 = "3793ea4d241dffaea3421437e0a3b84a2c803061b48d420a9a7ce064add4025f";
  })
  (fetchCosmo {
    file = "parseresolvconf_test.com.dbg.gz";
    sha256 = "13dacfc8905382072a74ff8e05b32ccd2c01bac1e870305ac4f7e241e5e259f7";
  })
  (fetchCosmo {
    file = "parseresolvconf_test.com.gz";
    sha256 = "5cf9af2443255178fb94301528c394aed2b6096abd01d2c75fb8f42ef2f4f440";
  })
  (fetchCosmo {
    file = "parseurl_test.com.dbg.gz";
    sha256 = "0f5e836108fd82c9e1d2ed63e190e39f5f5a3f2d0366ab319acf2b6189ff328e";
  })
  (fetchCosmo {
    file = "parseurl_test.com.gz";
    sha256 = "3d2f20a255be78843a3899591894dfe9f4fef604c5faeb489460227b4ffb694f";
  })
  (fetchCosmo {
    file = "pascalifydnsname_test.com.dbg.gz";
    sha256 = "b97b640d196f57c295b4154b6e25701f71a08e307aa94d73c937217f74c4e2fd";
  })
  (fetchCosmo {
    file = "pascalifydnsname_test.com.gz";
    sha256 = "028e8986d60ad3a1dbb2c32ef9ef58e90e9d00ebd259428844e57f4527bfe37a";
  })
  (fetchCosmo {
    file = "pcmpstr_test.com.dbg.gz";
    sha256 = "270a57db1103cb5fe5e36e2f97c6cdc4385945732e4f8b003e5e731745f35568";
  })
  (fetchCosmo {
    file = "pcmpstr_test.com.gz";
    sha256 = "3952d152cf2e1e4221fa8a918f6f32920e2de1d5259612647f6453d9bbe7fbd6";
  })
  (fetchCosmo {
    file = "pingpong_test.com.dbg.gz";
    sha256 = "89d26b9b9aac079f5e12fe286cfeb60ac86f55a391c00a9a955b854390a8d20e";
  })
  (fetchCosmo {
    file = "pingpong_test.com.gz";
    sha256 = "8c5e9424163bdfbfe734e27571a9142aadd98bf6dccd96d8dabe88785ac4eb89";
  })
  (fetchCosmo {
    file = "pipe_test.com.dbg.gz";
    sha256 = "20f9904b35f6961521a968dad4cd0beb44f84b531cb761acf5348d0205876454";
  })
  (fetchCosmo {
    file = "pipe_test.com.gz";
    sha256 = "fe9d7350fc95cea01a729af0ebbd796181d20ffa02427ab3eb7e42d13b142799";
  })
  (fetchCosmo {
    file = "pledge2_test.com.dbg.gz";
    sha256 = "8de8753f112d1d790180ac4b05ffbd6471f03e5e9626adf25c9fb9fb40ffb561";
  })
  (fetchCosmo {
    file = "pledge2_test.com.gz";
    sha256 = "95450d8db76bbbc1112ae81e84a9fdbd37d7f744eadca5e83f92690c7bf8d149";
  })
  (fetchCosmo {
    file = "pledge_test.com.dbg.gz";
    sha256 = "10dd1f3ef7b709216a455d0b4763ae1a740ae9c04f9deae2512f472aeb4e5872";
  })
  (fetchCosmo {
    file = "pledge_test.com.gz";
    sha256 = "9f21d4cc6edc98993f55efa66324fedb09bf0fb848d360b8b78dfbd26bfdfcdf";
  })
  (fetchCosmo {
    file = "plinko_test.com.dbg.gz";
    sha256 = "8c24b1eb027c5906631cfc4823a4c3279610794272073ee71156e278208b45d2";
  })
  (fetchCosmo {
    file = "plinko_test.com.gz";
    sha256 = "2464269f73c9a5612e5cd7e9811ee791de99d71c9520398da56588c3826e4367";
  })
  (fetchCosmo {
    file = "pmulhrsw_test.com.dbg.gz";
    sha256 = "33aa0a7bcf766934f96b64b30308b94d8e8d438541c007c16e4b88f79a12f779";
  })
  (fetchCosmo {
    file = "pmulhrsw_test.com.gz";
    sha256 = "13b6674409b5d6c6844789d431c633c2254f1c4ff265e61c5cb9a0a233cd2ee0";
  })
  (fetchCosmo {
    file = "poll_test.com.dbg.gz";
    sha256 = "9e118d9063ec84d44a61645bca9c366dd5e487d8b39f4bfc55ec2582833a06a3";
  })
  (fetchCosmo {
    file = "poll_test.com.gz";
    sha256 = "9642b9eb9cb6af6f7e3cd39810f844abdabbd5a3b5a2649c79cf08d6ad442c76";
  })
  (fetchCosmo {
    file = "popcnt_test.com.dbg.gz";
    sha256 = "22f8c0746e78fd3998b610ebf6644c9f44809bba3a68a2aad5335421a4010aa5";
  })
  (fetchCosmo {
    file = "popcnt_test.com.gz";
    sha256 = "01b4e728daec992f2a2e4ec21c9d36343e41b186888c4b3d64d2905e5a57a484";
  })
  (fetchCosmo {
    file = "popen_test.com.dbg.gz";
    sha256 = "c158d6aa8b8a2097da60f3348542a9666a33fbd847aa9234d29e37eb80ee6ee5";
  })
  (fetchCosmo {
    file = "popen_test.com.gz";
    sha256 = "b7320aa725a8d47a3cd66527d50b86264e309633e3f7ba20e56176c8effa7cb8";
  })
  (fetchCosmo {
    file = "posix_fadvise_test.com.dbg.gz";
    sha256 = "1a4a0d705336d9adfb52309ff30fe0904d4ee8ecfd2b3fb1df2cd04f95fc1f98";
  })
  (fetchCosmo {
    file = "posix_fadvise_test.com.gz";
    sha256 = "b13d930cab6b35961cd71afac40f187155bcc22756b5f6f54244ee7820a41c81";
  })
  (fetchCosmo {
    file = "posix_spawn_test.com.dbg.gz";
    sha256 = "5150b4b1b95d1b51737a656d8582052fa3485fbe532824767807534766d570e6";
  })
  (fetchCosmo {
    file = "posix_spawn_test.com.gz";
    sha256 = "6cc1086b98ac734f430eb2f717581e7513173cf820c14482b73e3a25be42c10d";
  })
  (fetchCosmo {
    file = "pow10_test.com.dbg.gz";
    sha256 = "265b2f239a21accabab0c0aa406a037a2412cea7fd170036bde1e1b6b2182bc1";
  })
  (fetchCosmo {
    file = "pow10_test.com.gz";
    sha256 = "9d50aea3ce34d607179d66dcd160c0bf58596bdff65cbda583edc89507018aab";
  })
  (fetchCosmo {
    file = "powl_test.com.dbg.gz";
    sha256 = "574c984e3e4e601e48b41743de692261af56f45a24298256af281680011849d7";
  })
  (fetchCosmo {
    file = "powl_test.com.gz";
    sha256 = "4a2a5da9461e437481d48eddbfd02bd3acf12b806d15211d849c924b5d5b5b75";
  })
  (fetchCosmo {
    file = "pread_test.com.dbg.gz";
    sha256 = "d7ed17f32b09056999dd5150d3103d88e74b1096ae066a41623bd7459dba17f9";
  })
  (fetchCosmo {
    file = "pread_test.com.gz";
    sha256 = "fa23c945cd36d72bda1a6462c275b8214ebe6ede8a7fe02ce2750c1a0941bd89";
  })
  (fetchCosmo {
    file = "preadv_test.com.dbg.gz";
    sha256 = "f0464611099c956c2f3efdf7dc4dc03e2f21f7860a7fa21ff151f5a91641d4e8";
  })
  (fetchCosmo {
    file = "preadv_test.com.gz";
    sha256 = "a062f6d2585d40041bbc923a88274350ef380559ec71564f4ab8e465c4ab66ff";
  })
  (fetchCosmo {
    file = "printargs_test.com.dbg.gz";
    sha256 = "c87e10a06be315a22c06993cd63a7f4963b622774f8747642599c4f58adb1aca";
  })
  (fetchCosmo {
    file = "printargs_test.com.gz";
    sha256 = "44bc076ead398c250ea2f69e303bea858919faca7fa8e0aa41e62a8f02358527";
  })
  (fetchCosmo {
    file = "prototxt_test.com.dbg.gz";
    sha256 = "d60d3eb290715e1a7397edbbe51b294fea52210888fc114dc68658e8472dac59";
  })
  (fetchCosmo {
    file = "prototxt_test.com.gz";
    sha256 = "45fe32054858bdf6c945642b942aeaa4a585d83ed5644c7b5acb9bf0f51fb3a0";
  })
  (fetchCosmo {
    file = "pshuf_test.com.dbg.gz";
    sha256 = "8a8f8c30249cdfee4e349babad18ca6ceb04051ccdea9c9f6eb227639482a9c5";
  })
  (fetchCosmo {
    file = "pshuf_test.com.gz";
    sha256 = "39d677a82ae462d7601acf6a8d9d85746e6a01ddc70f64f1e1942adab4e3addb";
  })
  (fetchCosmo {
    file = "pthread_atfork_test.com.dbg.gz";
    sha256 = "8830aaa436d43980375370f65bebdd0a7f5dcea6e3a3c0c41d78f31570413d1b";
  })
  (fetchCosmo {
    file = "pthread_atfork_test.com.gz";
    sha256 = "d81304a820c3ad930fbc027da2a2de0bd8faa97f44f36be2ca1b9e39477ba250";
  })
  (fetchCosmo {
    file = "pthread_barrier_wait_test.com.dbg.gz";
    sha256 = "996ce4887d9936eda01e3a0b8e119e3b3328155ad6c561308867fa610c44cc73";
  })
  (fetchCosmo {
    file = "pthread_barrier_wait_test.com.gz";
    sha256 = "dfd1c9627e8e5dbd6033e43c180419db235cae4073186c3cbe72a97aa46e2b2a";
  })
  (fetchCosmo {
    file = "pthread_cancel_test.com.dbg.gz";
    sha256 = "4ac8af933b0f482a2c09170096f85ac8ffec886dd9ae2cfbf604a008819b3f38";
  })
  (fetchCosmo {
    file = "pthread_cancel_test.com.gz";
    sha256 = "09eaeba7c4d18a85155d849f08819b39d30658628c5021d89eec1b447d8ab869";
  })
  (fetchCosmo {
    file = "pthread_cond_signal_test.com.dbg.gz";
    sha256 = "fdddac58927017beebb8795cad942b91e680f2cc8c351a574d497404a3429ae0";
  })
  (fetchCosmo {
    file = "pthread_cond_signal_test.com.gz";
    sha256 = "bbba18107a0800a6d1af40aa41f2ed54adaf80614542bd4c737656192b85bfad";
  })
  (fetchCosmo {
    file = "pthread_create_test.com.dbg.gz";
    sha256 = "0ea07383beb6dd927a0b600fcd90782cf1e14678a787bbaad88cbd7220e0fc41";
  })
  (fetchCosmo {
    file = "pthread_create_test.com.gz";
    sha256 = "d327c401e5eaf92ceb5f90368c9bb7e584480da987c803fbfd987d8320086892";
  })
  (fetchCosmo {
    file = "pthread_detach_test.com.dbg.gz";
    sha256 = "4194106f334b0cc7feab49fcc0f865e360f7f19aee172a29e238eee969fdaf38";
  })
  (fetchCosmo {
    file = "pthread_detach_test.com.gz";
    sha256 = "e7a98180949685bac7a7c2081372eddba8cadb9c857d39bba9cf9c41dd9dff1c";
  })
  (fetchCosmo {
    file = "pthread_exit_test.com.dbg.gz";
    sha256 = "7784a26790d342f6b24f8c73c2832ba339629d0fe7b3986b8bf7cd94945bcbd1";
  })
  (fetchCosmo {
    file = "pthread_exit_test.com.gz";
    sha256 = "c93846b3c601bf608f9ce9f9c6a594c0e22acfacdc2b5e13e87b1a6736f30b01";
  })
  (fetchCosmo {
    file = "pthread_key_create_test.com.dbg.gz";
    sha256 = "3944c49178ced4d1e6ec25f99c80dc45bab726b7c25dd461619df86bc441205e";
  })
  (fetchCosmo {
    file = "pthread_key_create_test.com.gz";
    sha256 = "0ac8bf575bdc63c88af61bfe008ffc8fe61c222be6dfe64daf61245a82221bdf";
  })
  (fetchCosmo {
    file = "pthread_kill_test.com.dbg.gz";
    sha256 = "d3271abbcec21425bb0ab7902031eeba6f669e7fc3b4417b74d7c2fb98f7f125";
  })
  (fetchCosmo {
    file = "pthread_kill_test.com.gz";
    sha256 = "435f45043ddf4d4e44c8e162795d2044ff6ae5651d01238659a819e4771070ac";
  })
  (fetchCosmo {
    file = "pthread_mutex_lock2_test.com.dbg.gz";
    sha256 = "72cfeb0b0bc91d3de96962fc182d806a0b5f26fb5291eb7213e83d82a984f7c3";
  })
  (fetchCosmo {
    file = "pthread_mutex_lock2_test.com.gz";
    sha256 = "c65fb4682a440bdf6df8b2f0f13a497273013d82c050a5fc4c186d47bf2b31e6";
  })
  (fetchCosmo {
    file = "pthread_mutex_lock_test.com.dbg.gz";
    sha256 = "f0896e9ce8c132ff7e1507692908cab92f1e06e2060ebd85093e41e37c3130e3";
  })
  (fetchCosmo {
    file = "pthread_mutex_lock_test.com.gz";
    sha256 = "e234713bc92fa658bc8e9a38ad536b4f0edd48357f48b055a80f0d21391c0923";
  })
  (fetchCosmo {
    file = "pthread_once_test.com.dbg.gz";
    sha256 = "b39d8d4d48d23b06a36bd7dacafe28f16713e8d08cb6f7a1b2263d004cdbc2a3";
  })
  (fetchCosmo {
    file = "pthread_once_test.com.gz";
    sha256 = "1f5c6622d7511c03f3b72c712a908afdc7c71437522ed228db1ff514964ffeae";
  })
  (fetchCosmo {
    file = "pthread_rwlock_rdlock_test.com.dbg.gz";
    sha256 = "b25273cc7cc38b98f063bf9062228c3a538425ac629b991cd47f65d918117788";
  })
  (fetchCosmo {
    file = "pthread_rwlock_rdlock_test.com.gz";
    sha256 = "d8b07ef1d1d52488f49d689b00f3714093aff769e3181029e27648a122199098";
  })
  (fetchCosmo {
    file = "pthread_setname_np_test.com.dbg.gz";
    sha256 = "95bbb433853fc9d580f1a5d9282c98af402859aeaee37df5688ccb3ab6669214";
  })
  (fetchCosmo {
    file = "pthread_setname_np_test.com.gz";
    sha256 = "36c9b690a24c75ce1e3a4a445eb034ef65a942ebc69b2a3f81aca2ac493e2264";
  })
  (fetchCosmo {
    file = "pthread_spin_lock_test.com.dbg.gz";
    sha256 = "c9253c7fac98fed0db9d0222113a1f9908174813025e1714f74845e76529e326";
  })
  (fetchCosmo {
    file = "pthread_spin_lock_test.com.gz";
    sha256 = "10bd69ae8099711f4cce9c586df084494982ec4c26a886dd70e10cfccd63fb6d";
  })
  (fetchCosmo {
    file = "ptrace_test.com.dbg.gz";
    sha256 = "e0f0d172e6ad0354161c2472a7cb62d145f69a593d4c1d790a302e51d3e10ab5";
  })
  (fetchCosmo {
    file = "ptrace_test.com.gz";
    sha256 = "1860b84f7251db2f1641bc4d88a7fa678be1500aa88e70037e003d4f90383458";
  })
  (fetchCosmo {
    file = "pty_test.com.dbg.gz";
    sha256 = "b9c5b0efae93498c82afb5478a4f80cd59f0284f42d99b02f05d322b57a2eb85";
  })
  (fetchCosmo {
    file = "pty_test.com.gz";
    sha256 = "0219e5b71b3d0ff31d81d5dc7a2e4c316842d2f91f04e78e1b9fe2db94b290c0";
  })
  (fetchCosmo {
    file = "putenv_test.com.dbg.gz";
    sha256 = "c52c7ee432a3bdac0d30dcb0bb80d8d7934291d7cf2104e8ad0f398d59aa4de1";
  })
  (fetchCosmo {
    file = "putenv_test.com.gz";
    sha256 = "e79689beaad790159ab920624a1d376503c4fdf2a4ccf6440c30c17d7a971ffe";
  })
  (fetchCosmo {
    file = "pwrite_test.com.dbg.gz";
    sha256 = "957f84c738c144f3f46afedbe537c993632f02278085891a89af30f05bc6b5ca";
  })
  (fetchCosmo {
    file = "pwrite_test.com.gz";
    sha256 = "aafc963493bdc8641cff377a3a6a28a32d9cbcc3cbdc34ccf0f7cc5c89cdb1fb";
  })
  (fetchCosmo {
    file = "qsort_test.com.dbg.gz";
    sha256 = "41e0dd947608b56afb5bd9cb6d52acfb75249996d9cc99a82c991ec20f087d88";
  })
  (fetchCosmo {
    file = "qsort_test.com.gz";
    sha256 = "47af44bda67e9c3557f9bb0185345aae2f013943c964497424fa3b5904be1c29";
  })
  (fetchCosmo {
    file = "raise_race_test.com.dbg.gz";
    sha256 = "dc90d6d8767dc6c2abbaff811a3492796585755aa60e76bfbc9b02d3da4ebcbf";
  })
  (fetchCosmo {
    file = "raise_race_test.com.gz";
    sha256 = "463183fba06c1a5179cc1ec7459e0beb6d3fff8c3094d50e210862fe5469b31f";
  })
  (fetchCosmo {
    file = "raise_test.com.dbg.gz";
    sha256 = "aa732f8ff4415634eeeca102ac03bccdb448b698890de562090b04251f1ea2f8";
  })
  (fetchCosmo {
    file = "raise_test.com.gz";
    sha256 = "82f3ced9e60699a6614e0e2698e2b6aa1c8490ae58610e72b8c767ccddf2fb49";
  })
  (fetchCosmo {
    file = "rand64_test.com.dbg.gz";
    sha256 = "6cb7985151cad6a82ecce7ecf1eeee2d04cbec64e678cbba6ae031148ac53089";
  })
  (fetchCosmo {
    file = "rand64_test.com.gz";
    sha256 = "ec18678128d07be110f1ead46662bbaa2a5c06a2e9dd3c03157770249c99461a";
  })
  (fetchCosmo {
    file = "rand_test.com.dbg.gz";
    sha256 = "5ce0e5155c8d7b0eeee1269a3ddab60fcbafe9eae7bf253068dad8bf21667925";
  })
  (fetchCosmo {
    file = "rand_test.com.gz";
    sha256 = "bee6eb7e7a108f7072ccef4e7e9b68e968f7bc75039dd2a03bb66fe7863e8cec";
  })
  (fetchCosmo {
    file = "read_test.com.dbg.gz";
    sha256 = "e8a9a0a8c162b945da40ecfce3a4ff5f0e55eb23f83eb466ef7c6f5f0a693d3e";
  })
  (fetchCosmo {
    file = "read_test.com.gz";
    sha256 = "ec8c22fa6918a37244df94b0caa529b01fa70f9262007051e23a19e858f1e4e5";
  })
  (fetchCosmo {
    file = "readansi_test.com.dbg.gz";
    sha256 = "2ce31f453a10b0e42ca39ebb64ffc881ca0fa65f4a1d4fac371dbc8b03a067c7";
  })
  (fetchCosmo {
    file = "readansi_test.com.gz";
    sha256 = "44d9d574f5185755666d655cd7e42c74fd352703d8a226401e2987de22914b01";
  })
  (fetchCosmo {
    file = "readlinkat_test.com.dbg.gz";
    sha256 = "251230ab5b7f14ee2b211cda28d2e48f99a1bbfa8020501534c228c15eac1779";
  })
  (fetchCosmo {
    file = "readlinkat_test.com.gz";
    sha256 = "0891de755332373e7bc3d903be36f72de5ed375e2447acef6ddfd28a4d7f3e8d";
  })
  (fetchCosmo {
    file = "realloc_in_place_test.com.dbg.gz";
    sha256 = "fa9a01b118b0b70266e1fbb690dba38b68f04e784765f2cec42b04549a996972";
  })
  (fetchCosmo {
    file = "realloc_in_place_test.com.gz";
    sha256 = "055a37b28b72acf40e7916545c5114adf011a16b91b59ee20ac22aaacbb48000";
  })
  (fetchCosmo {
    file = "redbean_test.com.dbg.gz";
    sha256 = "3b6f7689739bc2cb1c6ff1f95cf3dfb3afa23fe9c65b576f4675daaef23638b2";
  })
  (fetchCosmo {
    file = "redbean_test.com.gz";
    sha256 = "ab1b75356696cbaef8d942b813549b047a73ca24dcb5bc27eeec7cd1e52978b0";
  })
  (fetchCosmo {
    file = "regex_test.com.dbg.gz";
    sha256 = "95cb414c767d44ff8e093565c5d93ee5334e08b004efcb21a2737458cb832321";
  })
  (fetchCosmo {
    file = "regex_test.com.gz";
    sha256 = "5ac50fab0989ab7b4994c28b2be0df4201537d967abf955bf6406bb255bd37f5";
  })
  (fetchCosmo {
    file = "renameat_test.com.dbg.gz";
    sha256 = "cc3f4b03ec4948e914f5afe0e3bf43de678dcda38fcce36e1280699a2959f39b";
  })
  (fetchCosmo {
    file = "renameat_test.com.gz";
    sha256 = "5c2c9063eb3c2f5ec818d9af406fec804a3d77fb7f1538db3641acf6f96d8460";
  })
  (fetchCosmo {
    file = "replacestr_test.com.dbg.gz";
    sha256 = "08267108d1e2c17e191b6ee5bd053b7fce7574560eca8a0ff4adb263a0de2d2f";
  })
  (fetchCosmo {
    file = "replacestr_test.com.gz";
    sha256 = "b2849af2858dc465462acc2f4a72570f1206c5fbe41c9c5a555bfe5107174d50";
  })
  (fetchCosmo {
    file = "reservefd_test.com.dbg.gz";
    sha256 = "b81169624e29f251c8528e4da4a5519ec793b93d3dd4878399e5f454c8348595";
  })
  (fetchCosmo {
    file = "reservefd_test.com.gz";
    sha256 = "0861822186520f1df9b23b7b2c6e5c7ede19283c1b9dd1c51d7c709557b6aa9d";
  })
  (fetchCosmo {
    file = "resolvehostsreverse_test.com.dbg.gz";
    sha256 = "55df6dfe924acc83fdb9495603b78b9576b3686db413330409630726b0f55303";
  })
  (fetchCosmo {
    file = "resolvehostsreverse_test.com.gz";
    sha256 = "03ecc0a9231a8fa1e454b5d6b4fe1523b4c835bb6d9e97ddb2a07dcd155547c8";
  })
  (fetchCosmo {
    file = "resolvehoststxt_test.com.dbg.gz";
    sha256 = "e0d78c6d6715fbf18fdc84921d638c1155471b475848deefd83ef6143541794c";
  })
  (fetchCosmo {
    file = "resolvehoststxt_test.com.gz";
    sha256 = "1c97c7a2b33453ebd96e546d84b2feb663e69c41d1aa355e384dcd0e2814601f";
  })
  (fetchCosmo {
    file = "reverse_test.com.dbg.gz";
    sha256 = "7b8a649203703afa71c63819034a90fcd0438da95d53dbdf55f83a03835f8cc4";
  })
  (fetchCosmo {
    file = "reverse_test.com.gz";
    sha256 = "84047c8cad3e0a96b31179f12afd37feca24b652bde20057a62f6d48ca83bf0f";
  })
  (fetchCosmo {
    file = "rgb2ansi_test.com.dbg.gz";
    sha256 = "6e400a33e9c6d4b8ddda9f3d906a9f76c4a19a6d04fa78f6ff73abb7c7a9640c";
  })
  (fetchCosmo {
    file = "rgb2ansi_test.com.gz";
    sha256 = "0bc8d8884593194a130c59a3e7851ab280595b7c1ec50d3eed5cd318c8965c57";
  })
  (fetchCosmo {
    file = "rngset_test.com.dbg.gz";
    sha256 = "16a844f17e55b43f0f481e096a5b27613087cf9318cc68dbbf2baafea8686862";
  })
  (fetchCosmo {
    file = "rngset_test.com.gz";
    sha256 = "8b84008dcc3b43d16bd05ad5efe186ac6abe31758f13d6c9c1a6570c9796dc7f";
  })
  (fetchCosmo {
    file = "round_test.com.dbg.gz";
    sha256 = "68c32e7640a3a6908f470bd8b8ce9097ecb92b8ef47c13b21bb216afed0f5140";
  })
  (fetchCosmo {
    file = "round_test.com.gz";
    sha256 = "c7e3cb380f6c12afeadcf2c6a7677d69f15b964dd63ed3be3cc55829e7aee898";
  })
  (fetchCosmo {
    file = "rounddown2pow_test.com.dbg.gz";
    sha256 = "267f470e53c78076aab56b9649f75e625644ba9e3ef03f601ab8def505c16916";
  })
  (fetchCosmo {
    file = "rounddown2pow_test.com.gz";
    sha256 = "43a3c42b254c587b40681bc08d0395a0bf99d275603434afe066a67f7fa1b1d2";
  })
  (fetchCosmo {
    file = "roundup2log_test.com.dbg.gz";
    sha256 = "39c5e80a80b905755300eec7a5dbe9a7638460e2d8c2bda707a6442562d34b38";
  })
  (fetchCosmo {
    file = "roundup2log_test.com.gz";
    sha256 = "6073e10e044517a2050a3d7a07b81bc4c6a0a7b6ca6cf7451cb8e593f1df1b1a";
  })
  (fetchCosmo {
    file = "roundup2pow_test.com.dbg.gz";
    sha256 = "607797eeeeb97a4a1901fb8d4712fcacea3579cc59560f6b041276e81c9dd8bc";
  })
  (fetchCosmo {
    file = "roundup2pow_test.com.gz";
    sha256 = "036f28b9de0c141f1bc1bd44b8735b26581a35c3af3c320bdb036241aef74e7f";
  })
  (fetchCosmo {
    file = "sad16x8n_test.com.dbg.gz";
    sha256 = "01065e6da2b3bf0ddc63275ae894e2e3a7915a77d4c632659def8079648209c0";
  })
  (fetchCosmo {
    file = "sad16x8n_test.com.gz";
    sha256 = "e7f141868dc3f7519c6fdd98108ad64446f814b26e79e96d21a621cf24aca756";
  })
  (fetchCosmo {
    file = "scale_test.com.dbg.gz";
    sha256 = "bac12d1a5962277e4d312f980198d4d16fcba992f5b2e41aa90384afc07902f4";
  })
  (fetchCosmo {
    file = "scale_test.com.gz";
    sha256 = "5cc89b207965c04cd3a23c9c25fdd6d775e7710fd366bfa37474e9670b8c45d3";
  })
  (fetchCosmo {
    file = "scalevolume_test.com.dbg.gz";
    sha256 = "31e5959860c9e1e96ea54c7a1470afec9f77218cd24e7de0ef22d64ba7abd409";
  })
  (fetchCosmo {
    file = "scalevolume_test.com.gz";
    sha256 = "b1566e10de51db9859312d9c52f0bcb5d4663930ecac41e7fc79fd4561bea5b2";
  })
  (fetchCosmo {
    file = "sched_getaffinity_test.com.dbg.gz";
    sha256 = "a8e5d51f6de0b700cb5b3b4ea6b887292212cef534c9e1662626f1113357c24e";
  })
  (fetchCosmo {
    file = "sched_getaffinity_test.com.gz";
    sha256 = "06a4cbb523c6a50f1611f8a9aacb45013159b19f4a57f3352ff6b0d289c3f55b";
  })
  (fetchCosmo {
    file = "sched_setscheduler_test.com.dbg.gz";
    sha256 = "1478abc3ce90a9a4d864c6a6662d5fa0ba69ffe709dd017506a33c58fd30b278";
  })
  (fetchCosmo {
    file = "sched_setscheduler_test.com.gz";
    sha256 = "90a7b88a4e937e4e6e4f22a588d484965c6aa51dea3f43bd78ed3e8d6602191c";
  })
  (fetchCosmo {
    file = "sched_yield_test.com.dbg.gz";
    sha256 = "cb33fa7e1257f41daf4a37bd69bfcc4c5c11b854f1fe3b906fbe7fdb9f21b37e";
  })
  (fetchCosmo {
    file = "sched_yield_test.com.gz";
    sha256 = "473584a36f348b5950549eca2d3010cd9282ba960d042ff65e1c50a9c43ae800";
  })
  (fetchCosmo {
    file = "seccomp_test.com.dbg.gz";
    sha256 = "3326c73a47dc3f2630b816c6abeff8f7cf22b8a637ffaa2352d6aa00a72b2cf6";
  })
  (fetchCosmo {
    file = "seccomp_test.com.gz";
    sha256 = "89a167df3849febc358eed799ffb43f9278723b78668425209ab873ad8a243b0";
  })
  (fetchCosmo {
    file = "secp384r1_test.com.dbg.gz";
    sha256 = "b089dbb0578ed2a9be74ed8697a90e9a7ee99e5dac5002d446b5e4bcb69bcd8c";
  })
  (fetchCosmo {
    file = "secp384r1_test.com.gz";
    sha256 = "fc0328b3f31d6cb9e6cf1dd8a629ee030d119ffadb44ed81ada4bf5b64c0a436";
  })
  (fetchCosmo {
    file = "select_test.com.dbg.gz";
    sha256 = "a891ed186cfd833a7849c3dcc953e95eec52c39ba19361d818c42b263a28b7b5";
  })
  (fetchCosmo {
    file = "select_test.com.gz";
    sha256 = "041af3dd90142e541af59ef0cb33cee9503cfb942229eef31cdb8924f3074bd1";
  })
  (fetchCosmo {
    file = "sem_open_test.com.dbg.gz";
    sha256 = "0ad0f283603197d6705cc3336fca03ce4cbba6970cfc9c5fa3f96b8e7c955a6f";
  })
  (fetchCosmo {
    file = "sem_open_test.com.gz";
    sha256 = "d70aaf367899c5ef1727cf7fa17c7a42aede922e00def6055dba07bfac5208d6";
  })
  (fetchCosmo {
    file = "sem_timedwait_test.com.dbg.gz";
    sha256 = "927ae752ac936112b4e5fb7fc9d8122e63c1be2c1d566d4d03dd7c74ff577d2d";
  })
  (fetchCosmo {
    file = "sem_timedwait_test.com.gz";
    sha256 = "5a3889514ec88d5361c5559fb06dd99a897f2623dfa4750053664043d1b5ca50";
  })
  (fetchCosmo {
    file = "sendfile_test.com.dbg.gz";
    sha256 = "665cf289d5e653e8df455914b7cce5686b41fc7149ff8dbf6dfa14ce57bb0440";
  })
  (fetchCosmo {
    file = "sendfile_test.com.gz";
    sha256 = "660f6d142946577be17d1eccc5c45e807899514087923f2813221c0326795a88";
  })
  (fetchCosmo {
    file = "sendrecvmsg_test.com.dbg.gz";
    sha256 = "de1bfcb80e685f2e30dd118b32ed8a53f1f8fad3da84f84aec267380c2835839";
  })
  (fetchCosmo {
    file = "sendrecvmsg_test.com.gz";
    sha256 = "a37d156da9f39e3bb9a4b7de04f1b9730729021cbbb15d58661b145944b73c72";
  })
  (fetchCosmo {
    file = "servicestxt_test.com.dbg.gz";
    sha256 = "8b67e6590a2cb35856ec5b245d141a752a0ce81be745c9277f1c87321f75f010";
  })
  (fetchCosmo {
    file = "servicestxt_test.com.gz";
    sha256 = "10c9e37b5aa5ab265d2ca40529810250d8803efece79ee0300156938246545f8";
  })
  (fetchCosmo {
    file = "setitimer_test.com.dbg.gz";
    sha256 = "29c9159a37b07d0f1183fe0cfa6d54e77786fdfa6a2befc33b6e86ab069deb9b";
  })
  (fetchCosmo {
    file = "setitimer_test.com.gz";
    sha256 = "639b579331090fdf6d3efca402370405a96f57294b0b99b6dad779cc46c9eced";
  })
  (fetchCosmo {
    file = "setlocale_test.com.dbg.gz";
    sha256 = "c37757d1d2794e81d31e725963e0c5a7b36b60ddace635e6c4a0990c2745a2b5";
  })
  (fetchCosmo {
    file = "setlocale_test.com.gz";
    sha256 = "043e3764995929caed33c9b68e09c0126ee233e4a54e971d86eeece6292f1123";
  })
  (fetchCosmo {
    file = "setrlimit_test.com.dbg.gz";
    sha256 = "2af50510275bd51acf2bb8e85f3576f6fa5c0f88526be9551f19638187bda966";
  })
  (fetchCosmo {
    file = "setrlimit_test.com.gz";
    sha256 = "f4fb62821b54e65123320e078a148103c6685255e5b733a8220eea56c999b85c";
  })
  (fetchCosmo {
    file = "setsockopt_test.com.dbg.gz";
    sha256 = "c6268b99357ec952108397ac1f8e488ba81492c7e425dcbde0a2aace6ecaebde";
  })
  (fetchCosmo {
    file = "setsockopt_test.com.gz";
    sha256 = "3d0ddf1b538ec21d8092a982a9868352601133e3ad96ed5994befd9aaacfd96f";
  })
  (fetchCosmo {
    file = "sigaction_test.com.dbg.gz";
    sha256 = "1447daa2c0b1430461787de43e26248fd2c6cb4cf9526aa6f367da33a0301d99";
  })
  (fetchCosmo {
    file = "sigaction_test.com.gz";
    sha256 = "271db3a3bb82c7b99f5ac8addc3300a26cc74978e18964d0fccccb9499cf2285";
  })
  (fetchCosmo {
    file = "signal_test.com.dbg.gz";
    sha256 = "a103bde47b38c6fd92699022638f9b17ef3996e70ccc7d430d71f734741a3c9a";
  })
  (fetchCosmo {
    file = "signal_test.com.gz";
    sha256 = "d36176fd3a02bcd4019d7b3dc046e985455b86d92e4e1c10e0434efb56058b2d";
  })
  (fetchCosmo {
    file = "sigpending_test.com.dbg.gz";
    sha256 = "a499c0d40e0a87a6c314e297e11f7ecd8e2f33a05d9b887dd09f72b4a16c8fda";
  })
  (fetchCosmo {
    file = "sigpending_test.com.gz";
    sha256 = "500848bbd6ea12f9ba5a93c0aa8c58393e74a979bb8f62729e51aa75353e3fe7";
  })
  (fetchCosmo {
    file = "sigprocmask_test.com.dbg.gz";
    sha256 = "6fd9ea7cbaa7e4eebbbfa1f30624bd83ca1e957904e4e084f9cac8cf51538b5e";
  })
  (fetchCosmo {
    file = "sigprocmask_test.com.gz";
    sha256 = "434706c79540ea18c2dc394960d925bfb718cf1e2b8dde1cd0ea8c2dad460cf4";
  })
  (fetchCosmo {
    file = "sigsetjmp_test.com.dbg.gz";
    sha256 = "59602543e39d1d47d9fd7467fdf0cbcd837f9e405b93cbc17f4b8100ba031ab6";
  })
  (fetchCosmo {
    file = "sigsetjmp_test.com.gz";
    sha256 = "5fb6fafbd352277b6e33d0f6b2627eb053adf1123ea09c994ce495d86a9cd1e0";
  })
  (fetchCosmo {
    file = "sigsuspend_test.com.dbg.gz";
    sha256 = "fcfe6debfa632790248145f91a31526e1dfc7bb9617a74736381129b1a979bba";
  })
  (fetchCosmo {
    file = "sigsuspend_test.com.gz";
    sha256 = "ccde77da3b71d67079ac1341131abc1243fc0141e57aab5666bc25e0719fdf28";
  })
  (fetchCosmo {
    file = "sigtimedwait_test.com.dbg.gz";
    sha256 = "a25eb54d38c47b8f15f96a2809f45b7aa2e8c323fc61463c63e0d95b7bab2880";
  })
  (fetchCosmo {
    file = "sigtimedwait_test.com.gz";
    sha256 = "36857f06e1f26b814dc147cf024c446fac44e2db59f381fe64d071703703a0b3";
  })
  (fetchCosmo {
    file = "sin_test.com.dbg.gz";
    sha256 = "1c0a57c0b0b57b7661f9d781c87613f7364ed248ccdd28cca4cbcb5c76a27d6b";
  })
  (fetchCosmo {
    file = "sin_test.com.gz";
    sha256 = "7960263948d384fdd1813ccbe404013a9adb5c1a142ce8ea1c4f24417c5ee321";
  })
  (fetchCosmo {
    file = "sincos_test.com.dbg.gz";
    sha256 = "fac2a3e10ffc1db91dbb9eeabce8c8628c2604f22c13cb3539fa3a1c5fc83231";
  })
  (fetchCosmo {
    file = "sincos_test.com.gz";
    sha256 = "c296541ac46fbc19aa4bb36077c8be239628fdcd397800603559db56fe7750c4";
  })
  (fetchCosmo {
    file = "sinh_test.com.dbg.gz";
    sha256 = "6236bd37c535ad88f95387abc08e7da71897d22b2a1e19a83c89ce101ba4b861";
  })
  (fetchCosmo {
    file = "sinh_test.com.gz";
    sha256 = "202616dc554c689278bcae4689835817205d117d54e7e08288b4588894c559df";
  })
  (fetchCosmo {
    file = "sizetol_test.com.dbg.gz";
    sha256 = "2485143d186c5fe57062f28a5726cf0d859e47bd2da65ca22bfd1e52e4e79bc1";
  })
  (fetchCosmo {
    file = "sizetol_test.com.gz";
    sha256 = "7510777cda51a56f23dfd4f62ca66a7e86c19af040a2f67dc1644450c0381bfa";
  })
  (fetchCosmo {
    file = "sleb128_test.com.dbg.gz";
    sha256 = "dbd47188c7968d8a043ffe8b438ee91c1399a6765bd772ea28286bef79248177";
  })
  (fetchCosmo {
    file = "sleb128_test.com.gz";
    sha256 = "966f030d77c166c10820c47dfb3d2a3068d5493b6041dc4395278dc1cbcabce4";
  })
  (fetchCosmo {
    file = "snprintf_test.com.dbg.gz";
    sha256 = "fddf813c5ac3a12056ea0c490584b3881f9852bedf8a1daca3e9124a6a273302";
  })
  (fetchCosmo {
    file = "snprintf_test.com.gz";
    sha256 = "311217a01cf64278e977b8bf7a5d76e6fd9c82b759cf92b933ca66bcd7984b02";
  })
  (fetchCosmo {
    file = "socket_test.com.dbg.gz";
    sha256 = "61c1a8a0ba1ca92566fd643c73641d7098ca238b3b64d4ecbf60e22441bf8ea3";
  })
  (fetchCosmo {
    file = "socket_test.com.gz";
    sha256 = "c6965dd0afea222dbfa75cbbb0043458323e81ffc0efe068d8f523a55f586bee";
  })
  (fetchCosmo {
    file = "socketpair_test.com.dbg.gz";
    sha256 = "69caa48e75deb9b92b0fbec762d284217156949a78cd55c08fe95dec2f8479bb";
  })
  (fetchCosmo {
    file = "socketpair_test.com.gz";
    sha256 = "f4d4803d0a5d665452dd8f038b1ead1add422dc971377df42af8df5a5fe8bb91";
  })
  (fetchCosmo {
    file = "sortedints_test.com.dbg.gz";
    sha256 = "95379ca4379db57d852a33d3e4511849a38ba8d622365967bca36cd6fa8f5154";
  })
  (fetchCosmo {
    file = "sortedints_test.com.gz";
    sha256 = "917a141dbeb25dc330095369052e40b2a4afbe79fb3709dd989bf956f9ec1c9d";
  })
  (fetchCosmo {
    file = "spawn_test.com.dbg.gz";
    sha256 = "1b9281d5c0b960c89da0b8541628e24fb010c2593110cbc2e56f3152de6af7c6";
  })
  (fetchCosmo {
    file = "spawn_test.com.gz";
    sha256 = "061560376a20c4ed09b211baedc5aa950d3b746a4169c87cb05d4fe71f912039";
  })
  (fetchCosmo {
    file = "splice_test.com.dbg.gz";
    sha256 = "c03805ca215775923d6cbc84ff45295da21fe81a0c5d0c07791649aa040351e5";
  })
  (fetchCosmo {
    file = "splice_test.com.gz";
    sha256 = "0aff112115918607083b9e197d976b2309ccc756388023a1b1dd9b442b07b24e";
  })
  (fetchCosmo {
    file = "sprintf_s_test.com.dbg.gz";
    sha256 = "c8ddb5ddc0d65d214e85cb3a4fb27a1265dd54b64f54dd54994e84e3670e300e";
  })
  (fetchCosmo {
    file = "sprintf_s_test.com.gz";
    sha256 = "8e137d0d28674d195e6bac39ebb16e13c5b5f6469d12092a434837b2a46471a6";
  })
  (fetchCosmo {
    file = "sqlite_test.com.dbg.gz";
    sha256 = "78c1c0a97c40057a1f362172a5d8f0bf76feb100639b32e986b64b704260d02c";
  })
  (fetchCosmo {
    file = "sqlite_test.com.gz";
    sha256 = "c3dbca871d78b500789caf8f5d1a25844f42e69b6a15e2a5ec6ae70b3298ffb3";
  })
  (fetchCosmo {
    file = "sqrt_test.com.dbg.gz";
    sha256 = "111af1e179c357558254d0e15aa63613a4b5579163ae164906659ce2a4171c5f";
  })
  (fetchCosmo {
    file = "sqrt_test.com.gz";
    sha256 = "bf2447ccd775a0e1f4edbc55d2fb7e0c08a776f978d76938923a97f3df9e58b6";
  })
  (fetchCosmo {
    file = "sscanf_test.com.dbg.gz";
    sha256 = "0f0e8cdaf8429051c2c049d2710aa3ab411a0d58fb1b29d2c61912cdbff782c5";
  })
  (fetchCosmo {
    file = "sscanf_test.com.gz";
    sha256 = "810ce06561753783ca8764320cd81ac306664f835555745ab080f4accb9e042d";
  })
  (fetchCosmo {
    file = "stackrw_test.com.dbg.gz";
    sha256 = "c0924317f7fb5c8f3ffe75aa6d5329e283120b5bba2ee58aa498f76b92bf8a06";
  })
  (fetchCosmo {
    file = "stackrw_test.com.gz";
    sha256 = "24747a155a923a921d7362890cb87273df03fb30215801b2c9f19f5b790d1641";
  })
  (fetchCosmo {
    file = "stackrwx_test.com.dbg.gz";
    sha256 = "45c37f5598038c7c136858baa6247657df70e5ee136371a799cbc800f42cfb8d";
  })
  (fetchCosmo {
    file = "stackrwx_test.com.gz";
    sha256 = "10d8b5c9b97718d3c9fe2e49216f0b77c96e804c67b660299c1df1ae5b365ddc";
  })
  (fetchCosmo {
    file = "stat_test.com.dbg.gz";
    sha256 = "e01185f1fa66d4e315d808783bdb46a64205861a09e0ca47e53472824a62dd96";
  })
  (fetchCosmo {
    file = "stat_test.com.gz";
    sha256 = "ae30c90bf560542460732c3c787852c7e3cb7f4f769589ae7e68d2b1910ea72a";
  })
  (fetchCosmo {
    file = "statfs_test.com.dbg.gz";
    sha256 = "705750bcbdd7fef23db62023f7558dca4669ec9b7874e1571935aea8ca4bd2f6";
  })
  (fetchCosmo {
    file = "statfs_test.com.gz";
    sha256 = "4471b8db6fae9659f8e6745d578a359a2ff6352330f96bc6421c1cf4c21dec38";
  })
  (fetchCosmo {
    file = "str_test.com.dbg.gz";
    sha256 = "ded03ed781de3f465f34818a339de8d8338071624effaa472fffa60704dffae0";
  })
  (fetchCosmo {
    file = "str_test.com.gz";
    sha256 = "1fad3b777124f041bf91fabf11b4df8d946003cb0d525359dbb459d635124940";
  })
  (fetchCosmo {
    file = "strcasecmp_test.com.dbg.gz";
    sha256 = "cfdc1f7ab5d4bf7fc9ae60890c357a0e95081bee988bc8f891c29307adbeea63";
  })
  (fetchCosmo {
    file = "strcasecmp_test.com.gz";
    sha256 = "9357f1e3060fb46b40021c83a9b6d198d935409a66dce6522edce55d150f4bad";
  })
  (fetchCosmo {
    file = "strcaseconv_test.com.dbg.gz";
    sha256 = "53e8418c344876b726159278d09c2d95a7a5f74000fcd376a604bc60cf69a91d";
  })
  (fetchCosmo {
    file = "strcaseconv_test.com.gz";
    sha256 = "b590f3c389066c1f891a1d8c869137c5359ecf3c83792624fc71872847d529f1";
  })
  (fetchCosmo {
    file = "strcasestr_test.com.dbg.gz";
    sha256 = "31b00b68c794b23336bbcd5dfea2b13057792a5a353159046ec70655b289206a";
  })
  (fetchCosmo {
    file = "strcasestr_test.com.gz";
    sha256 = "f2c20619172d02cc73faee7c5e6f5e9ddebf1041db9dd2f2e430957dedf93ce4";
  })
  (fetchCosmo {
    file = "strcat_test.com.dbg.gz";
    sha256 = "5ece08563c698e65b7341d67e504d2e92970953e1f5b8f4c282f67ef6cea9bad";
  })
  (fetchCosmo {
    file = "strcat_test.com.gz";
    sha256 = "51d18fd6cd4958987e01ff830db134c24a60486d91463fae21f0c1e6312f69bf";
  })
  (fetchCosmo {
    file = "strchr_test.com.dbg.gz";
    sha256 = "cf2934f816ab0eca2e1f887558844e6d5995bb5e72c515aba31e8c8b9d83a2af";
  })
  (fetchCosmo {
    file = "strchr_test.com.gz";
    sha256 = "684c3b22bdc8eb71856b1961a59be5cbf97a086eee3c0c12edbec39c4700086a";
  })
  (fetchCosmo {
    file = "strclen_test.com.dbg.gz";
    sha256 = "63a2a31630a45d6cecb2334ba9d3429ea7ad43fcf0702742e5c455551f0d5a62";
  })
  (fetchCosmo {
    file = "strclen_test.com.gz";
    sha256 = "0158b1c9879a57dd2784d6f74d40d097aadea81d153f983ab07e112f2136251b";
  })
  (fetchCosmo {
    file = "strcmp_test.com.dbg.gz";
    sha256 = "0fc9427474f15bd8a980ab1a080a88fe38628697e0c3096c02499faee383b8fe";
  })
  (fetchCosmo {
    file = "strcmp_test.com.gz";
    sha256 = "863c10bd8f188f8d3aedd9bc43a76b7b3b6fb5cdf80526166f64800bb7052a97";
  })
  (fetchCosmo {
    file = "strcpy_test.com.dbg.gz";
    sha256 = "499726487cd03f7c76328adc6df54e1066ddab7229629237f7fd2c6d361d0fb7";
  })
  (fetchCosmo {
    file = "strcpy_test.com.gz";
    sha256 = "aa9a1435ff5892e4283ae7bae2d0f8e19fa2c619b90df0f781c6cf7d3b44b2b8";
  })
  (fetchCosmo {
    file = "strcspn_test.com.dbg.gz";
    sha256 = "cea196f592ab97662d588ae9347fc0251589d39eeed132e576ddb36d5ad14a45";
  })
  (fetchCosmo {
    file = "strcspn_test.com.gz";
    sha256 = "ad75864b1859fdff3b675279634c333f27b837ae046d6dcf2bd104b90b2a4f87";
  })
  (fetchCosmo {
    file = "strdup_test.com.dbg.gz";
    sha256 = "f0471d34c63c9748708cecb516332e8bb3c0c7f444751a15fde3391d69655ac3";
  })
  (fetchCosmo {
    file = "strdup_test.com.gz";
    sha256 = "7a757cf96971b047ec6205cfe6dc2d8957189d1e35d30b8e70a501896a3afce5";
  })
  (fetchCosmo {
    file = "strerror_r_test.com.dbg.gz";
    sha256 = "074737f13180e4e438f1744896661c9632f4c670fa4c638f0010d2bcc0f5b48c";
  })
  (fetchCosmo {
    file = "strerror_r_test.com.gz";
    sha256 = "407c25db3839d56e7a8a44f3f319f6aaf9d1933df8a85a10c6756c4da844cdbd";
  })
  (fetchCosmo {
    file = "strftime_test.com.dbg.gz";
    sha256 = "ba4eb363153c02b7e95e3c389890188f2525217cd907952d93ecc6f2801f9c0f";
  })
  (fetchCosmo {
    file = "strftime_test.com.gz";
    sha256 = "41c4ac71667d3843b769d8c058e78a4f005550c18bbc8c8c1dc29757ce26f92d";
  })
  (fetchCosmo {
    file = "stripcomponents_test.com.dbg.gz";
    sha256 = "899952ca12b342341a15cb2886e6bf0441894b9a939ea6ea1b6c51c4123f64c5";
  })
  (fetchCosmo {
    file = "stripcomponents_test.com.gz";
    sha256 = "84932ac4a8a44a53a972f6adf33de604a8fd6a713459dcb0a15b16260dbcc129";
  })
  (fetchCosmo {
    file = "stripexts_test.com.dbg.gz";
    sha256 = "7cd7207a8443a669d38da76f5527a821e1a885c6ff85a07b755b87134ee895e1";
  })
  (fetchCosmo {
    file = "stripexts_test.com.gz";
    sha256 = "47753a9501df30fb4f3ecac6e3b291a806165ece7538955d85b0273674f4b79a";
  })
  (fetchCosmo {
    file = "strlcpy_test.com.dbg.gz";
    sha256 = "1e47e2401e3383c37c546bbf88bb4fab1ff36f65875c5620f6e32590999a811e";
  })
  (fetchCosmo {
    file = "strlcpy_test.com.gz";
    sha256 = "a9e6fe76296455fd05a9ab9ac24a1788c6858d61384bfbe08876774b2116f13e";
  })
  (fetchCosmo {
    file = "strlen_test.com.dbg.gz";
    sha256 = "54b269dced3e31328f09c6cbb2aa17c2e308f79d3bbdb96ca02cbf24a2e6a4f5";
  })
  (fetchCosmo {
    file = "strlen_test.com.gz";
    sha256 = "2471d44fbbfdcb7e760dd81e87f95876301ab4a1a7710fbff3ac2e092515d07c";
  })
  (fetchCosmo {
    file = "strnlen_test.com.dbg.gz";
    sha256 = "6ab12007253e4e98dddffb64cf322998305cf3222f4b36f7da01c1bc2c34df03";
  })
  (fetchCosmo {
    file = "strnlen_test.com.gz";
    sha256 = "69104b13079f08f6c6619430519594d27e47586e0fc88de43dd0d26fdd66b31e";
  })
  (fetchCosmo {
    file = "strnwidth_test.com.dbg.gz";
    sha256 = "16764c6f59079a43542e9f3470c3901b33fce9195d2209777194ba2d8172e104";
  })
  (fetchCosmo {
    file = "strnwidth_test.com.gz";
    sha256 = "6c1bb69eed505555e26ffe09b601e82501b1f825cb7e989a4e38535a56483946";
  })
  (fetchCosmo {
    file = "strpbrk_test.com.dbg.gz";
    sha256 = "9a282c0bcbd1eedfb555400b3b9d6d39b3b26bf2aac34e729b8c42bc84801208";
  })
  (fetchCosmo {
    file = "strpbrk_test.com.gz";
    sha256 = "8c4cb441ccb4b86c2c0950813833044076f5e7a8299e1f62483d01145c6e572b";
  })
  (fetchCosmo {
    file = "strrchr_test.com.dbg.gz";
    sha256 = "81dd2993dea1e8200cdda9229eccd2ad98ea7906f3a160c15d3272ae5905de05";
  })
  (fetchCosmo {
    file = "strrchr_test.com.gz";
    sha256 = "2cb7b6c248bb0edadfc592314d5cd399ca35e7cdbf6118d33929061f3729bcb2";
  })
  (fetchCosmo {
    file = "strsak32_test.com.dbg.gz";
    sha256 = "9b58e90193f10ee7b4a731daa0b1528165df1046772519ee39c57bc1a13fd53e";
  })
  (fetchCosmo {
    file = "strsak32_test.com.gz";
    sha256 = "51ff8644af79f5fb95fb616143f24e6449178e95a25e357c2079ad2448c7367e";
  })
  (fetchCosmo {
    file = "strsignal_r_test.com.dbg.gz";
    sha256 = "636188f85d34d506d208854fc73209970e8a3ae8f439dd344be3ace99cf6bbac";
  })
  (fetchCosmo {
    file = "strsignal_r_test.com.gz";
    sha256 = "2180b0a3b8b421d1bdc19014b1e2a635c93f54d4a77d0d126942b1c8fa3cb19d";
  })
  (fetchCosmo {
    file = "strstr_test.com.dbg.gz";
    sha256 = "446a06192701708d69d2a1cdd04d257cc5e7a4f0e786c5a1a4c7508bd8622c5d";
  })
  (fetchCosmo {
    file = "strstr_test.com.gz";
    sha256 = "d41186a88f8676df8a491e0221d8e08988329b1d54466d9a886fbfe43d3d96f8";
  })
  (fetchCosmo {
    file = "strtod_test.com.dbg.gz";
    sha256 = "0c96002acc3faae07d5785d56211907cbfc4751b518f3cbd57bd4f609f07ad27";
  })
  (fetchCosmo {
    file = "strtod_test.com.gz";
    sha256 = "fca4af926a0aa4c79999f7e2489212f23baac7881ae2b5dfc8cb2e9402a0396f";
  })
  (fetchCosmo {
    file = "strtok_r_test.com.dbg.gz";
    sha256 = "38cd119e2933a6eb060612e44108c5a4de418f1329b9cf8f383aa582b171200c";
  })
  (fetchCosmo {
    file = "strtok_r_test.com.gz";
    sha256 = "76b451ff8950958308ce70e291d36f05c0c506d129e63108dc6acbe6bca6a727";
  })
  (fetchCosmo {
    file = "strtolower_test.com.dbg.gz";
    sha256 = "82cbb92f4e71dc83261687c29f5549afa6b7a11bad760f61fb71ba71952ee98b";
  })
  (fetchCosmo {
    file = "strtolower_test.com.gz";
    sha256 = "8ec03d5b03606a3d0c0ff4244ec5b0d23fe128eb04c8f477a63e6f8de594039b";
  })
  (fetchCosmo {
    file = "symlinkat_test.com.dbg.gz";
    sha256 = "493e36aa34e78c259b5fe88419211ea4885f186eb6cd099a7d0dee74b1162871";
  })
  (fetchCosmo {
    file = "symlinkat_test.com.gz";
    sha256 = "8b1e62144021c3e366600071d40cddece64665e195bf164162c8017398fd3bcb";
  })
  (fetchCosmo {
    file = "sys_ptrace_test.com.dbg.gz";
    sha256 = "55733bfa6398f83032e02ae4557237907e053514b24028d187de8b4b1c1fa031";
  })
  (fetchCosmo {
    file = "sys_ptrace_test.com.gz";
    sha256 = "a7e767fd7c63f93e5a7655c72562ec809d2f85dc9a5779532c675ff035b828ea";
  })
  (fetchCosmo {
    file = "system_test.com.dbg.gz";
    sha256 = "0d98b15a2d6763a75559a7a576810dec05c5fadebdaa2e026e138d85f187d0dc";
  })
  (fetchCosmo {
    file = "system_test.com.gz";
    sha256 = "dadf2f2814a3b573287ef05f3a6bd58e46592259a85588b47ed0fbc3c4bcc3a0";
  })
  (fetchCosmo {
    file = "tan_test.com.dbg.gz";
    sha256 = "650da38e2d641267e0d6b58b13ea92b2c699d208c8737da2d6a729052ea3cc0c";
  })
  (fetchCosmo {
    file = "tan_test.com.gz";
    sha256 = "37d6cc558b9575fe5162d07305c4e942163405b5431203ab08bdcc21824d2b06";
  })
  (fetchCosmo {
    file = "tanh_test.com.dbg.gz";
    sha256 = "405de53fd60f6beeb12ece7f72b901cc6dbf0f67d5dcb3761f5631c29155f42c";
  })
  (fetchCosmo {
    file = "tanh_test.com.gz";
    sha256 = "8def315d8ca21a64bd4f47ff4f842adbc3fa7747b481d8dd85f066b546f2e9ce";
  })
  (fetchCosmo {
    file = "tarjan_test.com.dbg.gz";
    sha256 = "9ed43efecf46e03923955fd540f5208efeda0b931a84d3eb8882d9fb5f11374e";
  })
  (fetchCosmo {
    file = "tarjan_test.com.gz";
    sha256 = "28887dd7fc71fd57ecf9de97bb66648e63a1f163a5c4ec72ecfab2604e68b4c9";
  })
  (fetchCosmo {
    file = "test_suite_aes.cbc.com.dbg.gz";
    sha256 = "894fab3f7608a186376cb3c98a690c33b7ae89ead0dbc6ba89b230499eaa011a";
  })
  (fetchCosmo {
    file = "test_suite_aes.cbc.com.gz";
    sha256 = "85ef9656311e876fb6000fc6842239df1baa7585e8c373fd3cbf94c34a4d40c5";
  })
  (fetchCosmo {
    file = "test_suite_aes.cfb.com.dbg.gz";
    sha256 = "9712913da373635b9c4669f47eb96245c9d879faed1d185ee68af95ddaceb233";
  })
  (fetchCosmo {
    file = "test_suite_aes.cfb.com.gz";
    sha256 = "ef856ae59ad36e83f0001886aa7fa087152edb70f636d3c991a529fde7b78f2c";
  })
  (fetchCosmo {
    file = "test_suite_aes.ecb.com.dbg.gz";
    sha256 = "900175ad2aefea31f4debd6393f7fe200337ebdde7521fc6563ebe10312b61a5";
  })
  (fetchCosmo {
    file = "test_suite_aes.ecb.com.gz";
    sha256 = "f80e528ab2c19e7dd9a7ac84b0bc9843b53aca3a7c60260dc7b9ac2c44c319cd";
  })
  (fetchCosmo {
    file = "test_suite_aes.ofb.com.dbg.gz";
    sha256 = "407f2ee28e374d56db5a8a3218ee73774754a7339a14efaa051a0ded1e4c1f81";
  })
  (fetchCosmo {
    file = "test_suite_aes.ofb.com.gz";
    sha256 = "ccf18590dde976c4adec13de308b3121e25d01348bf1ecd851c22b001dc80de2";
  })
  (fetchCosmo {
    file = "test_suite_aes.rest.com.dbg.gz";
    sha256 = "fd49cf14394c22fc8ca0284b1163b786d54ac1b6f405dd6d127e4539cd6ec04d";
  })
  (fetchCosmo {
    file = "test_suite_aes.rest.com.gz";
    sha256 = "c031bf898be86893ed89237b41637c2faf2d366d0c9e7a20478b9ae42a18b039";
  })
  (fetchCosmo {
    file = "test_suite_aes.xts.com.dbg.gz";
    sha256 = "fff373a956b0799b63692a1db51dca1a6002488269d9fbcc32bbd2ac0f43acf8";
  })
  (fetchCosmo {
    file = "test_suite_aes.xts.com.gz";
    sha256 = "de47fe92e462ae08f6be6645b37fcf1e50f734b8b3d5b9e9f20262a47bf86a7b";
  })
  (fetchCosmo {
    file = "test_suite_asn1parse.com.dbg.gz";
    sha256 = "df475367fed6ebc5a4c90e0fa322b371ebeafcb85df76306ed9ca0c0402f7354";
  })
  (fetchCosmo {
    file = "test_suite_asn1parse.com.gz";
    sha256 = "faf14a16be13ec8f1a8cd6a3a660bf65146d78548931400c884f554c305e1d0b";
  })
  (fetchCosmo {
    file = "test_suite_asn1write.com.dbg.gz";
    sha256 = "ac1a38ee95eb25c57e058922ad2085ef829b88d0ef8b29b084326055fc969a19";
  })
  (fetchCosmo {
    file = "test_suite_asn1write.com.gz";
    sha256 = "cb00a47b20461642baec09e55346793175c34433c7995583496a5c6dc06c444c";
  })
  (fetchCosmo {
    file = "test_suite_base64.com.dbg.gz";
    sha256 = "65cc6c19515143ddf869d23807a0ba54b72acb2ac75d1aa5ef88a0d7c6011de0";
  })
  (fetchCosmo {
    file = "test_suite_base64.com.gz";
    sha256 = "fa4b67f2b9a7389bdcd857dc5aa73323672683e7ad4615cb4203be6e1fb17dc1";
  })
  (fetchCosmo {
    file = "test_suite_blowfish.com.dbg.gz";
    sha256 = "8613cf2d1c15d56aa9fbd9742c886e52c5a822449976d6e2d061c6aea54f312d";
  })
  (fetchCosmo {
    file = "test_suite_blowfish.com.gz";
    sha256 = "6b038652bf5db4dd46a3794f0edcb5e19a47e8e4906fa0f9a6e58089024e4ef1";
  })
  (fetchCosmo {
    file = "test_suite_chacha20.com.dbg.gz";
    sha256 = "aafc9874ba08db8655e9cf97b76d4cf9dea9f6b989150de3b71c326a844e9c9e";
  })
  (fetchCosmo {
    file = "test_suite_chacha20.com.gz";
    sha256 = "b36a06829d7c6028a07905096090fb3876e75fe3197406dcb00b49e48654284f";
  })
  (fetchCosmo {
    file = "test_suite_chachapoly.com.dbg.gz";
    sha256 = "e47f3309d28814d2f50528cc84065ba8aed63b251bfc7a8c7e4b4a3553074d25";
  })
  (fetchCosmo {
    file = "test_suite_chachapoly.com.gz";
    sha256 = "eaa6eb3a014b151df48aa34fe665dd4baabf514c3f0488a45e03d96fcf01fbc1";
  })
  (fetchCosmo {
    file = "test_suite_cipher.aes.com.dbg.gz";
    sha256 = "6fcb85b26fc6e4f2c834e24eee82a17f9d5888d5def684a176ea69051e5ff7f7";
  })
  (fetchCosmo {
    file = "test_suite_cipher.aes.com.gz";
    sha256 = "d4758026ef45385dcd7a9a1e2d6c35c5d89b2c15e181d7bf24216f52cedb2d14";
  })
  (fetchCosmo {
    file = "test_suite_cipher.blowfish.com.dbg.gz";
    sha256 = "6cc199eb3345c3db99374f127248a2244977af08ef8da5fb953e3b262e133d5d";
  })
  (fetchCosmo {
    file = "test_suite_cipher.blowfish.com.gz";
    sha256 = "b64f1bbd67c2d0b57e6f025a0f60821b2502c49e924863e1180118e9ade99bc6";
  })
  (fetchCosmo {
    file = "test_suite_cipher.ccm.com.dbg.gz";
    sha256 = "9e770989a32d00c5c15ce95f5f45cea0ed8087aec0aae76852a8b9e1a0040693";
  })
  (fetchCosmo {
    file = "test_suite_cipher.ccm.com.gz";
    sha256 = "86bae6c7494e2b306ebc58962a54fad86dc1305e61a921721011d6be46269d35";
  })
  (fetchCosmo {
    file = "test_suite_cipher.chacha20.com.dbg.gz";
    sha256 = "15268eedfa1f449947b00ebfea513e33f1914d816b228c83eabe295453f0d0f8";
  })
  (fetchCosmo {
    file = "test_suite_cipher.chacha20.com.gz";
    sha256 = "1836de894fa43f9924d6fca53c86329aac83821f636fdd334098950668de088f";
  })
  (fetchCosmo {
    file = "test_suite_cipher.chachapoly.com.dbg.gz";
    sha256 = "7ff112c75aad82d4f1718ae09a1be4eea6d4fb6847e6526e880535c9a8d5f1be";
  })
  (fetchCosmo {
    file = "test_suite_cipher.chachapoly.com.gz";
    sha256 = "fa07693949806d03e113ced0b4c50203a5aeeecf89194dbb0e63292c2abbb572";
  })
  (fetchCosmo {
    file = "test_suite_cipher.des.com.dbg.gz";
    sha256 = "6c33a24e5acfd4e5d991f98526bf5df5b347412970013bda6fa030e37d471b57";
  })
  (fetchCosmo {
    file = "test_suite_cipher.des.com.gz";
    sha256 = "4c09ded73b0f07cc6c30704bc7d4d1c018385edb450708d145d4d19d5734b4e3";
  })
  (fetchCosmo {
    file = "test_suite_cipher.gcm.com.dbg.gz";
    sha256 = "ef0174340d4a18ce45b996308dd6e71b561090a63db25b671aa791b6c32a4abb";
  })
  (fetchCosmo {
    file = "test_suite_cipher.gcm.com.gz";
    sha256 = "b6a4d9f8e2c3833fc4db91bb3d0247b37d432b7bb7247e8c962df37afe24ca99";
  })
  (fetchCosmo {
    file = "test_suite_cipher.misc.com.dbg.gz";
    sha256 = "b53a2c3049f2c5b5e448cc1108af0603125d37a06b671262c24b6cd202d6c97a";
  })
  (fetchCosmo {
    file = "test_suite_cipher.misc.com.gz";
    sha256 = "f33386a818a8f043e82ff4f4676f3caf5c7fc79383333348d40645b3ab1b245c";
  })
  (fetchCosmo {
    file = "test_suite_cipher.nist_kw.com.dbg.gz";
    sha256 = "ef138326dc1cd5c6d237933c292a4021cce99219c220d870fd2beeb871943d44";
  })
  (fetchCosmo {
    file = "test_suite_cipher.nist_kw.com.gz";
    sha256 = "25e49bd42eb4ebcd30ca9f8e038b491436fb9754475579f3a758267ddf0bc137";
  })
  (fetchCosmo {
    file = "test_suite_cipher.null.com.dbg.gz";
    sha256 = "975c66d7d10a8a9876d89c985527067175010df28b0dd12e1e21b9f78774dcc6";
  })
  (fetchCosmo {
    file = "test_suite_cipher.null.com.gz";
    sha256 = "17ab5d41bcbe8f0bc3111a097b031477d182135bad2eb1fe85807d12572b478b";
  })
  (fetchCosmo {
    file = "test_suite_cipher.padding.com.dbg.gz";
    sha256 = "477d11e79dc81d456e2ed5d5a0dfbfaf80377c6e0fad5538729e58e2345d552c";
  })
  (fetchCosmo {
    file = "test_suite_cipher.padding.com.gz";
    sha256 = "a20d4ec658cc17032b87817eb77fa14e7be9d0e9a5915945f2c3ff330fc51afb";
  })
  (fetchCosmo {
    file = "test_suite_ctr_drbg.com.dbg.gz";
    sha256 = "b51cac9e0b878223ba1f0778b46939d34947ee48017ea896e95d2e068922e79d";
  })
  (fetchCosmo {
    file = "test_suite_ctr_drbg.com.gz";
    sha256 = "dcd6752e8f36ae0bd97b0776980eb5b43c9097aedb3c6d35e9bc9ce6ed8fb72e";
  })
  (fetchCosmo {
    file = "test_suite_des.com.dbg.gz";
    sha256 = "49d83828d5490f707562258f4317176570a54a57bccf28dc4380f63875382cde";
  })
  (fetchCosmo {
    file = "test_suite_des.com.gz";
    sha256 = "78f9943113cd2e5aec3e29c6184f9f99c6ee8e36856b58c3b84d71f4952e5575";
  })
  (fetchCosmo {
    file = "test_suite_dhm.com.dbg.gz";
    sha256 = "08d201d1643e8e886278b49119a03fdd966bb2bb2ae323fa6944817544a44c15";
  })
  (fetchCosmo {
    file = "test_suite_dhm.com.gz";
    sha256 = "d4df29df3f0b35091550b5b1356c23a74e899039193c12f091d274521e59fe44";
  })
  (fetchCosmo {
    file = "test_suite_ecdh.com.dbg.gz";
    sha256 = "dd475853821de50b013587e76a08dbd72b1a88d9a6cce82bd33c861ba34748e7";
  })
  (fetchCosmo {
    file = "test_suite_ecdh.com.gz";
    sha256 = "26bee59d291de22cf4b13a6acfeff42ae5c962b99efdbdbc517c13ffcbf5aa62";
  })
  (fetchCosmo {
    file = "test_suite_ecdsa.com.dbg.gz";
    sha256 = "c13d985b61d70496078ddec8209ff28e5519441210e002958a8961da04665c3d";
  })
  (fetchCosmo {
    file = "test_suite_ecdsa.com.gz";
    sha256 = "bee3fdf9db9d02b4a916f51306beeb1cb4b1b1042817d3cf44f605ba1b221b5c";
  })
  (fetchCosmo {
    file = "test_suite_ecp.com.dbg.gz";
    sha256 = "2bc77353222fd885ba0a7fa202e2c62f54cc4f86352f299d425bbf4655409a99";
  })
  (fetchCosmo {
    file = "test_suite_ecp.com.gz";
    sha256 = "3e1476f611051f8fb10113a9882e921eb9b5c0b3326c40311ef23c1005f49beb";
  })
  (fetchCosmo {
    file = "test_suite_entropy.com.dbg.gz";
    sha256 = "86bbdcde1fa2a2be63b80ea21bffd19aa2a160741109ec147a73e957cc1b6873";
  })
  (fetchCosmo {
    file = "test_suite_entropy.com.gz";
    sha256 = "d11be302f5b192fb4b2bcd06b7595428f6c928a5350ef0540b7c100403f36368";
  })
  (fetchCosmo {
    file = "test_suite_error.com.dbg.gz";
    sha256 = "c22d51506abda5ecc5be8eee178d3b87f8c16ea0324ca332b87851af5c2c2fcd";
  })
  (fetchCosmo {
    file = "test_suite_error.com.gz";
    sha256 = "8a0b55f0223fb7c51ff55e31359a2aa7fc78735f3b95ef1ee1206b710ccf0ba4";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes128_de.com.dbg.gz";
    sha256 = "f93c4b630d0a62cbb4fe5b8e4f1d1b74478b990e6fd0054febba745fc13b6546";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes128_de.com.gz";
    sha256 = "9feb3efb18daae46b2edf45cac274866c373c54c4088d21388bc9292ba320fd5";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes128_en.com.dbg.gz";
    sha256 = "a93d30a707a4081a5297b1951e0603b146aeddbc111bc4359f68f7920600731f";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes128_en.com.gz";
    sha256 = "8fbe37baefee1497c1463c30bfe2fdbdd29005be4de70a71c2c7ec2c48922c67";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes192_de.com.dbg.gz";
    sha256 = "725d29c76d1f1260e3450028d7814d7d74bf0e4f219a989e523a8e04a9e07604";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes192_de.com.gz";
    sha256 = "4fb0a16802c8a7ec81a49f6ac70715bad4eef77849958e0c7b875838bdee2e78";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes192_en.com.dbg.gz";
    sha256 = "1eb290aa263c9eb0bd5cd1e97b8213f4c11d6bde63f66f9e8fdbb5cf50905a55";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes192_en.com.gz";
    sha256 = "7cdf8cd41236bd644110490f90b17013c99a569e1e2e065ac8fcbf2777fb6847";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes256_de.com.dbg.gz";
    sha256 = "46f2a120ee328552c3d028a60dbeb3806bf2e67a67c6d8612de34cba65aa873b";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes256_de.com.gz";
    sha256 = "11e13598fd23569046e2897e3fd2027f405de48d24c1b024ab39cd69c50a97d7";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes256_en.com.dbg.gz";
    sha256 = "0608eef00f9d8a7c0d915dcfc8d66f5a6fa5678dd1c76c8832eda33ec75c2fae";
  })
  (fetchCosmo {
    file = "test_suite_gcm.aes256_en.com.gz";
    sha256 = "ae1ca6400387c91b9990d9c832147966feb62a5ef549e9bf44bf26351d972dfc";
  })
  (fetchCosmo {
    file = "test_suite_gcm.misc.com.dbg.gz";
    sha256 = "2801f04c0a84f23a4fd53079cd9af8b15cf568a28c43cf1e2b0d91503c03a74c";
  })
  (fetchCosmo {
    file = "test_suite_gcm.misc.com.gz";
    sha256 = "1408e57f7d12edb532015f7b46ac8ee5adf140769beca9932145d8d4c0bc1e62";
  })
  (fetchCosmo {
    file = "test_suite_hkdf.com.dbg.gz";
    sha256 = "b9358479dd205b4a0f306c1585b8aa6a7262cc0b0d167414cf8e288e6d050173";
  })
  (fetchCosmo {
    file = "test_suite_hkdf.com.gz";
    sha256 = "3d49b88013e2fc991caa404830c7c7d87dbf3af7d3d7c7b96638079fee55b79e";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.misc.com.dbg.gz";
    sha256 = "ecebd3cdd7cf31dc3df5dc2bf7b01ef28e26b015d3963d34a7e863edaad40203";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.misc.com.gz";
    sha256 = "bc1dfae4b46b31376306e044f1fe5374b8a47b27d643551a603c36d35ae9a4fb";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.no_reseed.com.dbg.gz";
    sha256 = "e5357685088b05e9b03c133d47e7c3fbf43d82b21b1fe577e1e0e97e2898c5cc";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.no_reseed.com.gz";
    sha256 = "a1f60eb97eb9686c67202664bf7b3e522c02bbecf26e7ff85def4734fec10fae";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.nopr.com.dbg.gz";
    sha256 = "a9ca22ac108cd807e56b389d8e0af6c90036af0e170bf3286e622bcdf3cb636e";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.nopr.com.gz";
    sha256 = "c18bf8137abf43385360043b9196ed0c81f23c31966b8d3261cbc9881590e790";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.pr.com.dbg.gz";
    sha256 = "7871587e9853ba38a21869eb40b0d258e1bc8f6555b92876604a09a71265d2e9";
  })
  (fetchCosmo {
    file = "test_suite_hmac_drbg.pr.com.gz";
    sha256 = "63fa5e629f52d759e50cbe54b9e9764d3a9da590e8c801a9a58574934a0d206a";
  })
  (fetchCosmo {
    file = "test_suite_md.com.dbg.gz";
    sha256 = "8da5330ec3e5b72a73afb8f654cbd92830a39c69b9bcc8e7cf11424651e3dd42";
  })
  (fetchCosmo {
    file = "test_suite_md.com.gz";
    sha256 = "c21b65e7830f0472bee74a8aaef8ca9cfa902fa9e38b9a3379d7fdf6f420c800";
  })
  (fetchCosmo {
    file = "test_suite_mdx.com.dbg.gz";
    sha256 = "b170332f148ec143fe70b46a31bc5179c6f54cad2ebbfdd365ff0071bb718d12";
  })
  (fetchCosmo {
    file = "test_suite_mdx.com.gz";
    sha256 = "8097c1a58f35d3c44d9753e10daeb2d5e41e47fefbe47ddd8fddd023e4496e0b";
  })
  (fetchCosmo {
    file = "test_suite_memory_buffer_alloc.com.dbg.gz";
    sha256 = "663020496a1e887988f5d2984fee5bdf83d4a9085437372584fce59d004e3588";
  })
  (fetchCosmo {
    file = "test_suite_memory_buffer_alloc.com.gz";
    sha256 = "76001252ed21c20fc551fc85ab672db7e037cffec592b412fc6c9dcac26404df";
  })
  (fetchCosmo {
    file = "test_suite_mpi.com.dbg.gz";
    sha256 = "5f81ff565e415381e39c6e8a83bccf6c71cb427d699802f57ef9814f7ef5ed46";
  })
  (fetchCosmo {
    file = "test_suite_mpi.com.gz";
    sha256 = "8a6dcc7caf054fadf088fe751dda009ec8e94f9a9c7cc3d751a08a864feba7a7";
  })
  (fetchCosmo {
    file = "test_suite_net.com.dbg.gz";
    sha256 = "8b3b0a39b2ba7db6af5fc2bd665b4314af468c916dab6701c9d79e004ec5d442";
  })
  (fetchCosmo {
    file = "test_suite_net.com.gz";
    sha256 = "604a687fe7a1754b1bb76a60d008c0abf371b0403adfada1dee0250249902e21";
  })
  (fetchCosmo {
    file = "test_suite_nist_kw.com.dbg.gz";
    sha256 = "85ae2696ce045b3182409fdc9d177895d8115d581d887c36b7c7ba3a82cad660";
  })
  (fetchCosmo {
    file = "test_suite_nist_kw.com.gz";
    sha256 = "3573f6ff68389a670e4fe6d49542a41b22a8206c6e49d6988da607ac2f6c773b";
  })
  (fetchCosmo {
    file = "test_suite_oid.com.dbg.gz";
    sha256 = "b2831aa2667484cbeefffdb0b16fc75de9f3b8a0833a4a5ad09467eaf40cc45f";
  })
  (fetchCosmo {
    file = "test_suite_oid.com.gz";
    sha256 = "bcee392d443a401434881dada76f07f47a9e761c54eb4a542794e2046a8a2890";
  })
  (fetchCosmo {
    file = "test_suite_pem.com.dbg.gz";
    sha256 = "c61fc25dbf9eafbc9465d851f44a8b0193928066ce2caac029318417f18f97d3";
  })
  (fetchCosmo {
    file = "test_suite_pem.com.gz";
    sha256 = "278802f87a33e8721184ded72bbfaa1c967aa86265e51e9744a3a025fa20a202";
  })
  (fetchCosmo {
    file = "test_suite_pk.com.dbg.gz";
    sha256 = "67a171acd8950cd45fec51b93c947f6f7ef249b57d8acb3b11afa9ad30058820";
  })
  (fetchCosmo {
    file = "test_suite_pk.com.gz";
    sha256 = "325a8266957c475769682131cbeaa18f61cbdb4ee4bfdd796303dff9f3440a49";
  })
  (fetchCosmo {
    file = "test_suite_pkcs1_v15.com.dbg.gz";
    sha256 = "443fae48e511b3248aa23af4bf302d49911865444446db9fa4de4fdf8f52ac94";
  })
  (fetchCosmo {
    file = "test_suite_pkcs1_v15.com.gz";
    sha256 = "59e9db28eddb0634db95aa24e4a751c3ee00351c36d5f1ab5cd0e309d901ec5b";
  })
  (fetchCosmo {
    file = "test_suite_pkcs1_v21.com.dbg.gz";
    sha256 = "bf3970a2a905a810e49a7efd8946d80c8cde78bdf6755689396947aa1c74e4e7";
  })
  (fetchCosmo {
    file = "test_suite_pkcs1_v21.com.gz";
    sha256 = "3b47bc730bc0edb13822c82e5d84dfba424e655d9756d03b426958d7dec679ad";
  })
  (fetchCosmo {
    file = "test_suite_pkcs5.com.dbg.gz";
    sha256 = "09dc26ffad20edeca9aa8026094a1b40baa4097a5aae12d05a356e00573ecb01";
  })
  (fetchCosmo {
    file = "test_suite_pkcs5.com.gz";
    sha256 = "2439c701673bbf4b6641a495b8ba1adfe96b3c54e798da6d803670177fc04239";
  })
  (fetchCosmo {
    file = "test_suite_pkparse.com.dbg.gz";
    sha256 = "0e92e4c45c6ea07592a30eb23867bfe0618779b68b0306b373446620b78fc62a";
  })
  (fetchCosmo {
    file = "test_suite_pkparse.com.gz";
    sha256 = "5a9ca5de49e6cf52337abd053b8338bd0e5be6f907faffd9db971e29d798fb80";
  })
  (fetchCosmo {
    file = "test_suite_pkwrite.com.dbg.gz";
    sha256 = "d61ff6776b99e4ece99415e138f9b8eb36590ce25b11cca72bb9dc6098f062fa";
  })
  (fetchCosmo {
    file = "test_suite_pkwrite.com.gz";
    sha256 = "4a6aa7684d06758651777882de8355ebb75d5db3d02c28e50ca3384dab4e13a7";
  })
  (fetchCosmo {
    file = "test_suite_poly1305.com.dbg.gz";
    sha256 = "3d547c4d3ff9899f215c8ac8c78708854feb5bb0e83c800ab179df3df5c9a1c2";
  })
  (fetchCosmo {
    file = "test_suite_poly1305.com.gz";
    sha256 = "7f3a04b03aecb53228975b38f09c8d5d9fc7b206b5fdb646955e4b192186cebb";
  })
  (fetchCosmo {
    file = "test_suite_random.com.dbg.gz";
    sha256 = "76bc16fde4881d11c0ab6bb8f019d07544ff46d6e2304bae545f670121fa2883";
  })
  (fetchCosmo {
    file = "test_suite_random.com.gz";
    sha256 = "d081021d4f45d3fdb1c2284444889e4fa055d10e05e8ce11b752ca55d262a969";
  })
  (fetchCosmo {
    file = "test_suite_rsa.com.dbg.gz";
    sha256 = "13bdef2f6ad8b7706998b8b576874978c0d5f007dce231ba021ea799721bd12b";
  })
  (fetchCosmo {
    file = "test_suite_rsa.com.gz";
    sha256 = "d014f1cf1ce9ef4a7f5024c1ad42bb43569bb305b201f94487539588489eb801";
  })
  (fetchCosmo {
    file = "test_suite_shax.com.dbg.gz";
    sha256 = "3f56df8e6e534ad179b177f00501e703de348547665e96e7bc1db72d3b98e6fb";
  })
  (fetchCosmo {
    file = "test_suite_shax.com.gz";
    sha256 = "997418f17fdb60e15ee2a582db59b8dc717fcb7e0f3f1811faa8016be5238eba";
  })
  (fetchCosmo {
    file = "test_suite_ssl.com.dbg.gz";
    sha256 = "630d5953b1ba28c8e670b1e6b235afdb3a87470cfa00514d0e113cda173e1e72";
  })
  (fetchCosmo {
    file = "test_suite_ssl.com.gz";
    sha256 = "7b8e5b99641eaaea78c96148b9d6dfcd026387db6660cca1dff2dc5d24e3b964";
  })
  (fetchCosmo {
    file = "test_suite_timing.com.dbg.gz";
    sha256 = "5c8a232d61afb2d649d14c9e1b45e06089383f4ca7e43b7db48881dcad259d83";
  })
  (fetchCosmo {
    file = "test_suite_timing.com.gz";
    sha256 = "b7816b70b64fe1001ff6d016397eb8853d7cd56a93786f1e30b56eff8a0d7e1b";
  })
  (fetchCosmo {
    file = "test_suite_version.com.dbg.gz";
    sha256 = "18636ab02cf6e140ea7293fc04c8d996b5639a27c8464af4ad9a6905ad7d34e9";
  })
  (fetchCosmo {
    file = "test_suite_version.com.gz";
    sha256 = "88ae6c179987f88c07cde43e01a6fe16adf5154bb2967532dcda8c53bb89adb2";
  })
  (fetchCosmo {
    file = "test_suite_x509parse.com.dbg.gz";
    sha256 = "8d834d75c857a7346e20eb6c829ec2aeef4b936ad9b02a4aefcbafd4729790ba";
  })
  (fetchCosmo {
    file = "test_suite_x509parse.com.gz";
    sha256 = "a028cea72d7d2c8f8817f47ea753ce532e51d3f07a140d559ab337be9fc1e496";
  })
  (fetchCosmo {
    file = "test_suite_x509write.com.dbg.gz";
    sha256 = "63a6d1f9bcd6477e9befa6d1e79dce045d9b955dbf4d56709e7b403f057c229d";
  })
  (fetchCosmo {
    file = "test_suite_x509write.com.gz";
    sha256 = "c2421fc678e51a0a9cadd4306b4a13edbdb7b63c0d2b305fb7972f27aa415559";
  })
  (fetchCosmo {
    file = "tgamma_test.com.dbg.gz";
    sha256 = "1b6fc586c3c35d3e749c5350334fc2b1a067e779d38045eb2383befc948aed51";
  })
  (fetchCosmo {
    file = "tgamma_test.com.gz";
    sha256 = "dd5a46eb7c0013c49dc65dbad0cbc3885541322b33f7f901adc31bc13f71d732";
  })
  (fetchCosmo {
    file = "timevaltofiletime_test.com.dbg.gz";
    sha256 = "1912ba360a7a62963c0883213a48cd339297e7881bd6a168cb29c9cf5e449ccd";
  })
  (fetchCosmo {
    file = "timevaltofiletime_test.com.gz";
    sha256 = "fd566c2a22bfd87fc969e6107d040abd1b62e7e346946464a37e26a3d28a975e";
  })
  (fetchCosmo {
    file = "tkill_test.com.dbg.gz";
    sha256 = "cd6f2498e6550da6a9fed5cf999a74080adb2e826b6885fec33342ddd223ce9b";
  })
  (fetchCosmo {
    file = "tkill_test.com.gz";
    sha256 = "bca5e12542e3e75e8f638a2c712eb3b74da55304bcfdb22ceb1f7b4d6990f379";
  })
  (fetchCosmo {
    file = "tls_test.com.dbg.gz";
    sha256 = "f5b260a658f9af9e169571b10de0f99ab83e1be54d3e1f6803f852a7fd75f6ee";
  })
  (fetchCosmo {
    file = "tls_test.com.gz";
    sha256 = "695ee274f42353e6b6e16f5c08e96c46ea7ab34372c82df833ccee470ae9e795";
  })
  (fetchCosmo {
    file = "tmpfile_test.com.dbg.gz";
    sha256 = "00cb6ccc04fdd65c58055d564d8abb9e4b2546d932b6f77a607b9a0fe2e156db";
  })
  (fetchCosmo {
    file = "tmpfile_test.com.gz";
    sha256 = "9ad581ea7e7942a8bead4de0d53eca1058e7df64172ee21d5a0ebb793084d040";
  })
  (fetchCosmo {
    file = "tokenbucket_test.com.dbg.gz";
    sha256 = "bacb2f4117b167e6eab4e005cd3db43908d1657547135db99dc5f9df0587540b";
  })
  (fetchCosmo {
    file = "tokenbucket_test.com.gz";
    sha256 = "f332239aa78b436e538c076c8198adc09fbcf575b6c38ae849a480a6de5b0d4c";
  })
  (fetchCosmo {
    file = "towupper_test.com.dbg.gz";
    sha256 = "dc2c37fcb03824a1a6f8e36b4551779827bd819a80eef83548f8518e644d784c";
  })
  (fetchCosmo {
    file = "towupper_test.com.gz";
    sha256 = "a83d18f56db13e2409214b536a2f4156c1a91734736cc46a86c95329addbe779";
  })
  (fetchCosmo {
    file = "tpenc_test.com.dbg.gz";
    sha256 = "83cf663f5d22841ca1e14193d9a0cf6e9c49621ab145232f931f4cab540dcfc9";
  })
  (fetchCosmo {
    file = "tpenc_test.com.gz";
    sha256 = "e25363afa322de025d549222d99579e932dbcb106a0792bb1702ed5a50137329";
  })
  (fetchCosmo {
    file = "tprecode16to8_test.com.dbg.gz";
    sha256 = "2a77d3e20bba860c4dcb38f488cabe2aae39246184bf3f154a28b8c7cca5fe79";
  })
  (fetchCosmo {
    file = "tprecode16to8_test.com.gz";
    sha256 = "4e63f2d25029bce0051d3b1d84cb6b76b3c692c8bf8f0f4e130210af2daf48b2";
  })
  (fetchCosmo {
    file = "tprecode8to16_test.com.dbg.gz";
    sha256 = "e3f2f4df80d9d6e32c60654abb509164269bdde4a2b7409026e0e8b7a337c8d3";
  })
  (fetchCosmo {
    file = "tprecode8to16_test.com.gz";
    sha256 = "27b4cdd3fe71061bec52ab61105f2a338dc68ad61169c0bcb44aeabd2ec38dcc";
  })
  (fetchCosmo {
    file = "trunc_test.com.dbg.gz";
    sha256 = "b5407aca1f459deb5c7724209d5abf0ac9fe25eef17efdf3c46d8acd2b12c29e";
  })
  (fetchCosmo {
    file = "trunc_test.com.gz";
    sha256 = "039bf561776a6f964d78060be3a003dd26bfb6c58da707a1ac6aa79dbdf3096e";
  })
  (fetchCosmo {
    file = "ttymove_test.com.dbg.gz";
    sha256 = "1b65f82a176f70a29008c08e3a32bcf74f2d5b5980024036a6ee0e94b4abe55d";
  })
  (fetchCosmo {
    file = "ttymove_test.com.gz";
    sha256 = "2d20e82c2b90a32e93acb94cade8162fdb44cc49e22b233d8e92866cf3ca07d2";
  })
  (fetchCosmo {
    file = "ttyraster_test.com.dbg.gz";
    sha256 = "e3123ede3b785e36523ece448dc4fe2279693827bd953e3431ef5bac7ecc9be8";
  })
  (fetchCosmo {
    file = "ttyraster_test.com.gz";
    sha256 = "42c3d7c6778fae09bead0556dc8f26fb557831cbac5d70dabeb9f620e430bd3c";
  })
  (fetchCosmo {
    file = "uleb128_test.com.dbg.gz";
    sha256 = "fd7f33d8e187c236ab17991ee473839dec44409dc58e0521d1877597534108ba";
  })
  (fetchCosmo {
    file = "uleb128_test.com.gz";
    sha256 = "72ad186035a0b1994e77748e8ecedba2d893877fed81bd1156cd99dd8e05037c";
  })
  (fetchCosmo {
    file = "uleb64_test.com.dbg.gz";
    sha256 = "44ab6af3ad420f722fa3685647271a5a384135bf11c44254ba71c22ac395c05e";
  })
  (fetchCosmo {
    file = "uleb64_test.com.gz";
    sha256 = "3559bc8e932573db19e336298aa105f0467c535175023aad04de7b7c97a40136";
  })
  (fetchCosmo {
    file = "unchunk_test.com.dbg.gz";
    sha256 = "a58f3e665fdb001ef2b3aa97a693694769b990a99f33a896b6f1eb9c2c657a80";
  })
  (fetchCosmo {
    file = "unchunk_test.com.gz";
    sha256 = "07f16d7ece1d0d66801c990ef92011c39a10a08e4d07fa62f377d22679c277f5";
  })
  (fetchCosmo {
    file = "underlong_test.com.dbg.gz";
    sha256 = "07e66419cd8515dfaf4236997673c6d948d4b258c8d42c3774ec1e2c8866f8e9";
  })
  (fetchCosmo {
    file = "underlong_test.com.gz";
    sha256 = "53ff56228de731f47bc9b1a0291a82b3ee70363a920043374c4be46089563309";
  })
  (fetchCosmo {
    file = "ungetc_test.com.dbg.gz";
    sha256 = "47ea3dcac3d176deb6c8766c46d326eaf6bf6025594ba312820b40a1bbaa2ada";
  })
  (fetchCosmo {
    file = "ungetc_test.com.gz";
    sha256 = "3d19b5e80d553926923fd473f590e8be2304f1add6c1aeda71bb28fd915ac46a";
  })
  (fetchCosmo {
    file = "unix_test.com.dbg.gz";
    sha256 = "7c5dfe91756b69ff166d124a232c776b2b6d107bda7da405781e55c7a7485956";
  })
  (fetchCosmo {
    file = "unix_test.com.gz";
    sha256 = "32f49c5ea599732cecd4202c8d4ab3b16bd205750b730513ad89bd5440471a52";
  })
  (fetchCosmo {
    file = "unlinkat_test.com.dbg.gz";
    sha256 = "81dfa3a2ff04f43c7fcd3ffeec74ec82dc10791354f93c4e89c75cb02c37c37d";
  })
  (fetchCosmo {
    file = "unlinkat_test.com.gz";
    sha256 = "d4416f72722cc9a16fb645901bd18d8d7fe9d9cf781df78b3f8b6f82dfbcde9a";
  })
  (fetchCosmo {
    file = "unveil_test.com.dbg.gz";
    sha256 = "e1f61f13e36128c709b6642e28b0ef049f4bf2d6c0dfc1494104286a59e77d98";
  })
  (fetchCosmo {
    file = "unveil_test.com.gz";
    sha256 = "9c1e881df86827a03c52b8a845c7462a6ee43605d1dcebdb3507bf30f75c3789";
  })
  (fetchCosmo {
    file = "utf16to32_test.com.dbg.gz";
    sha256 = "2ba8ee0411f8b58475b689fe9ceb8e8292601c86235d3e80ca46d6b105180c26";
  })
  (fetchCosmo {
    file = "utf16to32_test.com.gz";
    sha256 = "0ebc15cd47f3dd0b410dbe82fbfe3e0ad5eb72d9578aac5e24ec969997d1e095";
  })
  (fetchCosmo {
    file = "utf16to8_test.com.dbg.gz";
    sha256 = "cb0f288cfbb19b19632f324cedc865de78a34fadae2478a8f77eabcbb72f630e";
  })
  (fetchCosmo {
    file = "utf16to8_test.com.gz";
    sha256 = "50f5208329824169f178169ae6b4423fe2940c9f1ab6b2d92db41fb4b4911c44";
  })
  (fetchCosmo {
    file = "utf8to16_test.com.dbg.gz";
    sha256 = "a0382141e77e92bc0ce0284bf5675ebe5b03f11f45d34007c19707dbc61e3148";
  })
  (fetchCosmo {
    file = "utf8to16_test.com.gz";
    sha256 = "c6ca3c9c6ae0dd0b2669d8ff1e64a919aa4b9e1d30556eadca4da378695f04d9";
  })
  (fetchCosmo {
    file = "utf8to32_test.com.dbg.gz";
    sha256 = "50153631c8f89da7aff695c15caf365270d2aef02efec83ddf848cd79f8ef75d";
  })
  (fetchCosmo {
    file = "utf8to32_test.com.gz";
    sha256 = "5d685a8917c31f2537779c5cffa3203de83134a6d010781d1111c1fc4454f50d";
  })
  (fetchCosmo {
    file = "utimensat_test.com.dbg.gz";
    sha256 = "c94984c0f4dd5c803d06dda3bc565495d12689cd7bc68a6f52bb3f0ac86a2607";
  })
  (fetchCosmo {
    file = "utimensat_test.com.gz";
    sha256 = "6ec6986c7f41ce9d66197f8b826728c1e769eec31a574f82e1f6fe3f1dffc309";
  })
  (fetchCosmo {
    file = "vappendf_test.com.dbg.gz";
    sha256 = "d533d5c3568a97a5e42ff83752fbb794425fbe21f480ed1579c2e73b0ed424ec";
  })
  (fetchCosmo {
    file = "vappendf_test.com.gz";
    sha256 = "e7a7bde5d0b83adaaed7487ae0eaf0ac52f6eee5767d40a1d3bd4da8e54eec94";
  })
  (fetchCosmo {
    file = "vfork_test.com.dbg.gz";
    sha256 = "c770dabf6b912964d96efd6f17b9b12667d07957707da51a0b84d7c00849d213";
  })
  (fetchCosmo {
    file = "vfork_test.com.gz";
    sha256 = "6e172163551d58dbfde9599c0a0a55c83e4ad2e454cb394782cfb0607e51e3d1";
  })
  (fetchCosmo {
    file = "visualizecontrolcodes_test.com.dbg.gz";
    sha256 = "b5ffdd4a4fd7a4dea093bd79a4a125ea4a1b8463c18cd1a50659aec804abb53f";
  })
  (fetchCosmo {
    file = "visualizecontrolcodes_test.com.gz";
    sha256 = "ce8bfd7d65e92b52fbf7503c8770b432e91ac9e6779a3a95c1defdf3125556ab";
  })
  (fetchCosmo {
    file = "wait_test.com.dbg.gz";
    sha256 = "201feb4fd3d58eb83ebf812b33a5e2f00cacad7e49fdd5a59658c8f47e3d83d9";
  })
  (fetchCosmo {
    file = "wait_test.com.gz";
    sha256 = "936f8c6c4de9600e8a502f4d6476ca52b1ea08397c79ca38bfc249ff36d8d6a1";
  })
  (fetchCosmo {
    file = "wcsrchr_test.com.dbg.gz";
    sha256 = "9adc19fce6a309ba7c1b022bd24c9ae7beea134bfd321e07e6cb5918692ac5fd";
  })
  (fetchCosmo {
    file = "wcsrchr_test.com.gz";
    sha256 = "6b49c698d4d9413ef34c3c5d2adc0ab5fb517f6c7948d09bc2bbb4b70086e663";
  })
  (fetchCosmo {
    file = "wcwidth_test.com.dbg.gz";
    sha256 = "663cf6df3e51fd16e64e8f25e931169f5e045b8f0a1ca3e1e9008542dbbe1a3c";
  })
  (fetchCosmo {
    file = "wcwidth_test.com.gz";
    sha256 = "668a688432f62cf1da7685ae3ea12a2570cd071ae9442d7af8949724d960f87d";
  })
  (fetchCosmo {
    file = "windex_test.com.dbg.gz";
    sha256 = "c00a4de71a0aa3795b63c3b3cea957202a1a28fae1dc3a011767cf9c0bfc120d";
  })
  (fetchCosmo {
    file = "windex_test.com.gz";
    sha256 = "521f1e75cca7f961adcf7df843f9b319a2cf00d490bd9bc1f432f5e4d7bd82ae";
  })
  (fetchCosmo {
    file = "wmemrchr_test.com.dbg.gz";
    sha256 = "4ba81018fc32b1a6059befc53a198f30e178686bf59bfa46b959533dff04d834";
  })
  (fetchCosmo {
    file = "wmemrchr_test.com.gz";
    sha256 = "0ac4aa8efc300a03d0df5180371dba5219c6eb7e57daa714fb8fb1a1d9eec5ac";
  })
  (fetchCosmo {
    file = "write_test.com.dbg.gz";
    sha256 = "4307db7fbd1fb6591c3d0d538b6ef4bb3c70e75054d8aaa300c46d9f3fb2a269";
  })
  (fetchCosmo {
    file = "write_test.com.gz";
    sha256 = "cd55393d4feb2f8552c62f0c9046f58f6f59641da04b3ac65bbec5c44d596a99";
  })
  (fetchCosmo {
    file = "writev_test.com.dbg.gz";
    sha256 = "65660cd502045d4f661bcd4f4a6ce2ae614abca816870f1b936f0d4099a17026";
  })
  (fetchCosmo {
    file = "writev_test.com.gz";
    sha256 = "2c515a5ea52ab74f27620d09f0e2a99856aad172485bda5905e6f87d55eb2fea";
  })
  (fetchCosmo {
    file = "wut_test.com.dbg.gz";
    sha256 = "74785e7da5a5304bb13baeb1a01754c01cadc62447788e271d2c7bac5bfdaacc";
  })
  (fetchCosmo {
    file = "wut_test.com.gz";
    sha256 = "d1229f490c74fad405047f34a3fb7a9a7bb9195418dbadb1e118b485a7fda8d7";
  })
  (fetchCosmo {
    file = "x86ild_popular_binary_test.com.dbg.gz";
    sha256 = "3aed3fd84d2ac5f9c7e07085fe05969cb89e83b7aaec8010f58449a211408d27";
  })
  (fetchCosmo {
    file = "x86ild_popular_binary_test.com.gz";
    sha256 = "403f155bdc4a1d6cdf272aa797e3583db0c0e1064c4947912d96dbe88fcd03fd";
  })
  (fetchCosmo {
    file = "x86ild_popular_cmov_test.com.dbg.gz";
    sha256 = "59172e35f0f04d5fe74f555531ac424728fd955d19fdaa3142bd6b5a309c5298";
  })
  (fetchCosmo {
    file = "x86ild_popular_cmov_test.com.gz";
    sha256 = "6960c4c5f5919415987174dd6c4d707ac68f626c8ac8c9b1cd5b034d3af4e3c9";
  })
  (fetchCosmo {
    file = "x86ild_popular_i186_test.com.dbg.gz";
    sha256 = "d321ccf3fab3caca8d71055510fc2c8fe8c20abe879f4d4e153c298f37156ae4";
  })
  (fetchCosmo {
    file = "x86ild_popular_i186_test.com.gz";
    sha256 = "a55ed616cde3b0131cbb31c51bfac39fe5aac636ed4b8e0f06807e75790f8589";
  })
  (fetchCosmo {
    file = "x86ild_popular_i386_test.com.dbg.gz";
    sha256 = "470d2e34faa02b74a784b5daf8be33efc001582d7b28279bab11f732e4ef5587";
  })
  (fetchCosmo {
    file = "x86ild_popular_i386_test.com.gz";
    sha256 = "4f5f60fad01d9520dd4fea9e7f90b47466b549ffd74c27cb310b618e9dbff767";
  })
  (fetchCosmo {
    file = "x86ild_popular_i86_2_test.com.dbg.gz";
    sha256 = "da1491258fdf8b1f341cd27ff0b3b03fc9e502b63f7ee4b06c72b084440e9c71";
  })
  (fetchCosmo {
    file = "x86ild_popular_i86_2_test.com.gz";
    sha256 = "b6b7142752599028107e2bcfe09ff5d96bef48cfd6e00c36749be9c7af243984";
  })
  (fetchCosmo {
    file = "x86ild_popular_i86_test.com.dbg.gz";
    sha256 = "f9a3c7cdb4704384a4d1721cdac7f3a33ed316dde4845d9a15347af3d0d4b335";
  })
  (fetchCosmo {
    file = "x86ild_popular_i86_test.com.gz";
    sha256 = "cedb5794ab14720249952fad9e8e33fb994f906ae82112d60aa5a771a617a17b";
  })
  (fetchCosmo {
    file = "x86ild_popular_logical_test.com.dbg.gz";
    sha256 = "31b61a8d2484313011c5afe36a8ff6b54680e6d0a2787ae55c1d23954ead86f0";
  })
  (fetchCosmo {
    file = "x86ild_popular_logical_test.com.gz";
    sha256 = "0669bf20adac429d308918ff0cb1511a6ff4b6a7b68e570f084504f0214b3228";
  })
  (fetchCosmo {
    file = "x86ild_popular_misc_test.com.dbg.gz";
    sha256 = "3560d9eddc281105a446e2314eb47701275b53d2567cb71b3908e7f027967830";
  })
  (fetchCosmo {
    file = "x86ild_popular_misc_test.com.gz";
    sha256 = "2c22c4288d85ed52bb36331eb662b01cd6ca3fbdda1b23544a92fd310af22290";
  })
  (fetchCosmo {
    file = "x86ild_test.com.dbg.gz";
    sha256 = "7cf9c5fbbd3a0794a7ccd236e2e5c611c25c3af9401ea5d284482cacdeeb09aa";
  })
  (fetchCosmo {
    file = "x86ild_test.com.gz";
    sha256 = "a1d1c63884fd17d5568c59c6d4665889196f73e09b796b22eb4440382a3c3f62";
  })
  (fetchCosmo {
    file = "x86ild_widenop_test.com.dbg.gz";
    sha256 = "21139b14268e5176dccfc2b665e3774448510080f226af0495972c0717525319";
  })
  (fetchCosmo {
    file = "x86ild_widenop_test.com.gz";
    sha256 = "fe52c7bbfebbff769803a3bb29da4f72fe9b3f46c8e7600c20870cbbacc0c372";
  })
  (fetchCosmo {
    file = "xasprintf_test.com.dbg.gz";
    sha256 = "d923f4af4447cbad70fe467cb802cbc471ad55f4b4ccdefd8aede8539ad3a525";
  })
  (fetchCosmo {
    file = "xasprintf_test.com.gz";
    sha256 = "219e3e17929f4588ee7b5f57b8df2e06d4bb2052d184af244e820c0bde8a8cfe";
  })
  (fetchCosmo {
    file = "xfixpath_test.com.dbg.gz";
    sha256 = "1dc6eeb24596455a96b9ae6b223c4772713fa40533e42fd94157f3e5154a5219";
  })
  (fetchCosmo {
    file = "xfixpath_test.com.gz";
    sha256 = "5b112114c873294e5b6a8d1f86cedcd4296a5965f8a1aadc84e22c39a809fa72";
  })
  (fetchCosmo {
    file = "xjoinpaths_test.com.dbg.gz";
    sha256 = "b0fef3f6717e7bcd5373f9ae357fc87a96b24c83ef003d5e76ba87029ca3fc40";
  })
  (fetchCosmo {
    file = "xjoinpaths_test.com.gz";
    sha256 = "7846eed399d0b8d04f999c80b4a72c7e3392de700d657bb984e3468b19488037";
  })
  (fetchCosmo {
    file = "xlaterrno_test.com.dbg.gz";
    sha256 = "4bb5edfd06081fa1a55cf65ff1e9da054629ac3e1e95596b150bcae96a8e8a92";
  })
  (fetchCosmo {
    file = "xlaterrno_test.com.gz";
    sha256 = "c1e6a6366ed4fd5517154bfac96f8251694151dbbe2cbd4f8978255b407ada17";
  })
  (fetchCosmo {
    file = "xslurp_test.com.dbg.gz";
    sha256 = "26558eeb04fbef59eb443f01b712da27d318c08040f09cbe641a620e886e8641";
  })
  (fetchCosmo {
    file = "xslurp_test.com.gz";
    sha256 = "b3795004d6ca354e31046fbea86e5429e38b47cb037af2d96fdd1257622259ab";
  })
  (fetchCosmo {
    file = "xstrcat_test.com.dbg.gz";
    sha256 = "dbf09670f259bebd3587433f47ae886b77800e3ccb9264624a7224412e8f15c0";
  })
  (fetchCosmo {
    file = "xstrcat_test.com.gz";
    sha256 = "6c2cbef7b693cc80c4d110081c844bb39afcbd89163b2e2a59f6b4dab3184126";
  })
  (fetchCosmo {
    file = "ycbcr2rgb2_test.com.dbg.gz";
    sha256 = "5f04d38fb47cec33c4608b108f0d7aa4fc09e202d8b82b9d0026d79e16a51cd6";
  })
  (fetchCosmo {
    file = "ycbcr2rgb2_test.com.gz";
    sha256 = "435a51434a0b48cb8a7e65ba6178efad77412f149bb77ec2d03acb63a09d660d";
  })
  (fetchCosmo {
    file = "zleb64_test.com.dbg.gz";
    sha256 = "8ba8873c4b190f3dd113a336b6a89b567d60263e1a3a48a85aa22154693a39fc";
  })
  (fetchCosmo {
    file = "zleb64_test.com.gz";
    sha256 = "aa8159a3dea1b1c9bf8fe552d81f2444367e9be0f5695f8759d7845813a42d5b";
  })
]
