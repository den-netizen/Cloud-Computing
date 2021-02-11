data "exoscale_compute_template" "cc-compute-template" {
  name = var.template
  zone = var.zone
}