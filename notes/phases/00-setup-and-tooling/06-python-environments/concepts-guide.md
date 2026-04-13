# Python Environments Concept Exercises

This workbook turns the ideas from `phases/00-setup-and-tooling/06-python-environments/docs/en.md` into guided exercises.

## Exercise 1: Understand the Problem

Goal: understand dependency hell.

Read this scenario:
- Project A needs `torch 2.6`
- Project B needs an older `torch`
- both use the same global Python

Instruction:
1. Write one sentence explaining what breaks if both projects share one global package install.
2. Write one sentence explaining why isolation fixes it.

You should understand:
- the lesson exists to prevent project dependencies from colliding

## Exercise 2: Inspect a Virtual Environment

Goal: identify what a virtual environment is.

Run:

```powershell
cd C:\dev\ai-engineering-from-scratch
.\.venv\Scripts\Activate.ps1
python -c "import sys; print(sys.executable)"
```

Instruction:
1. Confirm the Python path points into `.venv`.
2. Write down what `.venv` contains in plain language.

You should understand:
- a virtual environment is a project-local Python installation with its own packages

## Exercise 3: Compare Global vs Project Install

Goal: understand why global installs are risky.

Read these two commands:

Bad:

```powershell
pip install torch
```

Good:

```powershell
.\.venv\Scripts\Activate.ps1
python -m pip install torch
```

Instruction:
1. Explain why the first command is dangerous for project work.
2. Explain why the second command is safer.

You should understand:
- global installs affect your machine
- project installs affect only the active environment

## Exercise 4: Prove Isolation

Goal: prove that one environment does not change another.

Follow the steps in:
`notes/phases/00-setup-and-tooling/06-python-environments/exercise-instructions.md`

Instruction:
1. Create `.venv-test`.
2. Install a different NumPy version there.
3. Compare it with the main repo `.venv`.

You should understand:
- each environment has its own interpreter and packages

## Exercise 5: Read a pyproject.toml

Goal: understand what `pyproject.toml` is for.

Study this example:

```toml
[project]
name = "my-ai-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["numpy", "pandas"]

[project.optional-dependencies]
torch = ["torch", "torchvision"]
llm = ["openai", "anthropic"]
```

Instruction:
1. Identify the project name.
2. Identify the minimum Python version.
3. List the base dependencies.
4. List the optional dependency groups.

You should understand:
- `pyproject.toml` describes what the project needs

## Lesson Exercise 3: Write a `pyproject.toml` for PyTorch and Anthropic

Goal: complete exercise 3 from the lesson with a runnable example.

Create a throwaway folder such as `scratch-exercise-3/` and add this file:

```toml
[project]
name = "scratch-ai-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "torch>=2.3",
    "anthropic>=0.39",
]
```

Then create a virtual environment in that folder and install from the project file:

```powershell
uv venv
.\.venv\Scripts\Activate.ps1
uv pip install -e .
```

Verify both packages import correctly:

```powershell
python -c "import torch, anthropic; print(torch.__version__, anthropic.__version__)"
```

You should notice:
- `pyproject.toml` can describe both ML and API dependencies in one project
- installing from the project file keeps the environment definition in version-controlled config instead of ad hoc shell history

## Exercise 6: Understand Optional Dependencies

Goal: understand extras.

Using the example above, answer:
1. Which packages are always installed?
2. Which packages are installed only for deep learning work?
3. Which packages are installed only for LLM API work?

Then write one sentence:
- why optional groups keep environments smaller and cleaner

You should understand:
- one project can support multiple use cases without installing everything by default

## Exercise 7: Understand the Lockfile

Goal: understand reproducibility.

Instruction:
1. Write one sentence explaining the difference between:
   - `pyproject.toml`
   - a lockfile
2. Explain why two people can get different installs without a lockfile.

Use this mental model:
- `pyproject.toml` = what you want
- lockfile = the exact versions that worked

You should understand:
- lockfiles pin exact versions, including transitive dependencies

## Exercise 8: Understand Transitive Dependencies

Goal: understand indirect packages.

Read this example:
- you install `pandas`
- `pandas` depends on other packages

Instruction:
1. Explain what a transitive dependency is in one sentence.
2. Explain why transitive dependencies still matter even if you did not install them directly.

You should understand:
- your environment includes both direct and indirect dependencies

## Exercise 9: Understand Reproducibility

Goal: understand why teams care about environment consistency.

Instruction:
1. Write down three things that can make AI environments fragile.
2. Explain why reproducibility matters for debugging and collaboration.

Suggested examples:
- package versions
- CUDA versions
- framework compatibility

You should understand:
- reproducibility means future you or another machine can recreate the same working environment

## Exercise 10: Choose Between uv, venv, and conda

Goal: know when to use each tool.

Instruction:
1. Write one sentence for when to use `uv`.
2. Write one sentence for when to use `venv`.
3. Write one sentence for when to use `conda`.

Use this guidance:
- `uv`: best default for this course
- `venv`: built-in fallback
- `conda`: useful when binary dependencies or CUDA-heavy setups make installs difficult

You should understand:
- these tools solve related problems, but are not identical

## Exercise 11: Understand Why Mixing pip and conda Is Risky

Goal: understand a common environment mistake.

Instruction:
1. Explain why mixing `pip` and `conda` in one environment can cause trouble.
2. Write the rule you want to follow in future projects.

Suggested rule:
- if you choose conda for an environment, let conda manage it as much as possible

You should understand:
- dependency tracking breaks down when multiple package managers modify the same environment carelessly

## Lesson Exercise 4: Deliberately Install a Package Globally, Then Remove It

Goal: complete exercise 4 from the lesson and see exactly what "global install" means.

Open a fresh shell with no virtual environment active. Install a small package globally:

```powershell
python -m pip install colorama
```

Check which Python you are using and where the package was installed:

```powershell
python -c "import sys; print(sys.executable)"
python -m pip show colorama
```

What to look for:
- `sys.executable` should point to your system Python, not `.venv\Scripts\python.exe`
- `pip show` prints the package location, which proves where the install landed

After you confirm it, remove the package:

```powershell
python -m pip uninstall colorama
```

You should notice:
- a global install changes the default Python on your machine, not just one project
- using `python -m pip` makes it easier to see which interpreter owns the install

## Exercise 12: Understand CUDA Mismatch

Goal: connect Python environments to GPU issues.

Read this scenario:
- the GPU exists
- `nvidia-smi` works
- but `torch.cuda.is_available()` is `False`

Instruction:
1. Explain one likely cause.
2. Explain how this differs from “the computer has no GPU.”

You already saw a version of this:
- first you had CPU-only PyTorch
- later you installed a CUDA-enabled build

You should understand:
- package compatibility matters for GPU access too

## Final Check

After these exercises, you should be able to explain:
- what problem a virtual environment solves
- why global installs are risky
- what `pyproject.toml` does
- what a lockfile does
- what reproducibility means
- when to use `uv`, `venv`, or `conda`
- why CUDA mismatches happen
