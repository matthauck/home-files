

function which($cmd) { Get-Command $cmd | Select path }

function AddToPath($newPath) {
  foreach ($path in $env:PATH.split(";")) {
    if ($path -eq $newPath) {
      return
    }
  }

  # add to user environment permanently
  echo "Adding $newPath to path"
  $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
  if ($userPath -ne "" -and $userPath -ne $null) {
    $userPath += ";"
  }
  $userPath += $newPath
  [Environment]::SetEnvironmentVariable("PATH", $userPath, "User")

  # add to current process too
  $processPath = [Environment]::GetEnvironmentVariable("PATH", "Process")
  $processPath += ";" + $newPath
  [Environment]::SetEnvironmentVariable("PATH", $processPath, "Process")
}

function SetEnv($key, $value) {
  [Environment]::SetEnvironmentVariable($key, $value, "User")
}
function SetEnvOnce($key, $value) {
  $current = [Environment]::GetEnvironmentVariable($key, "Process")
  if ($current -eq $null) {
    SetEnv $key $value
  }
}

# load in conf.ps1
if ((Test-Path "$HOME\conf.ps1")) {
  . "$HOME\conf.ps1"
}
