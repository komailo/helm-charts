# Repository Guidelines

## Project Structure & Module Organization
All Helm charts live in `charts/`; each directory contains a `Chart.yaml`, `values.yaml`, templates, and optional child charts under `charts/<name>/charts`. Shared helper logic belongs in `charts/common-library`. Automation scripts (chart index rebuild, release pruning) live in `.scripts/`, while workflow logic and chart-testing configs are under `.github/`. Root files such as `disk-bench.yaml` or `secret-test.yaml` are standalone manifests used for local experiments; keep them in sync with the chart values they document.

## Build, Test, and Development Commands
Use Helm 3.16+ and keep dependencies fresh: `helm dependency update charts/<chart>`. Quick validation goes through `helm lint charts/<chart>` and `helm template charts/<chart> --values examples/override.yaml` when provided. Reproduce CI by running `ah lint` from the `charts/` folder, `ct lint --config .github/configs/ct-lint.yaml`, and (when touching installable charts) `ct install --config .github/configs/ct-install.yaml` against a local Kind cluster. Release-specific maintenance uses `.scripts/index-recreate.sh` (chart-releaser + gh CLIs required) and `.scripts/release-cleanup.sh` (needs authenticated GitHub CLI).

## Coding Style & Naming Conventions
YAML stays two-space indented with lowercase `kebab-case` resource names mirroring directory names (`external-secrets`, `local-path-provisioner`). Keep helper templates in `_helpers.tpl` and namespace them, e.g., `{{- define "librechat.labels" -}}`. Default `.Values` lookups defensively (`| default "ClusterIP"`) and document any new keys inside the chart’s README or comments in `values.yaml`. Avoid committing generated `charts/*/charts` folders; CI rebuilds them.

## Testing Guidelines
Add smoke tests under `templates/tests/` when charts support `helm test`. When editing a chart, rerun `ct list-changed --config .github/configs/ct-lint.yaml` to confirm the test matrix and execute the corresponding `ct lint`/`ct install` steps locally. Capture helm output or screenshots for anything affecting rendered manifests or dashboards, and summarize that evidence in the PR description.

## Commit & Pull Request Guidelines
Commits follow a Conventional Commit flavor (`type(scope): subject`) or `<chart>: change`. Every chart change must bump the `version` in `Chart.yaml`, adjust `appVersion` when upstream software changes, and update README usage tables. PRs should list testing commands run, link related issues, and include before/after outputs when modifying services or CRDs. If you ran `.scripts/index-recreate.sh` or `release-cleanup.sh`, describe the trigger and confirm the required tokens were set.

## Release & Maintenance Tips
Publishing relies on chart-releaser: never track `.cr-release-packages/`, and ensure `CR_TOKEN`/`GH_TOKEN` have repo + pages scope before rebuilding `index.yaml`. When trimming history, prefer `.scripts/release-cleanup.sh` so GitHub releases and git tags stay in lockstep.
