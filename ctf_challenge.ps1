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
Write-Host "  Cel: Znajdz ukryta flage i uzyj: Submit-CTFFlag ""flaga""" -ForegroundColor Green
Write-Host "  Wszystkie zmiany sa 100% odwracalne." -ForegroundColor Green
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
    public static void Set(string path) { SystemParametersInfo(20, 0, path, 3); }
}
"@
    [Wallpaper]::Set($wallpaperPath)
    Write-Host "     [OK] Tapeta zmieniona!" -ForegroundColor Green
} catch {
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
   8     `88b.8    888    "        `888.8'      888    "      888``88b.
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

  Zostales RICK ROLLED przez CTF Challenge!
  Znajdz flage: Submit-CTFFlag ""CTF{...}""
  Lub poddaj sie tchorzliwie: Remove-CTFChallenge

  Podpowiedz: Szukaj w HKCU:\Software\CTFChallenge

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
Write-Host ""
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Red
Write-Host "  |  [CTF AKTYWNY]  Wyzwanie czeka!                        |" -ForegroundColor Red
Write-Host "  |  Znajdz flage   --> Submit-CTFFlag ""CTF{...}""          |" -ForegroundColor Yellow
Write-Host "  |  Poddaj sie     --> Remove-CTFChallenge                |" -ForegroundColor DarkGray
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Red
Write-Host ""
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
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "FLAG"           -Value $flag  -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "Hint"           -Value "Uzyj: (Get-ItemProperty HKCU:\Software\CTFChallenge).FLAG" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "Submit"         -Value 'Submit-CTFFlag "CTF{...}"' -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "FlagSubmitted"  -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "     [OK] Flaga ukryta w rejestrze!" -ForegroundColor Green

# === SKRYPTY: dwa zakonczenia ===
$ctfFunctions = @'
# -------------------------------------------------------
# ZAKOŃCZENIE WCZESNE: poddanie sie bez znalezienia flagi
# -------------------------------------------------------
function Remove-CTFChallenge {
    $submitted = (Get-ItemProperty "HKCU:\Software\CTFChallenge" -ErrorAction SilentlyContinue).FlagSubmitted
    if ($submitted -eq 1) {
        Write-Host "  Challenge juz rozwiazany! Nie ma czego usuwac." -ForegroundColor Green
        return
    }

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor DarkRed
    Write-Host "  ║           ZAKONCZENIE WCZESNE - PODDALES SIE        ║" -ForegroundColor DarkRed
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "        (._.) " -ForegroundColor Yellow
    Write-Host "        (>🏳️<) " -ForegroundColor Yellow
    Write-Host "        /   \  << biala flaga sramu" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Nie znalazles flagi... Usuwam wszystko ze wstydem." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Nastepnym razem moze sie uda? Moze." -ForegroundColor DarkGray
    Write-Host "  Flaga byla tutaj: HKCU:\Software\CTFChallenge -> FLAG" -ForegroundColor DarkGray
    Write-Host "  Wystarczylo: (Get-ItemProperty HKCU:\Software\CTFChallenge).FLAG" -ForegroundColor DarkGray
    Write-Host ""

    Start-Sleep 3
    Invoke-CTFCleanup
    Write-Host ""
    Write-Host "  Wszystkie zmiany cofniete. Zrestartuj PowerShell." -ForegroundColor Yellow
}

# -------------------------------------------------------
# ZAKOŃCZENIE NORMALNE: znalazles i przeslales flage
# -------------------------------------------------------
function Submit-CTFFlag {
    param([string]$Flag)

    $correct = "CTF{r1ckr0ll3d_by_n3v3r_g0nna_g1v3_u_up}"

    if ($Flag -ne $correct) {
        Write-Host ""
        Write-Host "  [-] Zla flaga! Probuj dalej..." -ForegroundColor Red
        Write-Host "  Podpowiedz: Sprawdz HKCU:\Software\CTFChallenge" -ForegroundColor DarkGray
        Write-Host ""
        return
    }

    Clear-Host
    $Host.UI.RawUI.ForegroundColor = "Green"

    $win = @"

  ██╗    ██╗██╗███╗   ██╗    ██╗
  ██║    ██║██║████╗  ██║    ██║
  ██║ █╗ ██║██║██╔██╗ ██║    ██║
  ██║███╗██║██║██║╚██╗██║    ╚═╝
  ╚███╔███╔╝██║██║ ╚████║    ██╗
   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝    ╚═╝
"@
    Write-Host $win -ForegroundColor Green

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║        CHALLENGE ROZWIAZANY - BRAWO!                ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Znalazles ukryta flage CTF!" -ForegroundColor Cyan
    Write-Host "  Flaga: $Flag" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Statystyki:" -ForegroundColor White
    $startTime = (Get-ItemProperty "HKCU:\Software\CTFChallenge" -ErrorAction SilentlyContinue).StartTime
    if ($startTime) {
        $elapsed = (Get-Date) - [datetime]$startTime
        Write-Host "  Czas rozwiazania: $([math]::Floor($elapsed.TotalMinutes)) minut $($elapsed.Seconds) sekund" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  Gratulacje od autora! Zaslugujesz na odpoczynek :)" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Usuwam wszystkie zmiany..." -ForegroundColor Green

    Set-ItemProperty "HKCU:\Software\CTFChallenge" -Name "FlagSubmitted" -Value 1 -ErrorAction SilentlyContinue
    Start-Sleep 2
    Invoke-CTFCleanup

    Write-Host ""
    Write-Host "  Gotowe! System przywrocony do normy." -ForegroundColor Green
    Write-Host "  Zrestartuj PowerShell zeby prompt wrocil do normy." -ForegroundColor Yellow
    Write-Host ""
}

# -------------------------------------------------------
# WSPOLNA FUNKCJA CZYSZCZACA (uzywana przez oba zakonczenia)
# -------------------------------------------------------
function Invoke-CTFCleanup {
    Unregister-ScheduledTask -TaskName "CTF_RickRoll_Reminder" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_reminder.ps1" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\ctf_functions.ps1" -Force -ErrorAction SilentlyContinue

    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $cleaned = $content -replace "(?s)# === CTF CHALLENGE ===.*?# === END CTF ===\r?\n?", ""
        $cleaned = $cleaned -replace "(?s)\n\. `".*?ctf_functions\.ps1`"\r?\n?", ""
        $cleaned | Set-Content $PROFILE
    }

    Remove-Item "HKCU:\Software\CTFChallenge" -Recurse -Force -ErrorAction SilentlyContinue

    try {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WallpaperReset2 {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Reset() { SystemParametersInfo(20, 0, "", 3); }
}
"@
        [WallpaperReset2]::Reset()
    } catch {}
}
'@

$ctfFunctionsPath = "$env:APPDATA\Microsoft\ctf_functions.ps1"
$ctfFunctions | Out-File -FilePath $ctfFunctionsPath -Encoding UTF8

Add-Content -Path $PROFILE -Value "`n. `"$ctfFunctionsPath`"`n"

# Zapisz czas startu challengu
New-ItemProperty -Path "HKCU:\Software\CTFChallenge" -Name "StartTime" -Value (Get-Date).ToString() -PropertyType String -Force | Out-Null

# === PODSUMOWANIE ===
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "  CHALLENGE AKTYWNY!" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Znajdz flage, a nastepnie wpisz:" -ForegroundColor White
Write-Host '  Submit-CTFFlag "CTF{...}"' -ForegroundColor Green
Write-Host ""
Write-Host "  Lub poddaj sie (bez chwaly):" -ForegroundColor DarkGray
Write-Host "  Remove-CTFChallenge" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Podpowiedz: Sprawdz rejestr -> HKCU:\Software\..." -ForegroundColor DarkGray
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep 2
Start-Process "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

Write-Host "  Zrestartuj PowerShell zeby zobaczyc zmieniony prompt!" -ForegroundColor Yellow
Start-Sleep 3
