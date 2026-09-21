# Platform Helm

Charts Helm reutilizáveis para workloads da plataforma. Os projetos consumidores
declaram a sua topologia e configuração em valores; este repositório mantém os
templates e o contrato versionado.

## Começar

Consulte o [índice de documentação](docs/README.md) e o
[README do chart platform-workload](charts/platform-workload/README.md).

```sh
helm repo add platform-workload https://lolmeida.github.io/platform-helm --force-update
helm repo update
helm show values platform-workload/platform-workload
```

Fixe uma versão SemVer compatível no `deploy/Chart.yaml` do projeto consumidor.
Mudanças incompatíveis do contrato de valores requerem uma versão major.
