# On-device checks for the maintainer's PC (Windows PowerShell), phone connected over adb.
# Never shipped. Does NOT touch the phone's screen.
#
#   .\tools\device_test.ps1 -Device 192.168.1.199:PORT [-InstallTestBuild]
#
# 1. Builds a TEST variant (tests/smali classes + update check pointed at
#    tests/fixtures/fake_release.json, tag 2.9.999) and runs the app_process tests:
#    SortTest (library series order) and UpdaterTest (tag -> versionCode).
# 2. With -InstallTestBuild, installs that test build over the app: the next time the
#    library opens, the "Version 2.9.999 is available" prompt must appear (first check
#    after install). Reinstall the normal build afterwards.
param(
  [Parameter(Mandatory = $true)][string]$Device,
  [string]$Work = 'E:\Claude_Workbench\_cra',
  [string]$Adb = 'E:\Claude_Workbench\tools\platform-tools\adb.exe',
  [string]$Apktool = 'E:\Claude_Workbench\tools\apktool\apktool_2.9.3.jar',
  [switch]$InstallTestBuild
)
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$t = Join-Path $repo 'tools'
$fake = 'https://raw.githubusercontent.com/PalpatineRex/ComicRackAndroid/main/tests/fixtures/fake_release.json'
Set-Location $env:TEMP

python -I "$t\patch_lvl.py" "$Work\base\ComicRack.1.80.apk" "$Work\out\t1.apk"
python -I "$t\patch_fork.py" "$Work\out\t1.apk" "$Work\out\t2.apk"
python -I "$t\patch_manifest.py" "$Work\out\t2.apk" "$Work\out\t3.apk" --ce-version 0.9.186
python -I "$t\patch_smali.py" "$Work\out\t3.apk" "$Work\out\t4.apk" --apktool $Apktool `
  --extra-smali (Join-Path $repo 'tests\smali') --update-url $fake
python -I "$t\sign_v1.py" sign "$Work\out\t4.apk" "$Work\out\cra_test.apk" "$Work\keys\test.key.pem" "$Work\keys\test.cert.pem"

& $Adb -s $Device push "$Work\out\cra_test.apk" /data/local/tmp/cra_test.apk | Out-Null
'--- SortTest (every number must be negative)'
& $Adb -s $Device shell "CLASSPATH=/data/local/tmp/cra_test.apk app_process /system/bin cra.test.SortTest"
'--- UpdaterTest (expected 918600, 918700, 918701, 10000000, 0)'
& $Adb -s $Device shell "CLASSPATH=/data/local/tmp/cra_test.apk app_process /system/bin cra.test.UpdaterTest"
& $Adb -s $Device shell rm -f /data/local/tmp/cra_test.apk

if ($InstallTestBuild) {
  '--- installing TEST build (fake update 2.9.999)'
  & $Adb -s $Device install -r "$Work\out\cra_test.apk"
}
'DONE'
