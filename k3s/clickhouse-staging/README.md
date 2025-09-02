# ClickHouse Staging
Staging environment for ClickHouse https://clickhouse.com/docs/install/docker used by https://github.com/DylanMunyard/bf1942-servers to store stuff about people playing BF42 / FH2.

## Key Differences from Production
- Namespace: `clickhouse-staging` instead of `clickhouse`
- Hostname: `clickhouse-staging.home.net` instead of `clickhouse.home.net`
- Reduced resource limits: 16Gi memory limit (vs 32Gi), 2Gi memory request (vs 4Gi), 250m CPU request (vs 500m)
- Separate PVC and ConfigMap with staging-specific names

## Usage
This staging environment allows for testing ClickHouse configurations and updates before deploying to production.
