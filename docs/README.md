# Documentação do Platform Helm

O chart público atual é [platform-workload](../charts/platform-workload/README.md).
Ele cria recursos a partir de valores e não contém identidade de nenhuma
aplicação consumidora.

## Consumir o chart

| Passo | Referência |
| --- | --- |
| Entender o contrato e a compatibilidade | [README do chart](../charts/platform-workload/README.md) |
| Consultar todos os campos aceites | [Schema de values](../charts/platform-workload/values.schema.json) |
| Ver valores de referência | [values.yaml](../charts/platform-workload/values.yaml) |
| Validar uma alteração do chart | [Testes de renderização](../charts/platform-workload/tests/render.sh) |

O projeto consumidor declara `platform-workload` como dependência em
`deploy/Chart.yaml` e coloca a configuração sob a chave
`platform-workload:` em `values.yaml` e `values-prod.yaml`.

## Publicação e consumo

O repositório Helm é publicado em
`https://lolmeida.github.io/platform-helm`. Fixe uma versão SemVer compatível:
uma alteração incompatível é major; um campo opcional novo é minor; uma correção
é patch.

## Limites de responsabilidade

- O chart não cria `Namespace`.
- Valores de runtime não sensíveis podem criar ConfigMaps.
- Segredos entram por referências explícitas a ExternalSecret/existing Secret;
  nunca por valores ou templates de aplicação.
- Argo CD e registo do cluster pertencem ao repositório GitOps central.
