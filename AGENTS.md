# Repository Guidelines

## Project Structure & Module Organization
This repository is curriculum-first. Core content lives in `phases/XX-phase-name/NN-lesson-name/`, typically with `code/`, `docs/en.md`, `outputs/`, and often `quiz.json`. Example: `phases/03-deep-learning-core/05-loss-functions/`. Shared artifacts live in top-level `outputs/` (`prompts/`, `skills/`, `agents/`, `mcp-servers/`) and are indexed by `outputs/index.json`. The static website is in `site/`; `site/build.js` generates `site/data.js` from `README.md`, `ROADMAP.md`, and `glossary/terms.md`.

## Build, Test, and Development Commands
Install Python dependencies with `python -m pip install -r requirements.txt`. Rebuild site data with `node site/build.js`; run this after changing `README.md`, `ROADMAP.md`, or glossary content. Validate lesson code by running the affected script directly, for example `python phases/03-deep-learning-core/05-loss-functions/code/main.py` or `python phases/00-setup-and-tooling/01-dev-environment/code/verify.py`. For a quick site preview, serve `site/` locally with `python -m http.server 8000 --directory site`.

## Coding Style & Naming Conventions
Match the existing style of the area you touch. Lesson folders use zero-padded numeric prefixes plus kebab-case names: `07-transformers-deep-dive/03-attention-from-scratch`. Python uses 4-space indentation and straightforward, runnable examples. When editing `site/`, preserve the current plain JavaScript style (`var`, semicolons, small functions). Follow `CONTRIBUTING.md`: code should be self-explanatory, practical, and generally free of explanatory comments. Keep docs direct and structured.

## Testing Guidelines
There is no single repo-wide test runner today. Treat validation as change-specific: run modified lesson code, verify any `verify.py` helpers, and rebuild the site when metadata changes. If you add a lesson, include the required `docs/en.md` structure and ensure linked outputs or quizzes load correctly. Prefer smoke-test evidence in the PR over unverified content edits.

## Commit & Pull Request Guidelines
Recent history uses concise conventional prefixes such as `feat:` and `fix:`. Keep commit subjects imperative and scoped, for example `feat: add quiz to phase 3 lesson 5`. PRs should describe what changed, list the paths affected, and note how you validated the change. Include screenshots only for `site/` UI changes. Use a focused branch name such as `feat/add-lesson-phase3-loss-functions`.
