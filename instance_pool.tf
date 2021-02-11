resource "exoscale_instance_pool" "cc-instance-pool" {
  name = "cc-instance-pool"
  service_offering = "micro"
  size = 3
  disk_size = 10
  template_id = data.exoscale_compute_template.cc-compute-template.id
  zone = var.zone
  security_group_ids = [exoscale_security_group.cc-security-group.id]
  user_data = <<EOF
#!/bin/bash
sudo apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker run -d -p 8080:8080 quay.io/janoszen/http-load-generator
sudo docker run -d -p 9100:9100 quay.io/prometheus/node-exporter
EOF
}
