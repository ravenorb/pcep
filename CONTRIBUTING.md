# Contributing to PCEP

Thanks for your interest in contributing to the Personal Cloud & Edge Platform (PCEP).

This project is opinionated around self-hosting, reproducibility, and security.
The goal is to keep the code and docs clear enough that an experienced admin
can rebuild the entire stack from scratch.

## Ways to contribute

- Improve documentation (architecture, install steps, troubleshooting).
- Add or refine Docker Compose services.
- Extend or fix GitHub Actions workflows.
- Improve pfSense, DNS, VPN, or backup guidance.
- File bug reports with clear reproduction steps.
- Propose new features via issues and pull requests.

## Workflow

1. **Fork** the repository on GitHub.
2. **Create a branch** for your work:

   ```bash
   git checkout -b feature/short-description
   ```

3. Make your changes:
   - Keep commits focused and logical.
   - Update or add documentation when you change behavior.
4. Run local checks:
   - Validate YAML and Docker Compose.
   - Run any linters or scripts described in `docs/`.
5. **Push** your branch and open a **Pull Request**:
   - Describe what changed and why.
   - Reference any related issue numbers.
   - Include configuration notes for complex changes.

## Coding and config style

- Prefer clarity over cleverness.
- Keep configuration composable and environment-driven.
- Avoid hard-coding secrets. Always use env vars or external secret stores.
- For docs, use concise headings and short paragraphs.

## Issue reporting

When filing an issue, include:

- Environment (home, VPS provider, OS versions).
- Exact command or configuration that fails.
- Relevant logs or error messages (sanitized).
- What you expected and what actually happened.

## License

By contributing, you agree that your contributions will be licensed under
the MIT License found in `LICENSE`.
