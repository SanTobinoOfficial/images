# Poker Doradca

Prosta, statyczna aplikacja webowa (HTML/CSS/JS, bez zależności), która sugeruje najlepszy ruch w pokerze (Texas Hold'em) na podstawie wybranych kart i sytuacji przy stole.

## Funkcje

- Wybór etapu gry: przed flopem, flop, turn, rzeka.
- Wybór dwóch własnych kart oraz kart wspólnych z pełnej talii.
- Ocena układu zgodna z klasyczną hierarchią rąk pokerowych (wysoka karta → poker królewski).
- Panel żetonów o nominałach **1, 5, 10, 25, 100, 500, 1000** do budowania puli, kwoty do dopłaty i własnego stosu.
- Sugestia ruchu (Spasuj / Sprawdź / Dopłać / Podbij / All-in) na podstawie siły ręki i kursów puli (pot odds), wraz z proponowaną wysokością zakładu rozbitą na żetony.

## Uruchomienie

To statyczna strona — wystarczy otworzyć `index.html` w przeglądarce, albo wystawić katalog na dowolnym hostingu stron statycznych (np. GitHub Pages, Vercel, Netlify).

```bash
python3 -m http.server 8000
# otwórz http://localhost:8000
```

## Zastrzeżenie

To narzędzie edukacyjne oparte o uproszczoną heurystykę (formuła Chena przed flopem, ocena układu i kursy puli po flopie). Nie jest solverem pokerowym i nie gwarantuje wygranej.
