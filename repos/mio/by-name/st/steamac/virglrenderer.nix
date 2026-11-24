{
  lib,
  stdenv,
  virglrendererSrc,
  venusProtocol,
  libepoxy,
  meson,
  ninja,
  pkg-config,
  python3,
}:

# The host virglrenderer (Venus over MoltenVK/KosmicKrisp) that libkrun links
# against. The Vulkan driver is opened at runtime (vulkan-dload), so MoltenVK
# is not a build input.
stdenv.mkDerivation (finalAttrs: {
  pname = "virglrenderer-steamac";
  version = "1.1.3-unstable-2026-10-03";

  src = virglrendererSrc;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    (python3.withPackages (ps: [
      ps.pyyaml
      ps.mako
    ]))
  ];

  buildInputs = [ libepoxy ];

  # Both host libraries (libepoxy, virglrenderer, libkrun) target macOS 15.
  env.MACOSX_DEPLOYMENT_TARGET = "15.0";

  mesonFlags = [
    "-Dvenus=true"
    "-Dvulkan-dload=true"
    "-Drender-server-mode=thread"
    "-Drender-server-worker=thread"
    "-Dneptune=false"
    "-Dvtest=false"
    "-Dtests=false"
    "-Dvideo=false"
    "-Dcheck-gl-errors=false"
  ];

  # meson must not download the venus-protocol wrap subproject.
  postPatch = ''
    mkdir -p subprojects/venus-protocol-1.1.3
    tar -xzf ${venusProtocol} -C subprojects/venus-protocol-1.1.3 --strip-components=1
  '';

  postInstall = ''
    install_name_tool -id @rpath/libvirglrenderer.1.dylib "$out/lib/libvirglrenderer.1.dylib"

    if otool -L "$out/lib/libvirglrenderer.1.dylib" | grep -qiE 'molten|vulkan'; then
      echo "libvirglrenderer links a Vulkan library (the driver is opened at runtime)" >&2
      exit 1
    fi
    # The app bundle signs every bundled dylib; a standalone signature is not
    # needed (and codesign/Xcode is not available in the default sandbox).
  '';

  dontFixup = true;

  meta = {
    description = "Virglrenderer with Venus support for the Steamac host stack";
    homepage = "https://github.com/utmapp/virglrenderer";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
})
