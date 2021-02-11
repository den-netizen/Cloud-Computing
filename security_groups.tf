resource "exoscale_security_group" "cc-security-group" {
  name = "firewall"
}

resource "exoscale_security_group_rule" "ssh-sg-rule" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}

resource "exoscale_security_group_rule" "load-generator-sg-rule2" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}

resource "exoscale_security_group_rule" "http-generator-sg-rule2" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "prometheus-sg-rule" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9090
  end_port = 9090
}

resource "exoscale_security_group_rule" "sd-config-sg-rule" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9100
  end_port = 9100
}

resource "exoscale_security_group_rule" "grafana-sg-rule" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 3000
  end_port = 3000
}

resource "exoscale_security_group_rule" "autoscaler-sg-rule" {
  security_group_id = exoscale_security_group.cc-security-group.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8090
  end_port = 8090
}