project('cyCodeBase', 'c')

install_headers(files('cyAlphaDistribution.h'), subdir: 'cyCodeBase')
install_headers(files('cyBVH.h'), subdir: 'cyCodeBase')
install_headers(files('cyColor.h'), subdir: 'cyCodeBase')
install_headers(files('cyCore.h'), subdir: 'cyCodeBase')
install_headers(files('cyGL.h'), subdir: 'cyCodeBase')
install_headers(files('cyHairFile.h'), subdir: 'cyCodeBase')
install_headers(files('cyHeap.h'), subdir: 'cyCodeBase')
install_headers(files('cyIVector.h'), subdir: 'cyCodeBase')
install_headers(files('cyLightingGrid.h'), subdir: 'cyCodeBase')
install_headers(files('cyMatrix.h'), subdir: 'cyCodeBase')
install_headers(files('cyPointCloud.h'), subdir: 'cyCodeBase')
install_headers(files('cyPolynomial.h'), subdir: 'cyCodeBase')
install_headers(files('cyQuat.h'), subdir: 'cyCodeBase')
install_headers(files('cySampleElim.h'), subdir: 'cyCodeBase')
install_headers(files('cyTimer.h'), subdir: 'cyCodeBase')
install_headers(files('cyTriMesh.h'), subdir: 'cyCodeBase')
install_headers(files('cyVector.h'), subdir: 'cyCodeBase')

pkgc = import('pkgconfig')
pkgc.generate(
  name: 'cyCodeBase',
  subdirs: 'cyCodeBase',
  description: 'cyCodeBase',
)

eigen_dep = declare_dependency(
  include_directories : include_directories('.'),
)
