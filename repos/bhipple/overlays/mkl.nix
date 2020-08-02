self: super: {
  # blas = super.blas.override { blasProvider = self.mkl; };
  # lapack = super.lapack.override { lapackProvider = self.mkl; };
}
