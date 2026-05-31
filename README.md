# 🎮 Snake Live — TikTok Overlay

Aplikacja do TikTok LIVE: gra Snake z auto-AI + reakcje na follow/prezenty.

## Szybki start (bez serwera)

Otwórz `index.html` w przeglądarce → gotowe do streamowania.

Naciśnij `` ` `` (backtick) aby otworzyć panel testowy.

## Z serwerem (panel na telefonie)

```bash
npm install
node server.js
```

Otwórz `index.html` — stream overlay  
Otwórz `panel.html` — panel sterowania (np. na telefonie)

## Z prawdziwym TikTok Live

```bash
npm install tiktok-live-connector
TIKTOK_USERNAME=@twojnazwa node server.js
```

Serwer automatycznie odbiera follow/lajki/prezenty/komentarze z Twojego live.

## Streamowanie (OBS)

1. Uruchom `index.html` w przeglądarce (Chrome/Firefox)
2. W OBS: Dodaj źródło → **Przechwytywanie okna** lub **Przechwytywanie przeglądarki**
3. Ustaw rozdzielczość 1080×1920 (pionowo TikTok)

## Sterowanie

| Klawisz | Akcja |
|---------|-------|
| `` ` `` | Panel testowy |
| `Spacja` | Przełącz AI / ręcznie |
| `Strzałki` | Graj ręcznie |

## Reakcje na zdarzenia

| Zdarzenie | Efekt |
|-----------|-------|
| Follow | Banner + konfetti + przyspieszenie węża |
| Lajki | Serduszka lecące w górę |
| Mały prezent (Róża/Słonecznik) | Animacja emoji + +25 pkt |
| Średni prezent (Panda/Korona) | Większa animacja + x3 mnożnik |
| Duży prezent (Lew/Wszechświat) | MEGA animacja + tęczowy wąż + x5 mnożnik + trzęsienie ekranu |
| Komentarz | Bańka z tekstem |