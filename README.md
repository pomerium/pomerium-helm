> [!WARNING]
> **This repository is archived and the chart is no longer maintained.** The last release, `pomerium-34.0.1` (May 2023), pins Pomerium v0.22. It does not receive updates or security fixes.
>
> To run Pomerium on Kubernetes, use one of these instead:
>
> - The [Pomerium Ingress Controller](https://github.com/pomerium/ingress-controller), following the [Kubernetes deployment docs](https://www.pomerium.com/docs/deploy/k8s) and the [quickstart](https://www.pomerium.com/docs/deploy/k8s/quickstart).
> - The Kustomize manifests in [pomerium/install](https://github.com/pomerium/install).
>
> The chart repository at `https://helm.pomerium.io` stays online for existing installations.

# Helm charts maintained by [Pomerium](https://pomerium.io)

# Using

You'll first need to add the `pomerium` repository with the command below:

```bash
helm repo add pomerium https://helm.pomerium.io
```

You can now install charts like so:

```bash
helm install pomerium/pomerium
```

# Contributing

- Create a GitHub Pull Request for your change, following the instructions in the pull request template.
- Perform a Code Review with the project maintainers on the pull request.

## Contributor License Agreement

As with many other projects, Pomerium requires a signed CLA before merging your first pull request.

## Versioning

Please version your changes according to SemVer.

## Branches

Please rebase/squash your commit history before marking a PR ready for review.
