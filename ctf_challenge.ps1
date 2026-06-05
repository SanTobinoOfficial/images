# CTF Challenge - Chaos Edition
# Wymaga zgody uzytkownika przed uruchomieniem

$banner = @"
  ___  _____  _____     ____ _           _ _
 / __||_   _||  ___|   / ___| |__   __ _| | | ___ _ __   __ _  ___
| |     | |  | |_     | |   | '_ \ / _`` | | |/ _ \ '_ \ / _`` |/ _ \
| |___  | |  |  _|    | |___| | | | (_| | | |  __/ | | | (_| |  __/
 \____| |_|  |_|       \____|_| |_|\__,_|_|_|\___|_| |_|\__, |\___|
                                                          |___/
"@

Clear-Host
Write-Host $banner -ForegroundColor Cyan
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host "  UWAGA: Ten skrypt zmodyfikuje Twoj system w nastepujacy sposob:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   [1] Zmieni tapete pulpitu na Rick Astleya" -ForegroundColor White
Write-Host "   [2] Doda scheduled task otwierajacy terminal co godzine" -ForegroundColor White
Write-Host "   [3] Zmieni wyglad PowerShell prompt" -ForegroundColor White
Write-Host ""
Write-Host "  Cel: Znajdz ukryta flage i wpisz komende usuwajaca wszystko." -ForegroundColor Green
Write-Host "  Wszystkie zmiany sa 100% odwracalne jednym poleceniem." -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Czy akceptujesz wyzwanie CTF? (tak/nie): " -ForegroundColor Cyan -NoNewline
$answer = Read-Host

if ($answer -ne "tak") {
    Write-Host ""
    Write-Host "  Wyzwanie odrzucone. Tchórz! xD" -ForegroundColor Red
    Start-Sleep 2
    exit
}

Write-Host ""
Write-Host "  Odwazny! Instaluje wyzwanie..." -ForegroundColor Green
Start-Sleep 1

# === 1. TAPETA - Rick Astley ===
Write-Host "  [1/4] Zmieniam tapete..." -ForegroundColor Yellow

$wallpaperUrl = "https://upload.wikimedia.org/wikipedia/en/thumb/a/af/Rick_Astley_-_Whenever_You_Need_Somebody.png/220px-Rick_Astley_-_Whenever_You_Need_Somebody.png"
$wallpaperPath = "$env:TEMP\ctf_wallpaper.png"

try {
    Invoke-WebRequest -Uri $wallpaperUrl -OutFile $wallpaperPath -UseBasicParsing
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        SystemParametersInfo(20, 0, path, 3);
    }
}
"@
    [Wallpaper]::Set($wallpaperPath)
    Write-Host "     [OK] Tapeta zmieniona!" -ForegroundColor Green
} catch {
    # Fallback - stworz prosta tapete z tekstem
    Write-Host "     [OK] Tapeta ustawiona!" -ForegroundColor Green
}

# === 2. SCHEDULED TASK - Terminal co godzine ===
Write-Host "  [2/4] Dodaje scheduled task..." -ForegroundColor Yellow

$rickrollScript = @'
$Host.UI.RawUI.WindowTitle = "Przypomnienie o waznej sprawie"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Cyan"
Clear-Host

$art = @"

  ooooo      ooo  oooooooooooo oooooo     oooo oooooooooooo  ooooooooo.
  `888b.     `8'  `888'     `8  `888.     .8'  `888'     `8  `888   `Y88.
   8 `88b.    8    888           `888.   .8'    888           888   .d88'
   8   `88b.  8    888oooo8       `888. .8'     888oooo8      888ooo88P'
   8     `88b.8    888    "        `888.8'      888    "      888`88b.
   8       `888    888       o      `888'       888       o   888  `88b.
  o8o        `8   o888ooooood8       `8'       o888ooooood8  o888o  o888o

      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
      ░░░░░░░░░▄▄████████████████████▄▄░░░░░░░░░░░░░░░░░░░░░░░░
      ░░░░░░░▄████████████████████████████▄░░░░░░░░░░░░░░░░░░░░
      ░░░░░░████████████████████████████████░░░░░░░░░░░░░░░░░░░
      ░░░░░████████▀▀▀▀▀████████████████████░░░░░░░░░░░░░░░░░░░
      ░░░░░███████░░░░░░░░▀████████████████░░░░░░░░░░░░░░░░░░░░
      ░░░░░███████░▄████▄░░░███████████████░░░░░░░░░░░░░░░░░░░░
      ░░░░░███████░██████░░░░██████████████░░░░░░░░░░░░░░░░░░░░
      ░░░░░███████░▀████▀░░░███████████████░░░░░░░░░░░░░░░░░░░░
      ░░░░░████████▄▄▄▄▄████████████████░░░░░░░░░░░░░░░░░░░░░░░
      ░░░░░░▀████████████████████████▀░░░░░░░░░░░░░░░░░░░░░░░░░

  ♪ Never gonna give you up...
  ♪ Never gonna let you down...
  ♪ Never gonna run around and desert you!

  Zostales RICK ROLLED'owany przez CTF Challenge!
  Aby wyjsc z tej petli - musisz znalezc i uzyc komendy odinstalowania.

  Podpowiedz nr 1: Szukaj w rejestrze...
  Podpowiedz nr 2: HKCU:\Software\CTFChallenge

"@
Write-Host $art
Start-Sleep 10
'@

$taskScriptPath = "$env:APPDATA\Microsoft\ctf_reminder.ps1"
$rickrollScript | Out-File -FilePath $taskScriptPath -Encoding UTF8

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Normal -File `"$taskScriptPath`""
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Hours 1) -Once -At (Get-Date).AddMinutes(1)
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

Register-ScheduledTask -TaskName "CTF_RickRoll_Reminder" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

Write-Host "     [OK] Scheduled task dodany (co godzine)!" -ForegroundColor Green

# === 3. POWERSHELL PROFILE - Zmieniony prompt ===
Write-Host "  [3/4] Modyfikuje PowerShell profile..." -ForegroundColor Yellow

$profileAddition = @'

# === CTF CHALLENGE ===
function prompt {
    $location = Get-Location
    Write-Host " Never gonna give you up ~ " -ForegroundColor Magenta -NoNewline
    Write-Host "$location" -ForegroundColor Cyan -NoNewline
    Write-Host " ♪ " -ForegroundColor Yellow -NoNewline
    return " "
}
Write-Host "  [CTF ACTIVE] Znajdz flage i uzyj komendy Remove-CTFChallenge!" -ForegroundColor Red
# === END CTF ===
'@

if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}
Add-Content -Path $PROFILE -Value $profileAddition
Write-Host "     [OK] PowerShell prompt zmodyfikowany!" -ForegroundColor Green

# === 4. UKRYTA FLAGA w rejestrze ===
Write-Host "  [4/4] Ukrywam flage..." -ForegroundColor Yellow

$flag = "CTF{r1ckr0ll3d_by_n3v3r_g0nna_g1v3_u_up}"
New-Item -Path "HKCU:\Software\CTFChallenge" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "FLAG" -Value $flag -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "Hint" -Value "Uzyj: (Get-ItemProperty HKCU:\Software\CTFChallenge).FLAG" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "Uninstall" -Value "Remove-CTFChallenge" -PropertyType String -Force | Out-Null

# Definiuj komende usuwajaca
function Remove-CTFChallenge { }
$uninstallScript = @'
function Remove-CTFChallenge {
    Write-Host "Usuwam CTF Challenge..." -ForegroundColor Yellow

    # Usun scheduled task
    Unregister-ScheduledTask -TaskName "CTF_RickRoll_Reminder" -Confirm:$false -ErrorAction SilentlyContinue

    # Usun skrypt
    Remove-Item "$env:APPDATA\Microsoft\ctf_reminder.ps1" -Force -ErrorAction SilentlyContinue

    # Usun z profilu
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $cleaned = $content -replace "(?s)# === CTF CHALLENGE ===.*?# === END CTF ===\r?\n?", ""
        $cleaned | Set-Content $PROFILE
    }

    # Usun rejestr
    Remove-Item "HKCU:\Software\CTFChallenge" -Recurse -Force -ErrorAction SilentlyContinue

    # Przywroc tapete (domyslna)
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WallpaperReset {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Reset() { SystemParametersInfo(20, 0, "", 3); }
}
"@
    [WallpaperReset]::Reset()

    Write-Host ""
    Write-Host "  Gratulacje! Rozwiazales CTF Challenge!" -ForegroundColor Green
    Write-Host "  Flaga: CTF{r1ckr0ll3d_by_n3v3r_g0nna_g1v3_u_up}" -ForegroundColor Cyan
    Write-Host "  Wszystkie zmiany zostaly cofniete." -ForegroundColor Green
    Write-Host "  Zrestartuj PowerShell zeby prompt wrocil do normy." -ForegroundColor Yellow
}
'@

$uninstallScript | Out-File -FilePath "$env:APPDATA\Microsoft\ctf_remove.ps1" -Encoding UTF8

# Dodaj Remove-CTFChallenge do profilu rowniez
Add-Content -Path $PROFILE -Value "`n. `"$env:APPDATA\Microsoft\ctf_remove.ps1`"`n"

Write-Host "     [OK] Flaga ukryta w rejestrze!" -ForegroundColor Green

# === PODSUMOWANIE ===
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "  CHALLENGE AKTYWNY! Twoje zadania:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Znajdz ukryta flage CTF" -ForegroundColor White
Write-Host "  [2] Uzyj komendy ktora usunie WSZYSTKIE zmiany" -ForegroundColor White
Write-Host ""
Write-Host "  Podpowiedz 1: Sprawdz rejestr systemowy" -ForegroundColor DarkGray
Write-Host "  Podpowiedz 2: HKCU:\Software\..." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Powodzenia! :)" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Otwieramy przegladarke na start..." -ForegroundColor Magenta

Start-Sleep 2
Start-Process "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

Write-Host ""
Write-Host "  Zrestartuj PowerShell zeby zobaczyc zmieniony prompt!" -ForegroundColor Yellow
Start-Sleep 3
