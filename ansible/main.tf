resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/inventory.tmpl",
    {
      drone_ip = var.drone_address
    }
  )
  filename = "${path.module}/inventory"
}
