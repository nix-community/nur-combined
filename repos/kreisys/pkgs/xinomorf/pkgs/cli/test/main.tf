resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo hello world"
  }
}
