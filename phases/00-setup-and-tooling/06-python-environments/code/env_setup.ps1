$ErrorActionPreference = "Stop"

$PythonMinMajor = 3
$PythonMinMinor = 11
$VenvDir = ".venv"
$CorePackages = @("numpy", "matplotlib", "jupyter", "scikit-learn", "pandas")

function Write-Pass([string]$Message) {
    Write-Host "  [PASS] $Message" -ForegroundColor Green
}

function Write-Fail([string]$Message) {
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Warn([string]$Message) {
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Get-RepoRoot {
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    return (Resolve-Path (Join-Path $scriptDir "..\..\..\..")).Path
}

function Get-PythonCommand {
    $candidates = @("python", "py")

    foreach ($candidate in $candidates) {
        try {
            if ($candidate -eq "py") {
                $version = & py -3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
                if (-not $version) {
                    continue
                }
                $parts = $version.Trim().Split(".")
                if ([int]$parts[0] -ge $PythonMinMajor -and [int]$parts[1] -ge $PythonMinMinor) {
                    return @{
                        Command = "py"
                        Args = @("-3")
                        Label = "py -3"
                    }
                }
            } else {
                $version = & $candidate -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
                if (-not $version) {
                    continue
                }
                $parts = $version.Trim().Split(".")
                if ([int]$parts[0] -ge $PythonMinMajor -and [int]$parts[1] -ge $PythonMinMinor) {
                    return @{
                        Command = $candidate
                        Args = @()
                        Label = $candidate
                    }
                }
            }
        } catch {
        }
    }

    return $null
}

function Invoke-Python {
    param(
        [hashtable]$PythonInfo,
        [string[]]$ExtraArgs
    )

    & $PythonInfo.Command @($PythonInfo.Args + $ExtraArgs)
}

function Verify-Package {
    param(
        [string]$PythonPath,
        [string]$PackageName,
        [string]$ImportName = $PackageName
    )

    try {
        $output = & $PythonPath -c "import $ImportName; print(getattr($ImportName, '__version__', 'ok'))" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ${PackageName}: $output"
            return $true
        }
    } catch {
    }

    Write-Fail $PackageName
    return $false
}

$RepoRoot = Get-RepoRoot
Set-Location $RepoRoot

Write-Host ""
Write-Host "=== AI Engineering from Scratch: Python Environment Setup ==="
Write-Host ""
Write-Host "Repo root: $RepoRoot"
Write-Host ""

$HasUv = $false
try {
    $uvVersion = & uv --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $HasUv = $true
        Write-Pass "uv found: $uvVersion"
    }
} catch {
}

if (-not $HasUv) {
    Write-Warn "uv not found. Install it from https://astral.sh/uv/"
    Write-Warn "Falling back to python -m venv + pip"
}

$PythonInfo = Get-PythonCommand
if (-not $PythonInfo) {
    Write-Fail "Python $PythonMinMajor.$PythonMinMinor+ not found"
    Write-Host ""
    Write-Host "Install Python $PythonMinMajor.$PythonMinMinor+ with one of:"
    Write-Host "  uv python install 3.12"
    Write-Host "  winget install Python.Python.3.12"
    exit 1
}

$PythonVersion = Invoke-Python -PythonInfo $PythonInfo -ExtraArgs @("-c", "import sys; print(sys.version)")
Write-Pass "Python: $PythonVersion"

Write-Host ""
Write-Host "--- Creating virtual environment ---"
Write-Host ""

if (Test-Path $VenvDir) {
    Write-Warn "Existing $VenvDir found. Reusing it."
} else {
    if ($HasUv) {
        & uv venv $VenvDir
    } else {
        Invoke-Python -PythonInfo $PythonInfo -ExtraArgs @("-m", "venv", $VenvDir)
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Failed to create $VenvDir"
        exit 1
    }

    Write-Pass "Created $VenvDir"
}

$VenvPython = Join-Path $RepoRoot "$VenvDir\Scripts\python.exe"
if (-not (Test-Path $VenvPython)) {
    Write-Fail "Could not find venv Python at $VenvPython"
    exit 1
}

Write-Pass "Python path: $VenvPython"

Write-Host ""
Write-Host "--- Installing core packages ---"
Write-Host ""

if ($HasUv) {
    & uv pip install --python $VenvPython @CorePackages
} else {
    & $VenvPython -m ensurepip --upgrade
    & $VenvPython -m pip install --upgrade pip
    & $VenvPython -m pip install @CorePackages
}

if ($LASTEXITCODE -ne 0) {
    Write-Fail "Package installation failed"
    exit 1
}

Write-Pass ("Installed: " + ($CorePackages -join ", "))

Write-Host ""
Write-Host "--- Verifying installation ---"
Write-Host ""

$Failures = 0

if (-not (Verify-Package -PythonPath $VenvPython -PackageName "numpy" -ImportName "numpy")) { $Failures++ }
if (-not (Verify-Package -PythonPath $VenvPython -PackageName "matplotlib" -ImportName "matplotlib")) { $Failures++ }
if (-not (Verify-Package -PythonPath $VenvPython -PackageName "scikit-learn" -ImportName "sklearn")) { $Failures++ }
if (-not (Verify-Package -PythonPath $VenvPython -PackageName "pandas" -ImportName "pandas")) { $Failures++ }
if (-not (Verify-Package -PythonPath $VenvPython -PackageName "jupyter" -ImportName "jupyter_core")) { $Failures++ }

Write-Host ""
& $VenvPython -c "import numpy as np; a = np.random.randn(3, 3); b = np.random.randn(3, 3); c = a @ b; print(f'  Matrix multiply check: ({a.shape}) @ ({b.shape}) = ({c.shape})')"
if ($LASTEXITCODE -ne 0) {
    Write-Fail "NumPy operations check failed"
    $Failures++
} else {
    Write-Pass "NumPy operations working"
}

Write-Host ""
try {
    & $VenvPython -c "import torch" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $torchVersion = & $VenvPython -c "import torch; print(torch.__version__)"
        $cudaAvail = & $VenvPython -c "import torch; print(torch.cuda.is_available())"
        Write-Pass "PyTorch $torchVersion (CUDA: $cudaAvail)"
    } else {
        Write-Warn "PyTorch not installed (install later when needed):"
        Write-Host "    uv pip install --python $VenvPython torch torchvision torchaudio"
    }
} catch {
    Write-Warn "PyTorch not installed (install later when needed):"
    Write-Host "    uv pip install --python $VenvPython torch torchvision torchaudio"
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host ""
Write-Host "  Repo root:    $RepoRoot"
Write-Host "  Venv:         $(Join-Path $RepoRoot $VenvDir)"
Write-Host "  Python:       $(& $VenvPython --version)"
Write-Host "  Packages:     $($CorePackages -join ', ')"
Write-Host ""

if ($Failures -gt 0) {
    Write-Fail "$Failures package(s) failed verification"
    exit 1
} else {
    Write-Pass "All checks passed"
    Write-Host ""
    Write-Host "Activate this environment in future sessions:"
    Write-Host ""
    Write-Host "  .\$VenvDir\Scripts\Activate.ps1"
    Write-Host ""
}
