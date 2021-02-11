resource "exoscale_compute" "monitoring-instance" {
  display_name = "monitoring-instance"
  size = "micro"
  disk_size = 10
  template_id = data.exoscale_compute_template.cc-compute-template.id
  zone = var.zone
  security_group_ids = [exoscale_security_group.cc-security-group.id]
  user_data = <<EOF
#!/bin/bash
sudo apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo mkdir -p /srv/service-discovery/
sudo chmod a+rwx /srv/service-discovery/
sudo docker run -d -v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools quay.io/janoszen/prometheus-sd-exoscale-instance-pools:1.0.0 --exoscale-api-key ${var.exoscale_key} --exoscale-api-secret ${var.exoscale_secret} --exoscale-zone-id 4da1b188-dcd6-4ff5-b7fd-bde984055548 --instance-pool-id ${exoscale_instance_pool.cc-instance-pool.id}
sudo mkdir -p /etc/prometheus/
sudo chmod a+rwx /etc/prometheus/
cd /etc/prometheus/
sudo cat <<EOPCF >prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: [ 'localhost:9090' ]
  - job_name: 'exoscale'
    file_sd_configs:
      - files:
          - /srv/service-discovery/config.json
        refresh_interval: 10s
EOPCF
sudo docker run -d -p 9090:9090 -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v /srv/service-discovery/:/srv/service-discovery/ quay.io/prometheus/prometheus
sudo mkdir -p /etc/grafana/provisioning/resources/
sudo chmod a+rwx /etc/grafana/provisioning/resources/
cd /etc/grafana/provisioning/resources/
sudo cat <<EODSCF >datasource.yaml
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  orgId: 1
  url: http://localhost:9090/
  version: 1
  editable: true
EODSCF
sudo cat <<EONCF >notifiers.yaml
notifiers:
  - name: Scale up
    type: webhook
    uid: scale-up
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://localhost:8090/up"
  - name: Scale down
    type: webhook
    uid: scale-down
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://localhost:8090/down"
EONCF
sudo cat <<EODCF >dashboard.yaml
apiVersion: 1
providers:
- name: 'Home'
  orgId: 1
  folder: ''
  type: file
  updateIntervalSeconds: 10
  options:
    path: /etc/grafana/dashboards/config.json
EODCF
sudo mkdir -p /etc/grafana/dashboards/
sudo chmod a+rwx /etc/grafana/dashboards/
cd /etc/grafana/dashboards/
sudo cat <<EODF >config.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 2,
  "links": [],
  "panels": [
    {
      "alert": {
        "alertRuleTags": {},
        "conditions": [
          {
            "evaluator": {
              "params": [
                0.8
              ],
              "type": "gt"
            },
            "operator": {
              "type": "and"
            },
            "query": {
              "params": [
                "A",
                "1m",
                "now"
              ]
            },
            "reducer": {
              "params": [],
              "type": "avg"
            },
            "type": "query"
          }
        ],
        "executionErrorState": "alerting",
        "for": "1m",
        "frequency": "1m",
        "handler": 1,
        "name": "High CPU usage alert",
        "noDataState": "no_data",
        "notifications": [
          {
            "uid": "scale-up"
          }
        ]
      },
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "unit": "percentunit"
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.3.6",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "(sum (rate(node_cpu_seconds_total{mode!=\"idle\", job=\"exoscale\"}[1m])) / sum (rate(node_cpu_seconds_total{job=\"exoscale\"}[1m])))",
          "interval": "",
          "legendFormat": "Average CPU usage",
          "queryType": "randomWalk",
          "refId": "A"
        }
      ],
      "thresholds": [
        {
          "colorMode": "critical",
          "fill": true,
          "line": true,
          "op": "gt",
          "value": 0.8
        }
      ],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "High CPU usage",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percentunit",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "alert": {
        "alertRuleTags": {},
        "conditions": [
          {
            "evaluator": {
              "params": [
                0.2
              ],
              "type": "lt"
            },
            "operator": {
              "type": "and"
            },
            "query": {
              "params": [
                "A",
                "1m",
                "now"
              ]
            },
            "reducer": {
              "params": [],
              "type": "avg"
            },
            "type": "query"
          }
        ],
        "executionErrorState": "alerting",
        "for": "1m",
        "frequency": "1m",
        "handler": 1,
        "name": "Low CPU usage alert",
        "noDataState": "no_data",
        "notifications": [
          {
            "uid": "scale-down"
          }
        ]
      },
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "unit": "percentunit"
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 3,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.3.6",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "(sum (rate(node_cpu_seconds_total{mode!=\"idle\", job=\"exoscale\"}[1m])) / sum (rate(node_cpu_seconds_total{job=\"exoscale\"}[1m])))",
          "interval": "",
          "legendFormat": "Average CPU usage",
          "queryType": "randomWalk",
          "refId": "A"
        }
      ],
      "thresholds": [
        {
          "colorMode": "critical",
          "fill": true,
          "line": true,
          "op": "lt",
          "value": 0.2
        }
      ],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Low CPU usage",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percentunit",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "schemaVersion": 26,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-15m",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "Autoscaling",
  "uid": "vQXhaQaMz",
  "version": 2
}
EODF
sudo docker run -d -p 8090:8090 quay.io/janoszen/exoscale-grafana-autoscaler:1.0.2 --exoscale-api-key ${var.exoscale_key} --exoscale-api-secret ${var.exoscale_secret} --exoscale-zone-id 4da1b188-dcd6-4ff5-b7fd-bde984055548 --instance-pool-id ${exoscale_instance_pool.cc-instance-pool.id}
sudo docker run -d -p 3000:3000 -v /etc/grafana/provisioning/resources/notifiers.yaml:/etc/grafana/provisioning/notifiers/notifiers.yaml -v /etc/grafana/provisioning/resources/datasource.yaml:/etc/grafana/provisioning/datasources/datasource.yaml -v /etc/grafana/dashboards/config.json:/etc/grafana/dashboards/config.json -v /etc/grafana/provisioning/resources/dashboard.yaml:/etc/grafana/provisioning/dashboards/dashboard.yaml grafana/grafana
EOF
}
