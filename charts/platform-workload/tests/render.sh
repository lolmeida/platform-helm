#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
helm lint "$root"
helm template minimal "$root" -f "$root/tests/fixtures/minimal.yaml" >/tmp/platform-workload-minimal.yaml
helm template full "$root" -f "$root/tests/fixtures/full.yaml" >/tmp/platform-workload-full.yaml
grep -q 'kind: Deployment' /tmp/platform-workload-minimal.yaml
grep -q 'checksum/config:' /tmp/platform-workload-full.yaml
grep -q 'kind: PodMonitor' /tmp/platform-workload-full.yaml
if helm template invalid "$root" -f <(printf 'workloads: {one: {image: {repository: example/one}}}\n') >/dev/null 2>&1; then exit 1; fi
