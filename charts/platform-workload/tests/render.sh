#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
helm lint "$root"
helm template minimal "$root" -f "$root/tests/fixtures/minimal.yaml" >/tmp/platform-workload-minimal.yaml
helm template full "$root" -f "$root/tests/fixtures/full.yaml" >/tmp/platform-workload-full.yaml
helm template profiles "$root" -f "$root/tests/fixtures/profiles.yaml" >/tmp/platform-workload-profiles.yaml
grep -q "replicas: 2" /tmp/platform-workload-profiles.yaml
grep -q "name: OVERRIDE_ENV" /tmp/platform-workload-profiles.yaml
grep -q "value: \"from-workload\"" /tmp/platform-workload-profiles.yaml
grep -q "name: PROFILE_ENV" /tmp/platform-workload-profiles.yaml
grep -q "name: WORKLOAD_ENV" /tmp/platform-workload-profiles.yaml
grep -q 'kind: Deployment' /tmp/platform-workload-minimal.yaml
grep -q 'checksum/config:' /tmp/platform-workload-full.yaml
grep -q 'kind: PodMonitor' /tmp/platform-workload-full.yaml
if helm template invalid "$root" -f <(printf 'workloads: {one: {image: {repository: example/one}}}\n') >/dev/null 2>&1; then exit 1; fi
helm template digest "$root" -f <(printf 'workloads: {one: {image: {repository: example/one, digest: sha256:%064d}}}\n' 0) | grep -q 'example/one@sha256:'
if helm template invalid-route "$root" -f <(printf 'workloads: {one: {image: {repository: example/one, tag: v1}}}\nservices: {bad: {workload: missing, port: 80}}\n') >/dev/null 2>&1; then exit 1; fi
if helm template invalid-digest "$root" -f <(printf 'workloads: {one: {image: {repository: example/one, digest: sha256:not-valid}}}\n') >/dev/null 2>&1; then exit 1; fi
