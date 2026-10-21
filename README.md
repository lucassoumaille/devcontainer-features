# Dev Container Features

Reusable Dev Container Features for a consistent, secure, AI-assisted development environment.

This repository contains shared development tooling designed to be reused across language-specific Dev Container templates.

## Available Features

### `ai-tools`

**Status:** Initial version — Claude Code

The `ai-tools` Feature provides a common entry point for AI coding tools across development environments.

Current capabilities:

- Installs Claude Code through the official Anthropic Dev Container Feature.
- Adds the Claude Code extension to VS Code.
- Provides a foundation for integrating additional AI development tools.

The Feature delegates Claude Code installation to Anthropic rather than maintaining a separate installation mechanism.

### Usage

Add the Feature to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/USER/devcontainer-features/ai-tools:1": {}
  }
}
```

Replace `USER` with the GitHub account or organization that publishes this repository.

The Feature must be published to GitHub Container Registry (GHCR) before this reference can be used.

## Claude Code Configuration Persistence

Claude Code configuration can be persisted between container rebuilds using a named Docker volume.

Add the following properties to your `.devcontainer/devcontainer.json`:

```json
{
  "mounts": [
    "source=claude-code-config-${devcontainerId},target=/home/vscode/.claude,type=volume"
  ],
  "containerEnv": {
    "CLAUDE_CONFIG_DIR": "/home/vscode/.claude"
  }
}
```

Merge these properties into your existing configuration rather than duplicating JSON keys.

### How it works

- The named volume stores Claude's configuration outside the container's writable filesystem.
- Rebuilding the same Dev Container can reuse the volume.
- Different Dev Containers receive separate volumes when their `devcontainerId` values differ.
- Removing the volume also removes the configuration stored in it.

On the first start, launch `claude` and complete authentication if prompted.

**Security notes**

- Never commit API keys, authentication tokens, or other credentials.
- Do not bake personal credentials into Docker images.
- Protect access to the Docker daemon and persistent configuration volumes.
- Authentication may need to be renewed when a session expires.

## Repository Structure

```text
devcontainer-features/
├── .devcontainer/
├── .github/
│   └── workflows/
├── src/
│   └── ai-tools/
│       ├── devcontainer-feature.json
│       └── install.sh
├── test/
│   └── ai-tools/
│       └── test.sh
├── LICENSE
└── README.md
```

- `src/ai-tools/` contains the Feature definition and installation script.
- `test/ai-tools/` contains the installation smoke test.
- `.github/workflows/` contains repository automation for validation and publication.

## Development and Testing

Requirements:

- Docker
- Node.js, as required by the Dev Container CLI
- [Dev Container CLI](https://github.com/devcontainers/cli)

Run the Feature tests from the repository root:

```bash
devcontainer features test \
  --project-folder . \
  --features ai-tools
```

The test verifies that Claude Code is installed and that its CLI is available.

The test does not authenticate with Anthropic or verify a live Claude session.

## Publishing

Features are distributed as OCI artifacts through GitHub Container Registry.

The intended published reference is:

```text
ghcr.io/TON_USER/devcontainer-features/ai-tools:1
```

Use the repository's GitHub Actions workflows to validate and publish the Feature. Confirm that the package exists in GHCR and that its visibility matches your intended use.

When making a breaking change, consider publishing a new major version. For compatible changes, update the Feature version and follow the repository's release workflow.

## Design Principles

- **Reusable:** shared tools should be available across language-specific templates.
- **Composable:** each Feature should have a focused responsibility.
- **Reproducible:** installation and testing should be automated.
- **Secure by default:** credentials should remain outside source control and container images.
- **Maintainable:** prefer official upstream installation mechanisms where appropriate.

## Roadmap

Potential future additions:

- OpenCode CLI integration.
- OpenAI Codex CLI integration.
- Shared developer tooling.
- Optional security tooling.
- Automated compatibility and release tests.

These items are planned possibilities, not capabilities currently provided by `ai-tools`.

## License

See [LICENSE](LICENSE).
