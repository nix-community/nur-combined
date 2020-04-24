self: super: {
  postfix = super.postfix.override { withMySQL = true; };
}
