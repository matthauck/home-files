
$ErrorActionPreference = "Stop"

# enable powershell scripts
Set-ExecutionPolicy Unrestricted -Scope CurrentUser

# get absolute path to directory of setup.sh
$HOME_FILES_DIR="$PSScriptRoot"

if (!(Test-Path $profile) -or !(cat $profile | select-string profile.ps1))  {
    mkdir (Split-Path $profile)
    echo "" >> $profile
    echo "# add home-files profile" >> $profile
    echo ". $HOME_FILES_DIR\profile\profile.ps1" >> $profile
    . $profile
}

# use plink for git-ssh
[Environment]::SetEnvironmentVariable("GIT_SSH", "c:\Program Files (x86)\PuTTY\plink.exe", "User")

function update_git_submodule($dir) {
  pushd $dir
  git submodule init
  git submodule update
  popd
}

# update home-files
update_git_submodule "$HOME_FILES_DIR"
# update dotvim
update_git_submodule "$HOME_FILES_DIR/dotvim"

if (!(Test-Path "$HOME\.gitconfig")) {
  cmd /c mklink "$HOME\.gitconfig" "$HOME_FILES_DIR\git\gitconfig"
}

if (!(Test-Path "$HOME\.vim")) {
  cmd /c mklink /D "$HOME\.vim" "$HOME_FILES_DIR\dotvim"
}
if (!(Test-Path "$HOME\_vimrc")) {
  cp "$HOME_FILES_DIR\dotvim\sample.vimrc" "$HOME\_vimrc"
}

if (!(Test-Path "c:\bin")) {
  mkdir c:\bin
}
AddToPath "c:\bin"

if (!(Test-Path "c:\bin\cmdp.bat")) {
  echo "powershell" | Out-File -Encoding ASCII "c:\bin\cmdp.bat"
}



