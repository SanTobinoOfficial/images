# Poker Doradca

Prosta, statyczna aplikacja webowa (HTML/CSS/JS, bez zależności), która krok po kroku doradza najlepszy ruch w **klasycznym pokerze dobieranym (5-Card Draw)** — bez dealera i bez kart wspólnych, gdzie za wejście do gry płaci się ante.

## Jak działa rozdanie

1. **Ustawienia** — ustawiasz swój stos żetonami, klikasz „Nowe rozdanie” (ante: 5 żetonów wpłacane automatycznie do puli).
2. **Rozdanie kart** — wybierasz 5 kart, które dostałeś, z pełnej talii.
3. **1. runda zakładów** — podajesz kwotę do dopłaty (0 jeśli można sprawdzić za darmo); aplikacja sugeruje Spasuj / Sprawdź / Dopłać / Podbij / All-in na podstawie siły ręki (uwzględniając potencjał do poprawy) i kursów puli.
4. **Wymiana kart** — aplikacja sugeruje, które karty wymienić (np. przy parze: zatrzymaj parę, wymień 3; przy 4 kartach w kolorze: wymień 1 itd.) — możesz zaakceptować sugestię albo zmienić zaznaczenie.
5. **Dobieranie kart** — wybierasz nowe karty w miejsce wymienionych.
6. **2. runda zakładów** — finalna runda z tą samą logiką doradczą, na podstawie już ukończonej ręki.
7. **Pokazanie kart** — zaznaczasz, czy wygrałeś (pula trafia do stosu), czy przegrałeś, i przechodzisz do kolejnego rozdania.

Cała historia decyzji i przepływu żetonów w rozdaniu jest widoczna w panelu „Historia rozdania”.

## Funkcje

- Ocena układu zgodna z klasyczną hierarchią rąk pokerowych (wysoka karta → poker królewski).
- Strategia wymiany kart oparta na standardowych zasadach 5-Card Draw (zatrzymuj gotowe układy, dobieraj do par/dwóch par/trójek, ściągaj na 4-kartowy kolor lub strita).
- Panel żetonów o nominałach **1, 5, 10, 25, 100, 500, 1000** do budowania stosu i kwot w rundach zakładów, z rozbiciem sugerowanych stawek na żetony.
- Automatyczne śledzenie stosu i puli przez całe rozdanie (ante, dopłaty, podbicia, wygrana/przegrana).

## Uruchomienie

To statyczna strona — wystarczy otworzyć `index.html` w przeglądarce, albo wystawić katalog na dowolnym hostingu stron statycznych (np. GitHub Pages, Vercel, Netlify).

```bash
python3 -m http.server 8000
# otwórz http://localhost:8000
```

## Zastrzeżenie

To narzędzie edukacyjne oparte o uproszczoną heurystykę (ocena układu, standardowa strategia wymiany kart, kursy puli). Nie zna kart przeciwników, nie jest solverem pokerowym i nie gwarantuje wygranej.
