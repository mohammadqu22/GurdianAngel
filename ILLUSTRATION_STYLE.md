# Illustration Style Guide: The Clinical Sentinel

> Companion to `DESIGN.md` — Reference this file before generating any in-app medical illustration.

---

## 1. Overview & Visual North Star

**Illustration North Star: "Flat-Vector Precision"**
Every illustration in Guardian Angel must function as a *visual instruction*, not a decoration. The goal is to reduce cognitive load in a high-stress emergency scenario. Illustrations should be immediately legible at a glance, free of visual noise, and consistent with the Clinical Sentinel design language.

The style is **bold flat-vector** — clean geometric forms, a strictly controlled palette, and zero photorealistic elements. Think modern medical infographic crossed with a premium first-aid reference card.

---

## 2. Style Pillars

### 2.1 Rendering Style
- **Flat vector illustration** — no gradients on characters, no shading, no drop shadows on figures
- **Solid fills only** for human figures and objects
- Geometric, slightly simplified anatomy — not cartoon, not realistic
- Strokeless or minimal stroke: forms are defined by **color contrast**, not outlines (mirrors the "No-Line" rule in DESIGN.md)
- **Clean white or very light grey background** (`#F9F9F9` or `#FFFFFF`) — never a scene or environment background

### 2.2 Color Palette
Use the Clinical Sentinel colors from `DESIGN.md`. Do not introduce new colors.

| Role | Hex | Usage |
|---|---|---|
| Primary Red | `#B7131A` | Critical action highlights, blood representation, urgency indicators |
| Primary Container Red | `#DB322F` | Secondary red elements, MDA logo star |
| Skin Tone (Neutral) | `#F2C9A0` | Human figures (default) |
| Dark Figure | `#3A3A3A` | Clothing, dark accessories |
| Off-White | `#F9F9F9` | Background, bandages, gauze |
| Accent Teal | `#006578` | Secondary objects (e.g., phone, gloves) |
| Text in Illustration | `#1A1C1C` | Any labels or call-out numbers inside the illustration |
| MDA Red | `#B7131A` | Magen David Adom star and branding |

### 2.3 Human Figure Style
- Simplified silhouettes — gender-neutral where possible
- Skin: flat `#F2C9A0` fill (no gradient, no shading)
- Hair: flat dark fill `#3A3A3A`
- Clothing: flat, solid color (use `#3A3A3A`, `#006578`, or primary red for helper/responder)
- **No facial expressions** needed — posture communicates intent
- Proportional: slightly tall and slender (not chibi/cartoon)

---

## 3. Localization: Israel / MDA Branding

All illustrations for Guardian Angel are Israel-specific. The following localization rules are **mandatory**:

### 3.1 Emergency Symbol
- **Use the Magen David Adom (MDA) Star of David**, NOT the Red Cross or Red Crescent
- The MDA logo is a **red Star of David** (six-pointed) on a white background
- Color: `#B7131A` (primary red) on white
- Apply it to: first-aid kits, response vehicles, instructional badges, responder clothing

### 3.2 Emergency Number
- **Always display "101"** as the emergency number — never "911" or "112"
- When a phone is shown, the screen should display **"MDA — 101"**
- In any call-to-action label within an illustration: **"Call MDA on 101"**

---

## 4. Composition Rules

### 4.1 Layout
- **Portrait-oriented, square crop (1:1)** — images display in a square container in the app
- **Main action centered** — the instruction being demonstrated fills ~60% of the frame
- Generous white space around the figure — breathing room is critical (mirrors DESIGN.md philosophy)
- A maximum of **2 figures** per illustration (helper + patient). Keep it simple.

### 4.2 Step Numbers & Labels
- If a step number badge is included, use a **bold red circle** (`#B7131A`) with white `#FFFFFF` number inside
- Font style: bold, sans-serif, consistent with Public Sans weight
- Keep text labels in illustrations **minimal** — one short phrase maximum

### 4.3 Action Arrows & Directional Cues
- Use **bold, flat arrows** in primary red (`#B7131A`) to indicate motion (pressure direction, movement)
- Arrow style: solid fill, slightly rounded tip, no outline
- Motion lines: simple parallel strokes in `#906F6C` (outline color), 2–3 lines max

### 4.4 Objects & Props
- Medical objects (bandages, gauze, gloves): flat white or light grey fills with subtle shape definition
- Phone: flat teal (`#006578`) body, white screen
- First-aid kit: white box with MDA Star of David (`#B7131A`)
- Elevation/tourniquets: flat dark (`#3A3A3A`) strap with red clasp

---

## 5. Prohibited Elements

Never include the following in any Guardian Angel illustration:

| Prohibited | Reason |
|---|---|
| Red Cross symbol | Not used in Israel — use MDA Star of David |
| "911" | Wrong emergency number for Israel |
| Photorealistic rendering | Too slow to parse under stress |
| Gradients on figures | Breaks flat-vector consistency |
| Complex backgrounds (rooms, streets) | Adds visual noise |
| Gore or graphic injury depiction | Inappropriate for a first-aid app |
| Copyrighted logos or brand marks | Legal |
| Drop shadows on illustrated elements | Breaks the Clinical Sentinel flat system |
| More than 3 focal elements per frame | Cognitive overload |

---

## 6. Prompt Template for AI Image Generation

When generating a new illustration, use this base prompt structure:

```
Flat vector medical illustration, clean white background (#F9F9F9), 
Clinical Sentinel style. [DESCRIBE THE ACTION]. 

Human figure with flat skin tone (#F2C9A0), solid dark clothing (#3A3A3A). 
No outlines, no gradients, no shadows on figures. Bold red (#B7131A) accent 
for [KEY ELEMENT]. Generous white space. Square composition (1:1).

Israel-specific: any first-aid kit shows a red Star of David (Magen David Adom / MDA), 
not a Red Cross. Any phone display shows "MDA — 101". 
No photorealism. Strokeless flat vector style. Medical infographic aesthetic.
```

Replace `[DESCRIBE THE ACTION]` with the specific step instruction (e.g., "Person pressing both hands firmly onto a wound on the upper arm").

---

## 7. Emergency Protocol Coverage

Use this checklist to track illustration completion across all protocols:

| Protocol | Steps | Status |
|---|---|---|
| **Bleeding** | 9 steps | ✅ Complete |
| **Burns** | 7 steps | ✅ Complete |
| **Choking (Adult)** | 7 steps | ✅ Complete |
| **Choking (Infant)** | — | ⬜ Pending |
| **CPR (Adult)** | 9 steps | ✅ Complete |
| **CPR (Infant)** | 7 steps | ✅ Complete |
| **Fracture** | 8 steps | ✅ Complete |
| **Seizure** | 7 steps | ✅ Complete |
| **Shock** | — | ⬜ Pending |
| **Stroke** | — | ⬜ Pending |

---

## 8. File Naming Convention

Illustration assets must follow this naming pattern:

```
assets/images/{protocol}/{protocol}_step_{N}.png
```

**Examples:**
- `assets/images/bleeding/bleeding_step_1.png`
- `assets/images/burns/burns_step_3.png`
- `assets/images/cpr/cpr_step_2.png`

All images should be **PNG format**, minimum **512×512px**, exported at **2x** for Retina displays.

---

**Director's Final Note:**
Every illustration is a life-saving instruction. Clarity beats artistry. If a user in a panic can't understand the illustration in under 2 seconds, it fails. Be precise. Be bold. Be consistent. When in doubt, simplify.
