# Cloud-Computing
with Terraform, Exoscale, Prometheus, Grafana

# Cloud Computing

## Sources:

https://community.exoscale.com/documentation/

https://www.terraform.io/docs/index.html

https://www.exoscale.com/syslog/network-load-balancer-cli-tutorial/

https://gist.github.com/janoszen/7ced227c54d1c9e86a9c1cbd93a451f2

https://www.exoscale.com/syslog/autoscaling-with-grafana-and-prometheus/

https://github.com/exoscale/terraform-provider-exoscale/blob/v0.20.0/examples/instance-pool/main.tf

https://github.com/exoscale/terraform-provider-exoscale/blob/v0.20.0/examples/nlb/main.tf

https://github.com/prometheus/node_exporter

https://quay.io/repository/prometheus/node-exporter?tag=latest&tab=tags

https://github.com/janoszen/prometheus-sd-exoscale-instance-pools

https://prometheus.io/docs/prometheus/latest/installation/

https://prometheus.io/docs/prometheus/latest/getting_started/

https://fh-cloud-computing.github.io/exercises/3-containers/

http://docs.docker.oeynet.com/machine/drivers/exoscale/#environment-variables-and-default-values

https://github.com/janoszen/exoscale-grafana-autoscaler

http://httpd.apache.org/docs/2.0/programs/ab.html

https://quay.io/repository/janoszen/http-load-generator?tag=latest&tab=tags

https://fh-cloud-computing.github.io/exercises/5-grafana/

https://grafana.com/docs/grafana/latest/administration/provisioning/

https://grafana.com/tutorials/provision-dashboards-and-data-sources/#2


This repository contains a project work and its 3 stages or sprints which are built on each other:
Sprint 1 Creating instance pool and Network Load Balancer (NLB)
Sprint 2 Monitoring with Prometheus
Sprint 3 Grafana and Autoscaling

## Overview

![Image of Overview](/assets/CCOverview.png)

Image Source:
https://www.exoscale.com/syslog/autoscaling-with-grafana-and-prometheus/

Similar:
https://fh-cloud-computing.github.io/projectwork/


Register and log into Exoscale, go to IAM and create an API Key. The key and secret needs to be copy-pasted in variables.tf and its placeholders `${var.exoscale_key}` and `${var.exoscale_secret}`.

Before starting, let's check if Terraform is healthy with:

`$ terraform plan`

Once we’re happy with the plan, we can set it into action:

`$ terraform apply`

Look up the instance-pool ID in the Exoscale Console under Compute > Instance Pools and copy-paste it in the placeholder `${exoscale_instance_pool.cc-instance-pool.id}`.

Update with:

`$ terraform apply`

**Network Load Balancer**

Copy the NLB-IP from Exoscale Console under Compute > Load Balancers and paste it in a browser window to check the following:

`http://<NLB-IP>/health` displays `OK`

`http://<NLB-IP>/load` displays `Load generation done.`

**Prometheus**

Copy the Monitoring-instance-IP from Exoscale Console under Compute > Instances and paste it in another browser window or tab to do and check the following:

`http://<monitoring-instance-IP>:9090` displays Prometheus UI. Under Status > Targets are the instances of the instance pool
and the monitoring-instance itself displayed. Under Graph the metrics can be filtered and visualised in a graph such as:

Inserting queries like `sum by (instance) (rate(node_cpu_seconds_total{mode!="idle"}[1m])) / sum by (instance) (rate(node_cpu_seconds_total[1m]))` for each instance or `(sum (rate(node_cpu_seconds_total{mode!=\"idle\", job=\"exoscale\"}[1m])) / sum (rate(node_cpu_seconds_total{job=\"exoscale\"}[1m])))` for all instances in the instance-pool in the metrics filter, the graph does not really change. To see the CPU usage increase and decrease, apply load by:

`http://<NLB-IP>/load`

**Grafana and Autoscaling**

`http://<monitoring-instance-IP>:3000` displays Grafana UI. For first login, username `admin` with password `admin` can be used. Go to Configuration (gear wheel icon) > Data sources, select Prometheus and insert the monitoring-instance-IP for its placeholder 'localhost'. Same for the notification channels (webhooks) `Scale up` and `Scale down` under Alerting (bell icon) > Notification channels. Now, everything is ready for testing. Go to Dashboards (4 tiles icon) and open the dashboard `Annotations & Alerts` with its two panels `High CPU usage` and `Low CPU usage`.

Again, you can apply load by:

`http://<NLB-IP>/load`

Or run a bash script like:

`for i in {1..n}`

`do`

`curl -X GET "http://<NLB-IP>/load"`

`echo "\n"`

`done`

Or use Apache Benchmark Tool, e.g.:

`ab -c 4 -n 1000 http://<NLB_IP>/load`

Either ways, the average CPU usage of the instance-pool and the graphs increase. After alerting, new instances are created in the instance-pool one after another if the average CPU usage stays over 80%. When the load stops, the average CPU usage decrease. After alerting, an instance in the instance-pool is deleted one after another if the average CPU usage stays under 20%.

After investigating and testing, destroy with:

`$ terraform destroy`
