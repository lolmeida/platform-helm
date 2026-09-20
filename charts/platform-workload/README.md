# platform-workload

Reusable Helm chart for values-driven Kubernetes workloads. Templates iterate over `workloads`, `services`, `routes`, `monitoring`, `externalSecrets` and `bootstrapJobs`; component names are values keys.

## Image contract

`image.repository` is required. Use `tag`, `digest`, or both. Rendering produces `repository:tag`, `repository@digest`, or `repository:tag@digest`.

## Consumer values

Each workload declares its image, optional container port, environment, existing `secretRefs`, probes and optional config mounts. Services declare `workload`, `port` and optional `targetPort`. Routes reference service keys. `runtimeConfig` is non-sensitive ConfigMap data and is never a secret store. External secrets are opt-in and require an explicit `secretStoreRef`, target name and remote keys.

The chart does not create a Namespace. Service-account token mounting is disabled by default; enabling it is an explicit workload value. PodMonitor and bootstrap Job resources are opt-in.

## Compatibility and publication

Values contract changes that require consumer changes are a SemVer major version. Additive optional values are minor releases; fixes are patch releases. The repository publishes the chart through GitHub Pages on pushes to `main`; consume it with `https://lolmeida.github.io/platform-helm` and a pinned SemVer constraint. OCI publication is optional and requires a token with package-write scope.

Run `tests/render.sh` before publishing.
