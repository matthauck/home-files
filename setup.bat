@echo off
SET home_files_dir=%~dp0
powershell -ExecutionPolicy Unrestricted %home_files_dir%setup.ps1
