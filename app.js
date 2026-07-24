// ---------- Card model ----------
const SUITS = [
  { key: "s", symbol: "♠", color: "black" },
  { key: "h", symbol: "♥", color: "red" },
  { key: "d", symbol: "♦", color: "red" },
  { key: "c", symbol: "♣", color: "black" },
];
const RANKS = [
  { key: 14, label: "A" }, { key: 13, label: "K" }, { key: 12, label: "Q" },
  { key: 11, label: "J" }, { key: 10, label: "10" }, { key: 9, label: "9" },
  { key: 8, label: "8" }, { key: 7, label: "7" }, { key: 6, label: "6" },
  { key: 5, label: "5" }, { key: 4, label: "4" }, { key: 3, label: "3" }, { key: 2, label: "2" },
];

const HAND_NAMES = [
  "Wysoka karta", "Para", "Dwie pary", "Trójka", "Strit",
  "Kolor", "Ful", "Kareta", "Poker", "Poker królewski",
];

// ---------- State ----------
let stage = 0; // number of community cards required: 0, 3, 4, 5
let holeCards = [null, null];
let communityCards = []; // grows to `stage` length
let activeTarget = "pot";

// ---------- Build deck UI ----------
const deckEl = document.getElementById("deck");
const cardButtons = {}; // key `${rank}${suit}` -> button

RANKS.forEach((r) => {
  SUITS.forEach((s) => {
    const btn = document.createElement("button");
    btn.className = "deck-card" + (s.color === "red" ? " red" : "");
    btn.textContent = r.label + s.symbol;
    btn.dataset.rank = r.key;
    btn.dataset.suit = s.key;
    btn.addEventListener("click", () => onCardPick(r.key, s.key));
    deckEl.appendChild(btn);
    cardButtons[`${r.key}${s.key}`] = btn;
  });
});
// deck cards are laid out per-suit blocks; reorder grid by suit blocks of 13
deckEl.innerHTML = "";
SUITS.forEach((s) => {
  RANKS.forEach((r) => {
    deckEl.appendChild(cardButtons[`${r.key}${s.key}`]);
  });
});

function cardLabel(card) {
  const r = RANKS.find((x) => x.key === card.rank).label;
  const s = SUITS.find((x) => x.key === card.suit).symbol;
  return r + s;
}

function allSelectedCards() {
  return [...holeCards.filter(Boolean), ...communityCards];
}

function isCardSelected(rank, suit) {
  return allSelectedCards().some((c) => c.rank === rank && c.suit === suit);
}

function onCardPick(rank, suit) {
  if (isCardSelected(rank, suit)) return;
  if (holeCards[0] === null) {
    holeCards[0] = { rank, suit };
  } else if (holeCards[1] === null) {
    holeCards[1] = { rank, suit };
  } else if (communityCards.length < stage) {
    communityCards.push({ rank, suit });
  } else {
    return; // all slots full
  }
  renderCards();
}

function renderCards() {
  // hole slots
  const holeSlotsEl = document.getElementById("holeSlots");
  holeSlotsEl.querySelectorAll(".card-slot").forEach((el, i) => {
    const card = holeCards[i];
    if (card) {
      el.textContent = cardLabel(card);
      el.classList.remove("empty");
      el.classList.toggle("red", SUITS.find((s) => s.key === card.suit).color === "red");
      el.classList.toggle("black", SUITS.find((s) => s.key === card.suit).color === "black");
    } else {
      el.textContent = "?";
      el.classList.add("empty");
      el.classList.remove("red", "black");
    }
  });

  // community slots
  const communityEl = document.getElementById("communitySlots");
  communityEl.innerHTML = "";
  for (let i = 0; i < stage; i++) {
    const div = document.createElement("div");
    const card = communityCards[i];
    if (card) {
      div.className = "card-slot " + (SUITS.find((s) => s.key === card.suit).color);
      div.textContent = cardLabel(card);
    } else {
      div.className = "card-slot empty";
      div.textContent = "?";
    }
    communityEl.appendChild(div);
  }
  if (stage === 0) {
    const div = document.createElement("div");
    div.className = "card-slot empty";
    div.style.opacity = 0.4;
    div.textContent = "—";
    communityEl.appendChild(div);
  }

  // deck buttons state
  Object.entries(cardButtons).forEach(([key, btn]) => {
    const rank = Number(btn.dataset.rank);
    const suit = btn.dataset.suit;
    const selected = isCardSelected(rank, suit);
    btn.classList.toggle("selected", selected);
    const slotsFull = holeCards[0] !== null && holeCards[1] !== null && communityCards.length >= stage;
    btn.disabled = selected || (slotsFull && !selected);
  });

  document.getElementById("result").classList.add("hidden");
}

// stage buttons
document.getElementById("stageButtons").addEventListener("click", (e) => {
  const btn = e.target.closest(".stage-btn");
  if (!btn) return;
  stage = Number(btn.dataset.stage);
  communityCards = communityCards.slice(0, stage);
  document.querySelectorAll(".stage-btn").forEach((b) => b.classList.toggle("active", b === btn));
  renderCards();
});

document.getElementById("clearCards").addEventListener("click", () => {
  holeCards = [null, null];
  communityCards = [];
  renderCards();
});

renderCards();

// ---------- Chips ----------
const potInput = document.getElementById("potInput");
const callInput = document.getElementById("callInput");
const stackInput = document.getElementById("stackInput");
const inputs = { pot: potInput, call: callInput, stack: stackInput };

document.getElementById("chipTray").addEventListener("click", (e) => {
  const chip = e.target.closest(".chip");
  if (!chip) return;
  const value = Number(chip.dataset.value);
  const input = inputs[activeTarget];
  input.value = (Number(input.value) || 0) + value;
});

document.querySelectorAll(".target-btn").forEach((btn) => {
  btn.addEventListener("click", () => {
    activeTarget = btn.dataset.target;
    document.querySelectorAll(".target-btn").forEach((b) => b.classList.toggle("active", b === btn));
  });
});

document.querySelectorAll(".clear-btn").forEach((btn) => {
  btn.addEventListener("click", () => {
    inputs[btn.dataset.target].value = 0;
  });
});

// ---------- Chip breakdown ----------
const DENOMINATIONS = [1000, 500, 100, 25, 10, 5, 1];
function chipBreakdown(amount) {
  let remaining = Math.round(amount);
  const parts = [];
  for (const d of DENOMINATIONS) {
    const count = Math.floor(remaining / d);
    if (count > 0) {
      parts.push(`${count}×${d}`);
      remaining -= count * d;
    }
  }
  return parts.length ? parts.join(" + ") : "0";
}

// ---------- Hand evaluation (5 to 7 cards) ----------
function combinations(arr, k) {
  const results = [];
  const combo = [];
  function helper(start) {
    if (combo.length === k) {
      results.push([...combo]);
      return;
    }
    for (let i = start; i < arr.length; i++) {
      combo.push(arr[i]);
      helper(i + 1);
      combo.pop();
    }
  }
  helper(0);
  return results;
}

function evaluate5(cards) {
  const ranks = cards.map((c) => c.rank).sort((a, b) => b - a);
  const suits = cards.map((c) => c.suit);
  const isFlush = suits.every((s) => s === suits[0]);

  const uniqRanks = [...new Set(ranks)].sort((a, b) => b - a);
  let isStraight = false;
  let straightHigh = null;
  if (uniqRanks.length === 5) {
    if (uniqRanks[0] - uniqRanks[4] === 4) {
      isStraight = true;
      straightHigh = uniqRanks[0];
    } else if (uniqRanks.join(",") === "14,5,4,3,2") {
      isStraight = true;
      straightHigh = 5; // wheel: 5-high straight
    }
  }

  const counts = {};
  ranks.forEach((r) => (counts[r] = (counts[r] || 0) + 1));
  const groups = Object.entries(counts)
    .map(([rank, count]) => ({ rank: Number(rank), count }))
    .sort((a, b) => b.count - a.count || b.rank - a.rank);

  let tier, tiebreak;
  if (isFlush && isStraight) {
    tier = 8; // straight flush (royal is straightHigh === 14)
    tiebreak = [straightHigh];
  } else if (groups[0].count === 4) {
    tier = 7;
    tiebreak = [groups[0].rank, groups[1].rank];
  } else if (groups[0].count === 3 && groups[1] && groups[1].count === 2) {
    tier = 6;
    tiebreak = [groups[0].rank, groups[1].rank];
  } else if (isFlush) {
    tier = 5;
    tiebreak = ranks;
  } else if (isStraight) {
    tier = 4;
    tiebreak = [straightHigh];
  } else if (groups[0].count === 3) {
    tier = 3;
    const kickers = groups.slice(1).map((g) => g.rank).sort((a, b) => b - a);
    tiebreak = [groups[0].rank, ...kickers];
  } else if (groups[0].count === 2 && groups[1] && groups[1].count === 2) {
    tier = 2;
    const pairs = [groups[0].rank, groups[1].rank].sort((a, b) => b - a);
    const kicker = groups[2].rank;
    tiebreak = [...pairs, kicker];
  } else if (groups[0].count === 2) {
    tier = 1;
    const kickers = groups.slice(1).map((g) => g.rank).sort((a, b) => b - a);
    tiebreak = [groups[0].rank, ...kickers];
  } else {
    tier = 0;
    tiebreak = ranks;
  }
  return { tier, tiebreak };
}

function compareEval(a, b) {
  if (a.tier !== b.tier) return a.tier - b.tier;
  for (let i = 0; i < Math.max(a.tiebreak.length, b.tiebreak.length); i++) {
    const av = a.tiebreak[i] || 0;
    const bv = b.tiebreak[i] || 0;
    if (av !== bv) return av - bv;
  }
  return 0;
}

function bestHand(cards) {
  const combos = combinations(cards, 5);
  let best = null;
  for (const combo of combos) {
    const ev = evaluate5(combo);
    if (!best || compareEval(ev, best) > 0) best = ev;
  }
  return best;
}

// tier base strength (0-100) + bonus scaled from tiebreak
function postflopStrength(evalResult) {
  const bases = [5, 22, 38, 50, 60, 68, 78, 88, 95, 100];
  const isRoyal = evalResult.tier === 8 && evalResult.tiebreak[0] === 14;
  const base = isRoyal ? 100 : bases[evalResult.tier];
  let bonus = 0;
  const top = evalResult.tiebreak[0] || 0;
  switch (evalResult.tier) {
    case 0: bonus = ((top - 2) / 12) * 15; break;
    case 1: bonus = ((top - 2) / 12) * 15; break;
    case 2: bonus = ((top - 2) / 12) * 12; break;
    case 3: bonus = ((top - 2) / 12) * 10; break;
    case 4: bonus = ((top - 5) / 9) * 8; break;
    case 5: bonus = ((top - 2) / 12) * 8; break;
    case 6: bonus = ((top - 2) / 12) * 10; break;
    case 7: bonus = ((top - 2) / 12) * 8; break;
    default: bonus = isRoyal ? 0 : ((top - 5) / 9) * 5;
  }
  return Math.min(100, Math.round(base + bonus));
}

function handName(evalResult) {
  const isRoyal = evalResult.tier === 8 && evalResult.tiebreak[0] === 14;
  return isRoyal ? HAND_NAMES[9] : HAND_NAMES[evalResult.tier];
}

// ---------- Preflop strength (Chen formula) ----------
function chenValue(rank) {
  if (rank === 14) return 10;
  if (rank === 13) return 8;
  if (rank === 12) return 7;
  if (rank === 11) return 6;
  if (rank === 10) return 5;
  return rank / 2;
}

function chenScore(c1, c2) {
  const [hi, lo] = [c1, c2].sort((a, b) => b.rank - a.rank);
  if (hi.rank === lo.rank) {
    return Math.max(chenValue(hi.rank) * 2, 5);
  }
  let score = chenValue(hi.rank);
  if (hi.suit === lo.suit) score += 2;
  const gap = hi.rank - lo.rank - 1;
  let gapPenalty = 0;
  if (gap === 1) gapPenalty = 1;
  else if (gap === 2) gapPenalty = 2;
  else if (gap === 3) gapPenalty = 4;
  else if (gap >= 4) gapPenalty = 5;
  score -= gapPenalty;
  if (gap <= 1 && hi.rank < 12) score += 1; // straight potential bonus
  return Math.max(0, Math.ceil(score));
}

function preflopStrength(c1, c2) {
  const score = chenScore(c1, c2);
  return Math.min(100, Math.round((score / 20) * 100));
}

// ---------- Decision logic ----------
document.getElementById("suggestBtn").addEventListener("click", () => {
  if (!holeCards[0] || !holeCards[1]) {
    alert("Wybierz obie Twoje karty przed sugestią.");
    return;
  }
  if (communityCards.length < stage) {
    alert("Uzupełnij karty wspólne dla wybranego etapu gry (lub zmień etap).");
    return;
  }

  const pot = Math.max(0, Number(potInput.value) || 0);
  const call = Math.max(0, Number(callInput.value) || 0);
  const stack = Math.max(0, Number(stackInput.value) || 0);

  let strength, handLabel;
  const allCards = allSelectedCards();
  if (allCards.length >= 5) {
    const best = bestHand(allCards);
    strength = postflopStrength(best);
    handLabel = `Najlepszy układ: ${handName(best)}`;
  } else {
    strength = preflopStrength(holeCards[0], holeCards[1]);
    handLabel = `Ocena startowa (formuła Chena): ${chenScore(holeCards[0], holeCards[1])} pkt`;
  }

  const effectiveCall = Math.min(call, stack);
  let move, moveClass, detail, chipsText = "";

  if (effectiveCall <= 0) {
    if (strength >= 55) {
      const raise = Math.min(stack, Math.max(10, Math.round((pot || Math.max(10, stack * 0.1)) * 0.7)));
      move = "POSTAW / PODBIJ";
      moveClass = "bet";
      detail = `Siła ręki: ${strength}/100 — brak zakładu do sprawdzenia, warto zagrać agresywnie o wartość.`;
      chipsText = `Sugerowana stawka: ${raise} (${chipBreakdown(raise)})`;
    } else {
      move = "SPRAWDŹ (CHECK)";
      moveClass = "check";
      detail = `Siła ręki: ${strength}/100 — brak zakładu do sprawdzenia, tania okazja by zobaczyć kolejną kartę za darmo.`;
    }
  } else {
    const requiredEquity = (effectiveCall / (pot + effectiveCall)) * 100;
    if (strength >= requiredEquity + 20) {
      const raise = Math.min(stack, Math.max(effectiveCall * 2, Math.round((pot + effectiveCall * 2) * 0.6)));
      if (raise >= stack) {
        move = "ALL-IN";
        moveClass = "allin";
        detail = `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% — duża przewaga, warto grać cały stos.`;
        chipsText = `All-in: ${stack} (${chipBreakdown(stack)})`;
      } else {
        move = "PODBIJ (RAISE)";
        moveClass = "raise";
        detail = `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% — silna przewaga, podbij dla wartości.`;
        chipsText = `Sugerowany podbicie do: ${raise} (${chipBreakdown(raise)})`;
      }
    } else if (strength >= requiredEquity) {
      move = "SPRAWDŹ (CALL)";
      moveClass = "call";
      detail = `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% (kursy puli) — dopłata jest opłacalna.`;
      chipsText = `Dopłata: ${effectiveCall} (${chipBreakdown(effectiveCall)})`;
    } else {
      move = "SPASUJ (FOLD)";
      moveClass = "fold";
      detail = `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% (kursy puli) — dopłata nieopłacalna.`;
    }
  }

  document.getElementById("resultMove").textContent = move;
  document.getElementById("resultMove").className = "result-move " + moveClass;
  document.getElementById("resultDetail").textContent = detail;
  document.getElementById("resultHand").textContent = handLabel;
  document.getElementById("resultChips").textContent = chipsText;
  document.getElementById("result").classList.remove("hidden");
});
