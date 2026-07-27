# Function to generate pkg-config files.
function(generate_pkgconfig name description version requires
                            libs libs_private output_filename)
  set(PC_NAME "${name}")
  set(PC_DESCRIPTION "${description}")
  set(PC_VERSION "${version}")
  set(PC_REQUIRES "${requires}")
  set(PC_LIB "${libs}")
  set(PC_LIBS_PRIVATE "${libs_private}")
  set(output_filepath "${grpc_BINARY_DIR}/libs/opt/pkgconfig/${output_filename}")
  configure_file(
    "${grpc_SOURCE_DIR}/cmake/pkg-config-template.pc.in"
    "${output_filepath}"
    @ONLY)
  install(FILES "${output_filepath}"
    DESTINATION "lib/pkgconfig/")
endfunction()

# gpr .pc file
generate_pkgconfig(
  "gpr"
  "gRPC platform support library"
  "${gRPC_CORE_VERSION}"
  "absl_base absl_cord absl_core_headers absl_memory absl_optional absl_random_random absl_status absl_str_format absl_strings absl_synchronization absl_time"
  "-lgpr"
  ""
  "gpr.pc")

# grpc .pc file
generate_pkgconfig(
  "gRPC"
  "high performance general RPC framework"
  "${gRPC_CORE_VERSION}"
  "gpr openssl absl_base absl_bind_front absl_cord absl_core_headers absl_flat_hash_map absl_flat_hash_set absl_hash absl_inlined_vector absl_memory absl_optional absl_random_random absl_span absl_status absl_statusor absl_str_format absl_strings absl_synchronization absl_time absl_type_traits absl_utility absl_variant"
  "-lgrpc -lre2 -lcares -lz"
  ""
  "grpc.pc")

# grpc_unsecure .pc file
generate_pkgconfig(
  "gRPC unsecure"
  "high performance general RPC framework without SSL"
  "${gRPC_CORE_VERSION}"
  "gpr absl_base absl_bind_front absl_cord absl_core_headers absl_flat_hash_map absl_flat_hash_set absl_hash absl_inlined_vector absl_memory absl_optional absl_random_random absl_span absl_status absl_statusor absl_str_format absl_strings absl_synchronization absl_time absl_type_traits absl_utility absl_variant"
  "-lgrpc_unsecure"
  ""
  "grpc_unsecure.pc")

# grpc++ .pc file
generate_pkgconfig(
  "gRPC++"
  "C++ wrapper for gRPC"
  "${PACKAGE_VERSION}"
  "grpc absl_base absl_bind_front absl_cord absl_core_headers absl_flat_hash_map absl_flat_hash_set absl_hash absl_inlined_vector absl_memory absl_optional absl_random_random absl_span absl_status absl_statusor absl_str_format absl_strings absl_synchronization absl_time absl_type_traits absl_utility absl_variant"
  "-lgrpc++"
  ""
  "grpc++.pc")

# grpc++_unsecure .pc file
generate_pkgconfig(
  "gRPC++ unsecure"
  "C++ wrapper for gRPC without SSL"
  "${PACKAGE_VERSION}"
  "grpc_unsecure absl_base absl_bind_front absl_cord absl_core_headers absl_flat_hash_map absl_flat_hash_set absl_hash absl_inlined_vector absl_memory absl_optional absl_random_random absl_span absl_status absl_statusor absl_str_format absl_strings absl_synchronization absl_time absl_type_traits absl_utility absl_variant"
  "-lgrpc++_unsecure"
  ""
  "grpc++_unsecure.pc")
