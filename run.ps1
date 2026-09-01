Set-Location $PSScriptRoot
if (Get-Command ruby -ErrorAction SilentlyContinue) {
    ruby main.rb
} else {
    & "C:\Ruby40-x64\bin\ruby.exe" main.rb
}
