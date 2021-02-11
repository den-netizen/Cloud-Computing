resource "exoscale_nlb" "cc-nlb" {
  name = "cc-nlb"
  zone = var.zone
}

resource "exoscale_nlb_service" "cc-nlb-service" {
  name = "cc-nlb-service"
  zone = exoscale_nlb.cc-nlb.zone
  nlb_id = exoscale_nlb.cc-nlb.id
  instance_pool_id = exoscale_instance_pool.cc-instance-pool.id
  protocol = "tcp"
  port = 80
  target_port = 8080
  strategy = "round-robin"
  healthcheck {
    port = 8080
    mode = "http"
    uri = "/health"
    interval = 20
    timeout = 10
    retries = 1
  }
}