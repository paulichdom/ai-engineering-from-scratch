# Python Environments Exercise

This exercise is based on Phase 00, Lesson 06:
`phases/00-setup-and-tooling/06-python-environments/docs/en.md`

## Goal

Prove that virtual environments are isolated by creating a second environment with a different NumPy version, then comparing it with the repo's main `.venv`.

## Step 1: Activate the repo environment

```powershell
cd C:\dev\ai-engineering-from-scratch
.\.venv\Scripts\Activate.ps1
python -c "import sys; print(sys.executable)"
python -c "import numpy; print(numpy.__version__)"
```

Expected result:
- Python path should point into `.venv`
- NumPy version should print successfully

## Step 2: Create a second virtual environment

```powershell
python -m venv .venv-test
.\.venv-test\Scripts\Activate.ps1
python -c "import sys; print(sys.executable)"
```

Expected result:
- Python path should now point into `.venv-test`

## Step 3: Install a different NumPy version

```powershell
python -m ensurepip --upgrade
python -m pip install numpy==1.26.4
python -c "import numpy; print(numpy.__version__)"
```

Expected result:
- `.venv-test` should report `1.26.4`

## Step 4: Switch back to the main repo environment

```powershell
deactivate
.\.venv\Scripts\Activate.ps1
python -c "import numpy; print(numpy.__version__)"
```

Expected result:
- The NumPy version in `.venv` should remain whatever was previously installed there
- It should not be affected by `.venv-test`

## What This Proves

Each virtual environment has:
- its own Python executable
- its own installed packages
- its own dependency versions

Installing a package in one environment does not change the packages in another.

## Cleanup

If you do not want to keep the second environment:

```powershell
deactivate
Remove-Item -Recurse -Force .venv-test
```
