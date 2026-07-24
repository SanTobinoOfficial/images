// ============ Card model ============
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
const ANTE = 5;
const DENOMINATIONS = [1000, 500, 100, 25, 10, 5, 1];

function cardKey(c) { return `${c.rank}${c.suit}`; }
function cardLabel(c) {
  const r = RANKS.find((x) => x.key === c.rank).label;
  const s = SUITS.find((x) => x.key === c.suit).symbol;
  return r + s;
}
function cardColor(c) { return SUITS.find((x) => x.key === c.suit).color; }

function chipBreakdown(amount) {
  let remaining = Math.round(amount);
  const parts = [];
  for (const d of DENOMINATIONS) {
    const count = Math.floor(remaining / d);
    if (count > 0) { parts.push(`${count}×${d}`); remaining -= count * d; }
  }
  return parts.length ? parts.join(" + ") : "0";
}

function combinations(arr, k) {
  const results = [];
  const combo = [];
  (function helper(start) {
    if (combo.length === k) { results.push([...combo]); return; }
    for (let i = start; i < arr.length; i++) { combo.push(arr[i]); helper(i + 1); combo.pop(); }
  })(0);
  return results;
}

// ============ Hand classification (always exactly 5 cards, no board) ============
function classifyHand(cards) {
  const indexed = cards.map((c, i) => ({ ...c, idx: i }));
  const suits = indexed.map((c) => c.suit);
  const isFlush = suits.every((s) => s === suits[0]);
  const sortedDesc = [...indexed].sort((a, b) => b.rank - a.rank);
  const uniqRanks = [...new Set(sortedDesc.map((c) => c.rank))];

  let isStraight = false, straightHigh = null;
  if (uniqRanks.length === 5) {
    const s = [...uniqRanks].sort((a, b) => b - a);
    if (s[0] - s[4] === 4) { isStraight = true; straightHigh = s[0]; }
    else if (s.join(",") === "14,5,4,3,2") { isStraight = true; straightHigh = 5; }
  }

  const byRank = {};
  indexed.forEach((c) => { (byRank[c.rank] = byRank[c.rank] || []).push(c.idx); });
  const groups = Object.entries(byRank)
    .map(([rank, idxs]) => ({ rank: Number(rank), count: idxs.length, idxs }))
    .sort((a, b) => b.count - a.count || b.rank - a.rank);

  let tier, tiebreak, keepIdxs;
  const allIdxs = indexed.map((c) => c.idx);
  if (isFlush && isStraight) { tier = 8; tiebreak = [straightHigh]; keepIdxs = allIdxs; }
  else if (groups[0].count === 4) { tier = 7; tiebreak = [groups[0].rank, groups[1].rank]; keepIdxs = allIdxs; }
  else if (groups[0].count === 3 && groups[1] && groups[1].count === 2) { tier = 6; tiebreak = [groups[0].rank, groups[1].rank]; keepIdxs = allIdxs; }
  else if (isFlush) { tier = 5; tiebreak = sortedDesc.map((c) => c.rank); keepIdxs = allIdxs; }
  else if (isStraight) { tier = 4; tiebreak = [straightHigh]; keepIdxs = allIdxs; }
  else if (groups[0].count === 3) {
    tier = 3;
    tiebreak = [groups[0].rank, ...groups.slice(1).map((g) => g.rank).sort((a, b) => b - a)];
    keepIdxs = groups[0].idxs;
  } else if (groups[0].count === 2 && groups[1] && groups[1].count === 2) {
    tier = 2;
    const pairs = [groups[0].rank, groups[1].rank].sort((a, b) => b - a);
    tiebreak = [...pairs, groups[2].rank];
    keepIdxs = [...groups[0].idxs, ...groups[1].idxs];
  } else if (groups[0].count === 2) {
    tier = 1;
    tiebreak = [groups[0].rank, ...groups.slice(1).map((g) => g.rank).sort((a, b) => b - a)];
    keepIdxs = groups[0].idxs;
  } else { tier = 0; tiebreak = sortedDesc.map((c) => c.rank); keepIdxs = []; }

  return { tier, tiebreak, keepIdxs };
}

function handName(cls) {
  const isRoyal = cls.tier === 8 && cls.tiebreak[0] === 14;
  return isRoyal ? HAND_NAMES[9] : HAND_NAMES[cls.tier];
}

function madeHandStrength(cls) {
  const bases = [5, 22, 38, 50, 60, 68, 78, 88, 95, 100];
  const isRoyal = cls.tier === 8 && cls.tiebreak[0] === 14;
  const base = isRoyal ? 100 : bases[cls.tier];
  const top = cls.tiebreak[0] || 0;
  let bonus = 0;
  switch (cls.tier) {
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

// 4-card flush / open draw detection (excluding one index at a time)
function findFourFlush(cards) {
  for (let excl = 0; excl < 5; excl++) {
    const suits = cards.filter((_, i) => i !== excl).map((c) => c.suit);
    if (suits.every((s) => s === suits[0])) return excl;
  }
  return null;
}
function findFourStraight(cards) {
  for (let excl = 0; excl < 5; excl++) {
    const ranks = cards.filter((_, i) => i !== excl).map((c) => c.rank);
    const uniq = [...new Set(ranks)];
    if (uniq.length !== 4) continue;
    const variants = [uniq];
    if (uniq.includes(14)) variants.push(uniq.map((r) => (r === 14 ? 1 : r)));
    for (const v of variants) {
      const s = [...v].sort((a, b) => a - b);
      if (s[3] - s[0] === 3) return excl;
    }
  }
  return null;
}

function suggestDraw(cards) {
  const cls = classifyHand(cards);
  if (cls.tier >= 4) {
    return { discardIdxs: [], reason: `Masz gotowy silny układ (${handName(cls)}) — zostań przy swoich kartach, nie wymieniaj nic.` };
  }
  if (cls.tier === 3) {
    const discard = [0, 1, 2, 3, 4].filter((i) => !cls.keepIdxs.includes(i));
    return { discardIdxs: discard, reason: "Masz trójkę — zatrzymaj trzy jednakowe karty i wymień pozostałe 2, licząc na karetę lub fula." };
  }
  if (cls.tier === 2) {
    const discard = [0, 1, 2, 3, 4].filter((i) => !cls.keepIdxs.includes(i));
    return { discardIdxs: discard, reason: "Masz dwie pary — zatrzymaj obie pary i wymień 1 kartę (kicker), licząc na fula." };
  }
  if (cls.tier === 1) {
    const discard = [0, 1, 2, 3, 4].filter((i) => !cls.keepIdxs.includes(i));
    return { discardIdxs: discard, reason: "Masz parę — zatrzymaj parę i wymień pozostałe 3 karty." };
  }
  // tier 0: look for a 4-card draw
  const flushExcl = findFourFlush(cards);
  if (flushExcl !== null) {
    return { discardIdxs: [flushExcl], reason: "Masz 4 karty w jednym kolorze — zatrzymaj je i wymień 1 kartę, licząc na kolor." };
  }
  const straightExcl = findFourStraight(cards);
  if (straightExcl !== null) {
    return { discardIdxs: [straightExcl], reason: "Masz 4 karty do strita — zatrzymaj je i wymień 1 kartę, licząc na strita." };
  }
  return { discardIdxs: [0, 1, 2, 3, 4], reason: "Słaba ręka bez pary i bez szans na kolor/strita — rozważ spasowanie. Jeśli grasz dalej, wymień wszystkie 5 kart." };
}

function preDrawStrength(cards) {
  const cls = classifyHand(cards);
  let s = madeHandStrength(cls);
  if (cls.tier === 0) {
    if (findFourFlush(cards) !== null) s = Math.max(s, 40);
    else if (findFourStraight(cards) !== null) s = Math.max(s, 35);
  }
  return Math.min(100, s);
}

// ============ Betting suggestion ============
function computeSuggestion(strength, facing, pot, stack) {
  const effectiveCall = Math.min(Math.max(0, facing), stack);
  if (effectiveCall <= 0) {
    if (strength >= 55) {
      const bet = Math.min(stack, Math.max(5, Math.round((pot || Math.max(10, stack * 0.1)) * 0.7)));
      return { move: "bet", label: "POSTAW / PODBIJ", amount: bet, detail: `Siła ręki: ${strength}/100 — brak zakładu do sprawdzenia, warto zagrać agresywnie o wartość.` };
    }
    return { move: "check", label: "SPRAWDŹ (CHECK)", amount: 0, detail: `Siła ręki: ${strength}/100 — możesz sprawdzić za darmo, nie ma kosztu kontynuacji.` };
  }
  const requiredEquity = (effectiveCall / (pot + effectiveCall)) * 100;
  if (strength >= requiredEquity + 20) {
    const raise = Math.min(stack, Math.max(effectiveCall * 2, Math.round((pot + effectiveCall * 2) * 0.6)));
    if (raise >= stack) {
      return { move: "allin", label: "ALL-IN", amount: stack, detail: `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% — duża przewaga, warto grać cały stos.` };
    }
    return { move: "raise", label: "PODBIJ (RAISE)", amount: raise, detail: `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% — silna przewaga, podbij dla wartości.` };
  }
  if (strength >= requiredEquity) {
    return { move: "call", label: "SPRAWDŹ / DOPŁAĆ", amount: effectiveCall, detail: `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% (kursy puli) — dopłata jest opłacalna.` };
  }
  return { move: "fold", label: "SPASUJ (FOLD)", amount: 0, detail: `Siła ręki: ${strength}/100 vs wymagane ${requiredEquity.toFixed(0)}% (kursy puli) — dopłata nieopłacalna.` };
}

// ============ Game state ============
const state = {
  stack: 500,
  pot: 0,
  stage: "setup", // setup, deal, bet1, discard, replace, bet2, result
  hand: [null, null, null, null, null],
  discardFlags: [false, false, false, false, false],
  replaceTargets: [], // indices awaiting new cards
  resultMode: null, // 'fold' | 'showdown'
  log: [],
};

function addLog(text) {
  state.log.unshift(text);
  renderLog();
}

function usedCardKeys() {
  return new Set(state.hand.filter(Boolean).map(cardKey));
}

// ============ Deck UI ============
const deckEl = document.getElementById("deck");
const cardButtons = {};
SUITS.forEach((s) => {
  RANKS.forEach((r) => {
    const btn = document.createElement("button");
    btn.className = "deck-card" + (s.color === "red" ? " red" : "");
    btn.textContent = r.label + s.symbol;
    btn.dataset.rank = r.key;
    btn.dataset.suit = s.key;
    btn.addEventListener("click", () => onDeckPick(r.key, s.key));
    deckEl.appendChild(btn);
    cardButtons[`${r.key}${s.key}`] = btn;
  });
});

function onDeckPick(rank, suit) {
  const key = `${rank}${suit}`;
  if (usedCardKeys().has(key)) return;
  if (state.stage === "deal") {
    const empty = state.hand.findIndex((c) => c === null);
    if (empty === -1) return;
    state.hand[empty] = { rank, suit };
    if (state.hand.every(Boolean)) document.getElementById("confirmCardsBtn").classList.remove("hidden");
  } else if (state.stage === "replace") {
    const target = state.replaceTargets.find((i) => state.hand[i] === null);
    if (target === undefined) return;
    state.hand[target] = { rank, suit };
    if (state.replaceTargets.every((i) => state.hand[i] !== null)) {
      document.getElementById("confirmCardsBtn").classList.remove("hidden");
    }
  } else {
    return;
  }
  render();
}

// ============ Render ============
function renderTableBar() {
  document.getElementById("stackDisplay").textContent = state.stack;
  document.getElementById("potDisplay").textContent = state.pot;
  const labels = {
    setup: "Ustawienia", deal: "Rozdanie kart", bet1: "1. runda zakładów",
    discard: "Wymiana kart", replace: "Dobieranie kart", bet2: "2. runda zakładów", result: "Wynik",
  };
  document.getElementById("stageDisplay").textContent = labels[state.stage];
}

function renderHandSlotsInto(containerId, { selectable = false } = {}) {
  const el = document.getElementById(containerId);
  el.innerHTML = "";
  state.hand.forEach((card, i) => {
    const div = document.createElement("div");
    div.className = "card-slot";
    if (card) {
      div.textContent = cardLabel(card);
      div.classList.add(cardColor(card));
    } else {
      div.textContent = "?";
      div.classList.add("empty");
    }
    if (selectable && card) {
      div.classList.add("selectable");
      if (state.discardFlags[i]) div.classList.add("marked-discard");
      else div.classList.add("kept");
      div.addEventListener("click", () => {
        state.discardFlags[i] = !state.discardFlags[i];
        render();
      });
    }
    el.appendChild(div);
  });
}

function renderDeckAvailability() {
  const used = usedCardKeys();
  const active = state.stage === "deal" || state.stage === "replace";
  Object.entries(cardButtons).forEach(([key, btn]) => {
    const isUsed = used.has(key);
    btn.classList.toggle("selected", isUsed);
    btn.disabled = !active || isUsed;
  });
  deckEl.style.opacity = active ? 1 : 0.35;
}

function renderLog() {
  const el = document.getElementById("log");
  el.innerHTML = "";
  state.log.forEach((text) => {
    const li = document.createElement("li");
    li.textContent = text;
    el.appendChild(li);
  });
}

function showStagePanels() {
  document.getElementById("setupPanel").classList.toggle("hidden", state.stage !== "setup");
  document.getElementById("cardsPanel").classList.toggle("hidden", !["deal", "replace"].includes(state.stage));
  document.getElementById("discardPanel").classList.toggle("hidden", state.stage !== "discard");
  document.getElementById("bettingPanel").classList.toggle("hidden", !["bet1", "bet2"].includes(state.stage));
  document.getElementById("resultPanel").classList.toggle("hidden", state.stage !== "result");
}

function render() {
  renderTableBar();
  showStagePanels();
  renderDeckAvailability();

  if (state.stage === "deal" || state.stage === "replace") {
    document.getElementById("cardsTitle").textContent = state.stage === "deal" ? "2. Twoje karty" : "Dobierz nowe karty";
    document.getElementById("cardsHint").textContent = state.stage === "deal"
      ? "Wybierz 5 kart, które dostałeś od rozdającego."
      : `Wybierz ${state.replaceTargets.length} nową kartę/karty w miejsce wymienionych.`;
    renderHandSlotsInto("handSlots", { selectable: false });
    const filled = state.stage === "deal" ? state.hand.every(Boolean) : state.replaceTargets.every((i) => state.hand[i] !== null);
    document.getElementById("confirmCardsBtn").classList.toggle("hidden", !filled);
  }

  if (state.stage === "discard") {
    const sug = suggestDraw(state.hand);
    if (state._appliedSuggestionFor !== state.hand.map(cardKey).join(",")) {
      state.discardFlags = [false, false, false, false, false];
      sug.discardIdxs.forEach((i) => (state.discardFlags[i] = true));
      state._appliedSuggestionFor = state.hand.map(cardKey).join(",");
    }
    document.getElementById("discardSuggestion").innerHTML =
      `<div class="sug-title">Sugestia: wymień ${sug.discardIdxs.length} ${sug.discardIdxs.length === 1 ? "kartę" : "karty"}</div>${sug.reason}`;
    renderHandSlotsInto("discardSlots", { selectable: true });
    const count = state.discardFlags.filter(Boolean).length;
    document.getElementById("confirmDiscardBtn").textContent =
      count === 0 ? "Zostań przy swoich kartach (stand pat)" : `Wymień zaznaczone karty (${count})`;
  }

  if (state.stage === "bet1" || state.stage === "bet2") {
    document.getElementById("bettingTitle").textContent = state.stage === "bet1" ? "3. Pierwsza runda zakładów" : "5. Druga runda zakładów (po wymianie)";
    const strength = state.stage === "bet1" ? preDrawStrength(state.hand) : madeHandStrength(classifyHand(state.hand));
    const facing = Number(document.getElementById("facingInput").value) || 0;
    const sug = computeSuggestion(strength, facing, state.pot, state.stack);
    state._currentSuggestion = sug;
    document.getElementById("bettingSuggestion").innerHTML =
      `<div class="sug-title">Sugerowany ruch: ${sug.label}</div>${sug.detail}` +
      (sug.amount > 0 ? `<br>Kwota: ${sug.amount} (${chipBreakdown(sug.amount)})` : "");
    document.querySelectorAll(".action-btn").forEach((b) => b.classList.remove("recommended"));
    const map = { fold: "foldBtn", call: "callBtn", check: "callBtn", bet: "raiseBtn", raise: "raiseBtn", allin: "allinBtn" };
    const btn = document.getElementById(map[sug.move]);
    if (btn) btn.classList.add("recommended");
    document.getElementById("callBtn").textContent = facing > 0 ? `Dopłać (${Math.min(facing, state.stack)})` : "Sprawdź (Check)";
    if (["bet", "raise", "allin"].includes(sug.move)) {
      document.getElementById("raiseInput").value = sug.amount;
    }
  }

  if (state.stage === "result") {
    const box = document.getElementById("resultBox");
    const showdownButtons = document.getElementById("showdownButtons");
    const nextBtn = document.getElementById("nextHandBtn");
    if (state.resultMode === "fold") {
      box.innerHTML = `<div class="result-move fold">SPASOWAŁEŚ</div><div class="result-detail">Tracisz pulę: ${state.pot} żetonów.</div>`;
      showdownButtons.classList.add("hidden");
      nextBtn.classList.remove("hidden");
    } else {
      const cls = classifyHand(state.hand);
      box.innerHTML = `<div class="result-move call">POKAZANIE KART</div><div class="result-hand">Twój finalny układ: ${handName(cls)}</div><div class="result-detail">Pula do rozstrzygnięcia: ${state.pot} żetonów.</div>`;
      showdownButtons.classList.remove("hidden");
      nextBtn.classList.add("hidden");
    }
  }
}

// ============ Setup stage ============
function buildChipTray(containerId, onPick) {
  const el = document.getElementById(containerId);
  DENOMINATIONS.slice().reverse().forEach((v) => {
    const btn = document.createElement("button");
    btn.className = `chip chip-${v}`;
    btn.textContent = v;
    btn.addEventListener("click", () => onPick(v));
    el.appendChild(btn);
  });
}
buildChipTray("chipTraySetup", (v) => {
  const input = document.getElementById("stackInput");
  input.value = (Number(input.value) || 0) + v;
});
buildChipTray("chipTrayBetting", (v) => {
  const input = document.getElementById("facingInput");
  input.value = (Number(input.value) || 0) + v;
  render();
});

document.getElementById("clearStackBtn").addEventListener("click", () => {
  document.getElementById("stackInput").value = 0;
});
document.getElementById("clearFacingBtn").addEventListener("click", () => {
  document.getElementById("facingInput").value = 0;
  render();
});
document.getElementById("facingInput").addEventListener("input", render);

document.getElementById("startHandBtn").addEventListener("click", () => {
  const stackVal = Math.max(0, Number(document.getElementById("stackInput").value) || 0);
  state.stack = stackVal;
  if (state.stack < ANTE) {
    document.getElementById("notEnoughChips").classList.remove("hidden");
    return;
  }
  document.getElementById("notEnoughChips").classList.add("hidden");
  state.stack -= ANTE;
  state.pot = ANTE;
  state.hand = [null, null, null, null, null];
  state.discardFlags = [false, false, false, false, false];
  state.replaceTargets = [];
  state.log = [];
  state.stage = "deal";
  addLog(`Wpłacasz ante: ${ANTE}. Pula: ${state.pot}.`);
  render();
});

// ============ Cards stage ============
document.getElementById("confirmCardsBtn").addEventListener("click", () => {
  if (state.stage === "deal") {
    addLog(`Otrzymujesz rękę: ${state.hand.map(cardLabel).join(", ")}.`);
    state.stage = "bet1";
    document.getElementById("facingInput").value = 0;
  } else if (state.stage === "replace") {
    addLog(`Dobrane karty: ${state.replaceTargets.map((i) => cardLabel(state.hand[i])).join(", ")}. Nowa ręka: ${state.hand.map(cardLabel).join(", ")}.`);
    state.replaceTargets = [];
    state.stage = "bet2";
    document.getElementById("facingInput").value = 0;
  }
  document.getElementById("confirmCardsBtn").classList.add("hidden");
  render();
});

// ============ Discard stage ============
document.getElementById("confirmDiscardBtn").addEventListener("click", () => {
  const targets = state.discardFlags.map((f, i) => (f ? i : -1)).filter((i) => i !== -1);
  if (targets.length === 0) {
    addLog("Zostajesz przy swoich kartach (stand pat).");
    state.stage = "bet2";
    document.getElementById("facingInput").value = 0;
    render();
    return;
  }
  addLog(`Wymieniasz ${targets.length} ${targets.length === 1 ? "kartę" : "karty"}: ${targets.map((i) => cardLabel(state.hand[i])).join(", ")}.`);
  targets.forEach((i) => (state.hand[i] = null));
  state.replaceTargets = targets;
  state.stage = "replace";
  render();
});

// ============ Betting actions ============
function resolveBettingAction(move, amount) {
  const facing = Number(document.getElementById("facingInput").value) || 0;
  if (move === "fold") {
    addLog(`Spasowałeś. Pula (${state.pot}) przepada.`);
    state.resultMode = "fold";
    state.stage = "result";
    render();
    return;
  }
  if (move === "check") {
    addLog(facing > 0 ? "Błąd: nie można sprawdzić przy zakładzie do dopłaty." : "Sprawdzasz (check).");
    if (facing > 0) return;
  }
  if (move === "call") {
    const pay = Math.min(facing, state.stack);
    state.stack -= pay;
    state.pot += pay;
    addLog(pay > 0 ? `Dopłacasz ${pay}. Stos: ${state.stack}, pula: ${state.pot}.` : "Sprawdzasz (check).");
  }
  if (move === "raise" || move === "bet" || move === "allin") {
    let pay = move === "allin" ? state.stack : Math.max(0, Math.min(amount, state.stack));
    state.stack -= pay;
    state.pot += pay;
    addLog(`${move === "allin" ? "Idziesz all-in" : "Podbijasz"}: ${pay}. Stos: ${state.stack}, pula: ${state.pot}.`);
  }
  // advance
  if (state.stage === "bet1") {
    state.stage = "discard";
    state._appliedSuggestionFor = null;
  } else if (state.stage === "bet2") {
    state.resultMode = "showdown";
    state.stage = "result";
  }
  render();
}

document.getElementById("foldBtn").addEventListener("click", () => resolveBettingAction("fold"));
document.getElementById("callBtn").addEventListener("click", () => {
  const facing = Number(document.getElementById("facingInput").value) || 0;
  resolveBettingAction(facing > 0 ? "call" : "check");
});
document.getElementById("raiseBtn").addEventListener("click", () => {
  const amount = Number(document.getElementById("raiseInput").value) || 0;
  resolveBettingAction("raise", amount);
});
document.getElementById("allinBtn").addEventListener("click", () => resolveBettingAction("allin"));

// ============ Result stage ============
document.getElementById("winBtn").addEventListener("click", () => {
  state.stack += state.pot;
  addLog(`Wygrywasz pulę: +${state.pot}. Stos: ${state.stack}.`);
  state.pot = 0;
  document.getElementById("showdownButtons").classList.add("hidden");
  document.getElementById("nextHandBtn").classList.remove("hidden");
  renderTableBar();
});
document.getElementById("loseBtn").addEventListener("click", () => {
  addLog(`Przegrywasz pulę: ${state.pot}.`);
  state.pot = 0;
  document.getElementById("showdownButtons").classList.add("hidden");
  document.getElementById("nextHandBtn").classList.remove("hidden");
  renderTableBar();
});
document.getElementById("nextHandBtn").addEventListener("click", () => {
  document.getElementById("stackInput").value = state.stack;
  state.stage = "setup";
  document.getElementById("nextHandBtn").classList.add("hidden");
  render();
});

render();
