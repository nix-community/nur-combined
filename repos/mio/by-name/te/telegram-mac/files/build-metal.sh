# Xcode's Metal stub cannot locate the separately installed toolchain inside
# the Nix build HOME. Compile shaders explicitly with find-metal.sh's tools.
mkdir -p build/metal

compile_metal_library() {
  local name="$1"
  shift
  local shader
  local objects=()
  for shader in "$@"; do
    local object="build/metal/$(basename "$shader").air"
    "$METAL" -c -target air64-apple-macos10.13 -I "$(dirname "$shader")" "$shader" -o "$object"
    objects+=("$object")
  done
  "$METALLIB" "${objects[@]}" -o "build/metal/$name.metallib"
}

compile_metal_library Telegram Resources/shaders/MetalFunctions.metal
compile_metal_library MetalEngine_MetalEngine \
  submodules/telegram-ios/submodules/MetalEngine/Sources/MetalEngineShaders.metal
compile_metal_library DustLayer_DustLayer \
  packages/DustLayer/Sources/DustEffectShaders.metal \
  packages/DustLayer/Sources/loki.metal \
  packages/DustLayer/Sources/loki_header.metal
compile_metal_library CallVideoLayer_CallVideoLayer \
  packages/CallVideoLayer/Sources/CallScreenShaders.metal

# Keep resources for Bundle.module but prevent Xcode invoking its Metal stub.
find . -name '*.metal' -exec mv {} {}.txt \;
find . -name Package.swift -exec sed -i 's/\.metal"/.metal.txt"/g' {} +
sed -i '/MetalFunctions.metal in Sources/d' Telegram.xcodeproj/project.pbxproj

install_metal_libraries() {
  local products="$1"
  local name bundle
  cp build/metal/Telegram.metallib "$products/Telegram.app/Contents/Resources/default.metallib"
  for name in MetalEngine_MetalEngine DustLayer_DustLayer CallVideoLayer_CallVideoLayer; do
    bundle="$products/Telegram.app/Contents/Resources/$name.bundle"
    test -d "$bundle"
    mkdir -p "$bundle/Contents/Resources"
    cp "build/metal/$name.metallib" "$bundle/Contents/Resources/default.metallib"
  done
}
