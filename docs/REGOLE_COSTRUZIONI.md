# 📐 MAGNETICREA — Guida Completa per Nuove Costruzioni

> **Questo documento va condiviso all'inizio di ogni nuova chat** con l'AI per garantire coerenza nel progetto.
> Ultimo aggiornamento: 31 maggio 2026

---

## 📱 Il Progetto

**MagnetiCrea** è un'app Flutter per bambini che guida passo-passo nella costruzione di figure con piastrelle magnetiche (tipo Magna-Tiles / Playmags).

- **Repository:** `giandomeniconigro90-pixel/magneticrea_flutter`
- **Branch principale:** `main`
- **Percorso locale:** `C:\Users\giand\Documents\GitHub\app_magneti_flutter`
- **Sviluppatore:** Giandomenico Nigro

---

## 🧱 Le Piastrelle Disponibili (`tile_types.dart`)

Ogni piastrella ha un `id` univoco, una forma (`TileShape`), un colore e la proprietà `isOpen`.

| ID | Nome | Shape | Colore | isOpen |
|---|---|---|---|---|
| `quadrato_grande` | Quadrato Grande | `squareLarge` | Rosso `#FF6B6B` | false |
| `quadrato_piccolo` | Quadrato Piccolo | `squareSmall` | Arancio `#FF9F43` | false |
| `rettangolo` | Rettangolo | `rectangle` | Verde acqua `#26D0CE` | false |
| `triangolo_equilatero` | Triangolo Equilatero | `triangleEquilateral` | Verde `#20BF6B` | false |
| `triangolo_isoscele_grande` | Triangolo Isoscele Grande | `triangleIsoscaleLarge` | Blu `#45AAF2` | false |
| `triangolo_isoscele_piccolo` | Triangolo Isoscele Piccolo | `triangleIsoscaleSmall` | Celeste `#2BCBBA` | false |
| `triangolo_rettangolo` | Triangolo Rettangolo | `triangleRight` | Viola `#A55EEA` | false |
| `rombo` | Rombo | `rhombus` | Rosso acceso `#FC5C65` | false |
| `pentagono` | Pentagono | `pentagon` | Arancio `#FD9644` | false |
| `esagono` | Esagono | `hexagon` | Blu `#4B7BEC` | false |
| `porta` | Porta | `door` | Rosa `#E84393` | **true** ⚠️ |
| `finestra` | Finestra | `window` | Rosa `#E84393` | **true** ⚠️ |
| `base_macchina` | Base Macchina | `carBase` | Azzurro `#45AAF2` | false |

---

## ⚠️ Regola isOpen (FONDAMENTALE)

La proprietà `isOpen: true` indica che la piastrella ha **aperture passanti** (arco, griglia, foro).

### ❌ Le piastrelle `isOpen: true` NON possono essere usate come:
- **Base / pavimento** → la pallina o l'oggetto cadrebbe
- **Tetto / copertura** → non copre, lascia passare tutto
- **Parete contenitiva** → non trattiene nulla (piste per palline, vasche, ecc.)

### ✅ Le piastrelle `isOpen: true` POSSONO essere usate come:
- Pareti decorative (es. facciata di una casa con porta)
- Elementi architettonici (portali, finestre di castelli)
- Pannelli laterali dove il passaggio è voluto (es. entrata di un tunnel)

### Piastrelle isOpen attualmente
| ID | Apertura |
|---|---|
| `porta` | Arco passante nella metà inferiore |
| `finestra` | Griglia 2×2 passante al centro |

> 💡 **Regola pratica AI:** Prima di assegnare `porta` o `finestra` a uno step, verifica che il ruolo strutturale lo permetta.

---

## 🏗️ Struttura di una Costruzione (`constructions.dart`)

```dart
Construction(
  id: 'nome_univoco',           // snake_case, univoco
  name: 'Nome Visibile',        // stringa leggibile
  emoji: '🏠',                  // emoji rappresentativa
  is3d: true,                   // true = ha viewer 3D, false = solo 2D flat
  difficulty: Difficulty.easy,  // easy / medium / hard / master
  category: Category.buildings, // buildings / animals / nature / vehicles / shapes / fantasy
  timeMinutes: 10,              // tempo stimato in minuti
  ageGroups: ['5-7', '8+'],     // '3-5' / '5-7' / '8+'
  description: '...',           // frase breve descrittiva
  tip: '...',                   // consiglio pratico per il bambino
  piecesNeeded: {               // mappa tile_id → quantità
    'quadrato_grande': 4,
    'triangolo_isoscele_grande': 1,
  },
  steps: [ ... ],               // lista BuildStep (vedi sotto)
)
```

---

## 🪢 Struttura di uno Step (`BuildStep`)

```dart
BuildStep(
  stepNumber: 2,                          // progressivo da 1
  tileId: 'quadrato_grande',              // null per intro/finale
  action: 'Metti il quadrato rosso...',   // istruzione per il bambino
  placedPieces: [
    PlacedPiece(
      tileId: 'quadrato_grande',
      x: 0.5,         // 0.0 = sinistra, 1.0 = destra
      y: 0.65,        // 0.0 = alto, 1.0 = basso
      rotation: 0,    // gradi, opzionale
      isNew: true,    // true = pezzo nuovo (evidenziato/animato), false = già posato
    ),
  ],
)
```

### Regole degli Step

1. **Step 1** è sempre l'**intro**: `tileId: null`, `placedPieces: []`, action = "Prendi tutti i pezzi..."
2. **Step finale** è sempre il **completamento**: `tileId: null`, `placedPieces: []`, action = "🎉 Bravissimo! ..."
3. Ogni step intermedio aggiunge **UN SOLO pezzo nuovo** (`isNew: true`)
4. I pezzi già posati negli step precedenti restano con `isNew: false` (semitrasparenti)
5. Le coordinate x/y sono **frazioni** (0.0–1.0) relative alla dimensione dello schermo
6. Le rotazioni sono in **gradi** (0, 90, 180, 270 o angoli liberi)

---

## 🗂️ Struttura delle Difficoltà

| Livello | Pezzi | Step | Età | Esempi |
|---|---|---|---|---|
| `easy` | 3–5 | 4–6 | 3-5, 5-7 | Casa, Pesce, Fiore |
| `medium` | 5–8 | 6–9 | 5-7, 8+ | Razzo, Barca, Torre |
| `hard` | 8–12 | 7–10 | 8+ | Cubo 3D, Castello, Elicottero |
| `master` | 12+ | 10–14 | 8+ | Drago |

---

## 🎯 Regola 2D vs 3D (FONDAMENTALE)

Ogni nuova costruzione va classificata **prima di creare qualsiasi codice**.
L'AI deve dichiarare esplicitamente la scelta con motivazione:
> *"Questa costruzione la faccio [Solo 2D / 2D+3D / Solo 3D] perché [motivazione]."*

### ✅ Solo 2D (`is3d: false`)
- La figura è **piatta per natura** (pesce, fiore, farfalla, stella)
- Non ha volume reale nemmeno nei Magna-Tiles fisici
- Il 3D non aggiunge comprensione
- Target 3-5 anni prevalente
- **Nessun GLB da generare**

### ✅ 2D + 3D (`is3d: true` + toggle UI)
- La figura **può essere costruita sia piatta che volumetrica**
- Il 3D aiuta a capire la struttura spaziale
- Esempi: Casa, Razzo, Barca, Torre, Castello, Elicottero, Treno, Drago
- **Servono i GLB** generati con Blender
- Ha sia `placedPieces` (per vista 2D) che GLB (per vista 3D)

### ✅ Solo 3D (`is3d: true`, no 2D flat utile)
- La figura è **intrinsecamente volumetrica** e non ha senso piatta
- Esempio: Cubo 3D
- **Servono i GLB**, la vista 2D flat non ha senso

### Tabella decisionale rapida

| Criterio | Solo 2D | 2D + 3D | Solo 3D |
|---|---|---|---|
| Forma | Piatta per natura | Può essere entrambe | Volumetrica pura |
| Pezzi | ≤5, stesso piano | Qualsiasi | Struttura chiusa |
| Età target | 3-5 prevalente | 5-7 / 8+ | 8+ |
| 3D aggiunge valore? | ❌ No | ✅ Sì | ✅ Fondamentale |
| GLB necessari? | ❌ No | ✅ Sì | ✅ Sì |

---

## 🧪 Come Funziona il Viewer 3D

### File GLB
- Percorso: `assets/models/steps/{id}_step{N}.glb`
- Esempio torre: `torre_step1.glb` … `torre_step18.glb`
- **Step 1 (intro) e step finale: GLB vuoto** (scena Blender vuota)
- Ogni GLB mostra i pannelli accumulati fino a quello step
- Pannello nuovo = opacità `0.85` (pieno, colorato)
- Pannello già posato = opacità `0.35` (semitrasparente)

### Impostazioni Camera (`guide_screen.dart`)
```dart
fieldOfView: '25deg'
cameraOrbit: '45deg 60deg 8m'
minCameraOrbit: 'auto auto 3m'
maxCameraOrbit: 'auto auto 20m'
```

### Colori nei GLB (`genera_modelli_3d.py`)
```python
COLORS = {
    'quadrato_grande':           (1.0,  0.42, 0.42, 1),  # rosso
    'quadrato_piccolo':          (1.0,  0.62, 0.26, 1),  # arancio
    'rettangolo':                (0.15, 0.82, 0.80, 1),  # verde acqua
    'triangolo_isoscele_grande': (0.27, 0.67, 0.95, 1),  # blu
    'triangolo_isoscele_piccolo':(0.17, 0.80, 0.73, 1),  # celeste
    'triangolo_equilatero':      (0.13, 0.75, 0.42, 1),  # verde
    'triangolo_rettangolo':      (0.65, 0.37, 0.92, 1),  # viola
    'rombo':                     (0.99, 0.36, 0.40, 1),  # rosso acceso
    'pentagono':                 (0.99, 0.59, 0.27, 1),  # arancio
    'esagono':                   (0.29, 0.48, 0.93, 1),  # blu
    'porta':                     (0.91, 0.26, 0.58, 1),  # rosa
    'finestra':                  (0.91, 0.26, 0.58, 1),  # rosa
    'base_macchina':             (0.27, 0.67, 0.95, 1),  # azzurro
}
```

---

## 🐍 Script Blender (`scripts/genera_modelli_3d.py`)

### Come aggiungere una nuova costruzione 3D

1. Definire la lista `{id}_steps = [[]]` (step 1 = intro vuoto)
2. Aggiungere i pezzi step per step usando le funzioni helper
3. Aggiungere finale vuoto: `{id}_steps.append([])`
4. Inserire in `CONSTRUCTIONS`:
```python
CONSTRUCTIONS = {
    'torre': (torre_steps, (4.5, -4.5, 4.5)),
    'nuova': (nuova_steps, (3.5, -3.5, 2.8)),  # <-- aggiungere qui
}
```
5. Eseguire in locale:
```bash
blender --background --python scripts/genera_modelli_3d.py
```

### Funzioni primitive disponibili

| Funzione | Cosa crea |
|---|---|
| `add_quad_wall(name, cx, cy, cz, face, is_new)` | Pannello quadrato (muro) |
| `add_tri_roof_pyramid(side, base_z, apex_z, is_new)` | Triangolo tetto a piramide |
| `quad_old(face, piano)` | Helper: pannello già posato al piano N |
| `quad_new(face, piano)` | Helper: pannello nuovo al piano N |

### Orientamento facce
- `'N'` = Nord (davanti, y negativo)
- `'S'` = Sud (dietro, y positivo)
- `'E'` = Est (destra, x positivo)
- `'W'` = Ovest (sinistra, x negativo)

---

## 📦 Asset necessari per costruzione

| Tipo costruzione | File necessari |
|---|---|
| Solo 2D | Solo `assets/images/tiles/*.png` (già presenti, non toccare) |
| 2D + 3D | `assets/models/steps/{id}_step1.glb` … `{id}_stepN.glb` |
| Solo 3D | Stessi GLB sopra |

---

## 🔄 Workflow standard per nuova costruzione

### Costruzione Solo 2D
```
1. Aggiungere Construction(...) in constructions.dart con is3d: false
2. Definire gli step con PlacedPiece (coordinate x/y)
3. Push su GitHub (AI)
4. git pull && flutter run (sviluppatore in locale)
```

### Costruzione 2D + 3D
```
1. Aggiungere Construction(...) in constructions.dart con is3d: true
2. Definire gli step con PlacedPiece (per vista 2D)
3. Aggiungere la costruzione in genera_modelli_3d.py
4. Push su GitHub (AI)
5. git pull in locale
6. Eseguire script Blender per generare GLB
7. git add assets/models/steps/{id}_step*.glb
8. git commit -m "Add: GLB {nome} {N} step"
9. git push origin main
10. flutter run
```

---

## 📋 Costruzioni Esistenti — Stato Attuale

| ID | Nome | Difficoltà | is3d | GLB | Stato |
|---|---|---|---|---|---|
| `casa` | Casa 🏠 | easy | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `pesce` | Pesce 🐟 | easy | false | ❌ | ✅ Solo 2D (OK) |
| `fiore` | Fiore 🌺 | easy | false | ❌ | ✅ Solo 2D (OK) |
| `stella` | Stella ⭐ | easy | false | ❌ | ✅ Solo 2D (OK) |
| `farfalla` | Farfalla 🦋 | easy | false | ❌ | ✅ Solo 2D (OK) |
| `razzo` | Razzo 🚀 | medium | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `uccello` | Uccello 🦅 | medium | false | ❌ | ✅ Solo 2D (OK) |
| `macchina` | Macchina 🚗 | medium | false | ❌ | ✅ Solo 2D (OK) |
| `torre` | Torre 🏰 | medium | true | ✅ 18 GLB | ✅ Completa |
| `barca` | Barca ⛵ | medium | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `albero` | Albero 🌲 | medium | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `cubo_3d` | Cubo 3D 🧊 | hard | true | ✅ | ✅ Solo 3D (OK) |
| `castello` | Castello 🏯 | hard | true | ✅ | ✅ Completo |
| `elicottero` | Elicottero 🚁 | hard | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `treno` | Treno 🚂 | hard | false | ❌ | ⚠️ Da convertire in 2D+3D |
| `drago` | Drago 🐉 | master | false | ❌ | ⚠️ Da convertire in 2D+3D |

---

## 🎮 Feature UI da Implementare (TODO)

- [ ] **Toggle 2D/3D** nella `GuideScreen` per costruzioni con `is3d: true`
- [ ] Fix `_glbPath()` in `guide_screen.dart` — deve rispettare il flag `is3d`
- [ ] Convertire le costruzioni marcate ⚠️ in 2D+3D (casa, razzo, barca, albero, elicottero, treno, drago)

---

## ⚡ Comandi Git Essenziali

Dopo ogni push dell'AI su GitHub, eseguire **sempre**:
```bash
cd C:\Users\giand\Documents\GitHub\app_magneti_flutter
git pull origin main
flutter pub get
flutter run
```

Dopo generazione GLB in locale:
```bash
git add assets/models/steps/*.glb
git commit -m "Add: GLB {nome} {N} step"
git push origin main
```

---

## 📝 Regole di Stile per le Istruzioni (step `action`)

1. **Linguaggio semplice**, adatto a bambini 3-8 anni
2. **Verbo imperativo** all'inizio: "Metti", "Attacca", "Appoggia", "Chiudi"
3. **Colore del pezzo** sempre esplicito: "il quadrato rosso", "il triangolo blu"
4. **Posizione** sempre indicata: "a sinistra", "sopra", "davanti a te"
5. **Emoji** di rinforzo nei step chiave (completamento piano, finale)
6. **Lunghezza max** ~60 caratteri per leggibilità su mobile
7. **Step finale** sempre con emoji grande: 🎉🏠🏰🐟🌺 ecc.

---

## 🔑 Informazioni Tecniche Progetto

```
Flutter SDK:      stabile
Dart:             3.x
Dipendenze chiave:
  - model_viewer_plus    (viewer GLB in-app)
  - google_fonts         (font Nunito)
  - flutter_svg          (icone SVG)
Blender:          3.x / 4.x (per generazione GLB)
Python:           3.x (script Blender)
```

---

*Documento aggiornato il 31 maggio 2026 — aggiunta proprietà isOpen, nuove piastrelle: rettangolo, porta, finestra, base_macchina.*
*Aggiornare questo file ogni volta che si aggiungono costruzioni o si modificano le regole.*
