from distutils.command.build_ext import build_ext
from multiprocessing.pool import ThreadPool

def parallel_build_extensions(self):
    cores = int(os.environ.get("NIX_BUILD_CORES", "16"))
    print("Building extensions in parallel using {} cores".format(cores))
    pool = ThreadPool(cores)
    pool.map(self.build_extension, self.extensions)
    pool.close()
    pool.join()

build_ext.build_extensions = parallel_build_extensions
