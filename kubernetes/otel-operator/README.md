# OpenTelemetry Collector

This directory contains the OpenTelemetry Collector deployment for the home lab cluster.

## Components

- **Agent (DaemonSet)**: Collects telemetry data from each node
- **Collector (Deployment)**: Processes and exports telemetry data
- **Configuration**: OTEL collector and agent configurations

## Configuration Files

- `config/otel-agent-config.yaml` - OpenTelemetry agent configuration
- `config/otel-collector-config.yaml` - OpenTelemetry collector configuration
- `agent-daemonset.yaml` - Agent DaemonSet deployment
- `collector-deployment.yaml` - Collector deployment
- `collector-service.yaml` - Service for collector
- `kustomization.yaml` - Kustomize configuration with configMapGenerator
- `namespace.yaml` - Namespace definition

## Configuration

The default configuration:

- Agent collects OTLP traces/metrics from nodes
- Agent forwards to collector service
- Collector exports to external endpoint (needs configuration)

**Important**: Update the collector export endpoint in `config/otel-collector-config.yaml` to point to your actual observability backend.

## Usage

Deploy with:

```bash
kubectl apply -k .
```

Or via ArgoCD by adding an application pointing to this directory.
