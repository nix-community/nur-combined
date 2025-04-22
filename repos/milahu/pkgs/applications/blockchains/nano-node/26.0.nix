/*
FIXME undefined reference to `boost::log::v2_mt_posix::sinks::text_file_backend::~text_file_backend()'

i have tried ...

change boost version

add to CMakeLists.txt ...

  add_definitions(-DBOOST_ALL_DYN_LINK)

  find_library(libboost_log_so boost_log lib/libboost_log.so)
  target_link_libraries(Boost::log INTERFACE ${libboost_log_so})

  # https://github.com/boostorg/log/issues/46
  add_definitions(-DBOOST_LOG_DYN_LINK)

  # https://github.com/boostorg/log/issues/18
  list(APPEND Boost_LIBRARIES boost_log_setup)

  SET(Boost_USE_STATIC_LIBS ON)

... but nothing helps

probably this requires Boost_USE_STATIC_LIBS
but nixpkgs has only dynamic boost libs
*/

{ lib
, nano-node
, fetchFromGitHub
, diskhash
}:

nano-node.overrideAttrs (attrs: {

  # revert: Logging overhaul
  # pwojcikdev merged commit b225de0 into nanocurrency:develop on Jan 24 -> after V26.0 Jan 15
  # https://github.com/nanocurrency/nano-node/pull/4375
  # error: logging should be initialized before creating a logger
  # https://github.com/nanocurrency/nano-node/pull/4679
  # V26.0 Jan 15 20:05:06 2024
  # V26.1 Feb 26 11:32:57 2024
  version = "26.0";

  # use shared libraries, dont fetch gitmodules
  # https://github.com/nanocurrency/nano-node/pull/4679
  # backported to V26.0
  # branch shared-libs-V26.0
  src = fetchFromGitHub {
    owner = "milahu";
    repo = "nano-node";
    rev = "73745d4039d8c2efb981d01d6001e98383294eb0";
    hash = "";
  };

  buildInputs = attrs.buildInputs ++ [
    diskhash
  ];

})
