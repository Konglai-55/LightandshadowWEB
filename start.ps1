$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $Root

$IndexFile = Join-Path $Root "index.html"
if (-not (Test-Path -LiteralPath $IndexFile)) {
    Write-Host "index.html was not found in: $Root"
    exit 1
}

function Test-PortAvailable {
    param([int]$Port)

    $listener = $null
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
        $listener.Start()
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($null -ne $listener) {
            $listener.Stop()
        }
    }
}

function Get-FreePort {
    param([int]$StartPort = 5173)

    for ($port = $StartPort; $port -lt ($StartPort + 100); $port++) {
        if (Test-PortAvailable -Port $port) {
            return $port
        }
    }

    throw "No available port found from $StartPort to $($StartPort + 99)."
}

function Get-PythonCommand {
    $candidates = @(
        @{ File = "py"; Args = @("-3") },
        @{ File = "python"; Args = @() },
        @{ File = "python3"; Args = @() }
    )

    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate.File -ErrorAction SilentlyContinue
        if ($null -eq $command) {
            continue
        }

        try {
            $versionArgs = @($candidate.Args + @("--version"))
            $versionOutput = & $command.Source @versionArgs 2>&1
            if ($LASTEXITCODE -eq 0 -and ($versionOutput -match "Python")) {
                return @{ File = $command.Source; Args = $candidate.Args }
            }
        }
        catch {
            continue
        }
    }

    return $null
}

$Port = if ($env:PORT) { [int]$env:PORT } else { Get-FreePort -StartPort 5173 }
$Url = "http://127.0.0.1:$Port/"
$Python = Get-PythonCommand

if ($null -eq $Python) {
    Write-Host "Python was not found. Opening index.html directly."
    Start-Process -FilePath $IndexFile
    exit 0
}

$ServerArgs = @($Python.Args + @("-m", "http.server", $Port.ToString(), "--bind", "127.0.0.1"))

Write-Host "Starting local server: $Url"
Write-Host "Serving directory: $Root"
Write-Host "Press Ctrl+C to stop."
Start-Process -FilePath $Url

& $Python.File @ServerArgs
