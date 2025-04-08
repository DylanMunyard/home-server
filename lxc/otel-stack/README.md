# Monitoring Stack
After deploying go to port 8086 and configure InfluxDB:
- Add an organisation called `Bansion`
- Add a bucket called `proxmox`

Go to Proxmox admin UI > Datacentre > Metric Server and configure the Influx DB.

![Metrics Server Config](proxmox-metrics-server)

Go to the Grafana UI port 3000. Add a new InfluxDB datasource
- URL = http://influxdb:8086
- Add a Custom HTTP Header: `Authorization`: `Token <paste_token>`
- Enter `proxmox` for the database name

Then import the Proxmox Grafana dashboard https://grafana.com/grafana/dashboards/10048-proxmox/

Drop the YAMLs under `/opt/stacks/otel` (assuming `otel` as the stack name)
