# Design System Specification: The Clinical Sentinel

> Extracted from Google Stitch Project ID: `18416799649176081778`

## 1. Overview & Creative North Star

**Creative North Star: The Clinical Sentinel**
In high-stress medical emergencies, cognitive load is the enemy. This design system moves beyond "clean" into the realm of **Clinical Sentinel**—a high-end editorial approach that combines the authority of a premium medical journal with the rapid-response clarity of a performance cockpit. 

We reject the "generic app" aesthetic of boxed grids and thin lines. Instead, we utilize **Intentional Asymmetry** and **Aggressive Typography** to command the user's focus. By treating the screen as a series of layered, high-contrast plates, we ensure that in a moment of panic, the "What to do next" is the only thing that exists. The system feels expensive because it is precise; it feels trustworthy because it is calm.

---

## 2. Colors

The color strategy is rooted in "Life-Saving Contrast." We use a stark, surgical foundation punctuated by a visceral primary red.

### Color Tokens (Material Design Convention)

| Token | Hex |
|---|---|
| Primary | `#B7131A` |
| Primary Container | `#DB322F` |
| On Primary | `#FFFFFF` |
| Secondary | `#A13D36` |
| Secondary Container | `#FF857A` |
| Tertiary | `#006578` |
| Tertiary Container | `#008097` |
| Surface | `#F9F9F9` |
| Surface Container Low | `#F3F3F4` |
| Surface Container | `#EEEEEE` |
| Surface Container High | `#E8E8E8` |
| Surface Container Highest | `#E2E2E2` |
| Surface Container Lowest | `#FFFFFF` |
| On Surface | `#1A1C1C` |
| On Surface Variant | `#5B403D` |
| Outline | `#906F6C` |
| Outline Variant | `#E4BEB9` |
| Error | `#BA1A1A` |
| Error Container | `#FFDAD6` |

### The "No-Line" Rule
Designers are prohibited from using 1px solid borders for sectioning. Structural boundaries must be defined solely through background color shifts or the "Ghost Border" (outline_variant at 15% opacity).

### Surface Hierarchy & Nesting
- Main Screen: `surface` (#F9F9F9)
- Instruction Card: `surface-container-low` (#F3F3F4)
- Actionable Element within Card: `surface-container-lowest` (#FFFFFF)

### The "Glass & Gradient" Rule
- **Urgent CTAs:** Linear gradient from `primary` → `primary_container` at 15°
- **Floating Navigation:** Glassmorphism with `surface` at 80% opacity + 20px backdrop-blur

---

## 3. Typography

Font: **Public Sans** — neutral, authoritative, highly legible.

- **Display Large (3.5rem / Bold):** Single-word life-critical status
- **Headline Large (2rem / Bold):** Primary instructional voice
- **Title Medium (1.125rem / Medium):** Labels and secondary info
- **Body Large (1rem / Regular):** Explanatory text (minimize in high-stress flows)

---

## 4. Elevation & Depth

- **Tonal Layering** over traditional drop shadows
- **Ambient Shadows:** y-offset: 16px, blur: 40px, on-surface at 8% opacity
- **Ghost Border:** outline_variant at 15% opacity
- **RTL:** Depth layering mirrors perfectly

---

## 5. Components

### SOS Button
- Full-width, primary gradient
- `headline-sm` (Bold), Uppercase
- Minimum 64dp height

### Action Buttons
- **Primary:** Solid primary, 12px rounded corners
- **Secondary:** surfaceContainerHighest bg, no border
- **Tertiary:** No bg, primary text bold, 48×48dp hit area

### Instructional Cards
- No divider lines — 2rem vertical spacing between steps
- surfaceContainerLow background

### Progress Bars
- Track: surfaceVariant
- Indicator: primary or tertiary
- Height: 8px

### Chips (Category Selectors)
- Accent color at 10% opacity bg + bold accent text label

---

## 6. Do's and Don'ts

### Do
- 48dp minimum touch target for every interactive element
- Leave "wasteful" white space — breathing room reduces panic
- Bold for "Action", medium for "Label"
- Test RTL for optical balance

### Don't
- No 1px black/grey borders
- No Material Design shadows (0.2 alpha)
- No icons without labels in critical paths
- No body text under 16px for instructions

- No body text under 16px for instructions

---

# Design System Specification: The Clinical Sentinel (Dark Mode)

> Mirror of Light Theme (Source: Google Stitch Asset `9ded492310cb4c238c243c195180f0ee`)

## 1. Overview & Creative North Star

**Creative North Star: The Clinical Sentinel**
The dark theme preserves the "Pulse of Precision" philosophy. In low-light or high-stress environments, the dark interface reduces eye strain while maintaining the authority of a premium medical instrument. The layout remains identical to the Light Theme, utilizing **Intentional Asymmetry** and **Aggressive Typography** to command focus.

---

## 2. Colors

The dark color strategy utilizes a "Deep Black" foundation to ensure the red emergency accents vibrate with maximum clarity and visibility.

### Color Tokens (Material Design Convention)

| Token | Hex |
|---|---|
| Primary | `#FFB4AC` |
| Primary Container | `#FF544C` |
| On Primary | `#690006` |
| Secondary | `#9ECAFF` |
| Secondary Container | `#1E95F2` |
| Tertiary | `#F9ABFF` |
| Tertiary Container | `#D560E6` |
| Surface | `#131313` |
| Surface Container Low | `#1C1B1B` |
| Surface Container | `#201F1F` |
| Surface Container High | `#2A2A2A` |
| Surface Container Highest | `#353534` |
| Surface Container Lowest | `#0E0E0E` |
| On Surface | `#E5E2E1` |
| On Surface Variant | `#E4BEB9` |
| Outline | `#AB8985` |
| Outline Variant | `#5B403D` |
| Error | `#FFB4AB` |
| Error Container | `#93000A` |

### The "No-Line" Rule
Identical to Light Theme: Designers are prohibited from using 1px solid borders for sectioning. Structural boundaries must be defined solely through background color shifts or the "Ghost Border" (outline_variant at 15% opacity).

### Surface Hierarchy & Nesting
- Main Screen: `surface` (#131313)
- Instruction Card: `surface-container-low` (#1C1B1B)
- Actionable Element within Card: `surface-container-lowest` (#0E0E0E)

### The "Glass & Gradient" Rule
- **Urgent CTAs:** Linear gradient from `primary` → `primary_container` at **15°** (Matches Light Mode)
- **Floating Navigation:** Glassmorphism with `surface` at 80% opacity + 20px backdrop-blur

---

## 3. Typography

Font: **Public Sans** — neutral, authoritative, highly legible.

- **Display Large (3.5rem / Bold):** Single-word life-critical status
- **Headline Large (2rem / Bold):** Primary instructional voice
- **Title Medium (1.125rem / Medium):** Labels and secondary info
- **Body Large (1rem / Regular):** Explanatory text (minimize in high-stress flows)

---

## 4. Elevation & Depth

- **Tonal Layering** over traditional drop shadows
- **Ambient Shadows:** y-offset: 16px, blur: 40px, on-surface at 8% opacity
- **Ghost Border:** outline_variant at 15% opacity
- **RTL:** Depth layering mirrors perfectly

---

## 5. Components

### SOS Button
- Full-width, primary gradient
- `headline-sm` (Bold), Uppercase
- Minimum 64dp height

### Action Buttons
- **Primary:** Solid primary, 12px rounded corners
- **Secondary:** surfaceContainerHighest bg, no border
- **Tertiary:** No bg, primary text bold, 48×48dp hit area

### Instructional Cards
- No divider lines — 2rem vertical spacing between steps
- surfaceContainerLow background

### Progress Bars
- Track: surfaceVariant
- Indicator: primary or tertiary
- Height: 8px

---

## 6. Do's and Don'ts

### Do
- 48dp minimum touch target for every interactive element
- Leave "wasteful" white space — breathing room reduces panic
- Bold for "Action", medium for "Label"
- Test RTL for optical balance

### Don't
- No 1px black/grey borders
- No Material Design shadows (0.2 alpha)
- No icons without labels in critical paths
- No body text under 16px for instructions

---

**Director's Final Note:** 
Consistency is clarity. By maintaining identical spacing, typography, and structural rules across both themes, we ensure the user’s muscle memory and cognitive mapping remain intact regardless of the lighting conditions. Be bold. Be precise.