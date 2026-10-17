# Watch Play Talk - Design System

Kids language-learning app (Spanish + English, ages 2 to 6) with a parent area. Bright, soft, friendly, calm. Light theme only.

## Color (use ONLY these colors)
- Background (tinted page): #F6F4FC
- Surface (cards, sheets): #FFFFFF
- Accent (lavender, large fills, icons, active states, hero numerals): #9D7BEA
- Accent fill (any button or chip with a WHITE label): #8165C0
- Accent tint (selected fills, badges): #F1ECFC
- Accent pressed: #7159A9
- Support (peach, secondary data, illustration, chips with dark labels): #FFB199
- Text primary #120C1F, secondary #4B4360, tertiary #857D99
- Border / divider #E6E1F2
- Semantic: success #16A34A, warning #D97706, danger #DC2626
No default indigo/violet palette, no flat neutral grey. Neutrals are lavender-tinted.

## Typography
- UI + body: Readex Pro. Display headings (kid screens, hero titles): Quicksand Bold.
- Display 34/700 -0.02em, Title 22/600, Body 17/400, Label 16/600, Caption 14/500.
- Kid-facing screens use few words, large type, and icons/pictures over text.

## Frame + safe areas
393x852 (iPhone 16/17). Keep top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.

## Shape, spacing, elevation
- Radius: card 24, control 16, input 12, pill 999.
- 8pt spacing scale, 20px screen edge padding.
- Soft shadows only: 0 1px 2px rgba(18,12,31,.05) + 0 8px 24px rgba(18,12,31,.07). No hard shadows.
- Kid tap targets at least 64px; parent screens at least 44px.

## Icons
One set only: Phosphor regular rounded outline, 24px (32px in the kid tab bar), 1.75 stroke. Never mix outline and filled.

## Controls (one spec each, reused everywhere)
- Primary button: pill, soft gradient #9D7BEA -> #FFB199 or solid #8165C0, white label, min 56px tall (64px on kid screens). Pressed #7159A9. Disabled 40% opacity.
- Secondary button: white pill, 2px #9D7BEA border, #8165C0 label.
- Input: 12px radius, #E6E1F2 border, focus = #9D7BEA 2px ring, error = #DC2626.
- Card: white, 24px radius, soft shadow.
- Chip: pill, #F1ECFC fill, #8165C0 label; support chips #FFB199 fill with #120C1F label.

## Shared components
- Bottom tab bar (kid screens only): exactly three tabs in this order: Learn (map/path icon), Watch (play-circle icon), Stickers (sticker icon). 72px tall, white, flat (no gradient), top hairline #E6E1F2. Active tab: icon + label in #8165C0 with a #F1ECFC pill behind the icon. Inactive: #857D99. Never rename, reorder, add or remove tabs.
- Kid header: child photo avatar + name on the left, star counter and a small lock icon (parent area) on the right.
- Lesson step pills: Watch, Play, Talk shown as three pills; done = check, active = accent fill, upcoming = outline.
- Parent area and all onboarding, lesson-step, player and game screens show NO bottom tab bar.

## Gradient + focal rules
- Soft 2-stop gradient #9D7BEA -> #FFB199 (low contrast) only on hero cards, the primary CTA, and the lesson path backdrop. Tab bar stays flat.
- Every screen has ONE bold focal element (the path, a hero card, the giant mic button, a sticker reveal) that owns the visual weight; everything else stays quiet.

## Imagery
Real photography only for people, places and objects (warm, natural light, diverse families, teacher Maestra Luna: a smiling young Latina teacher in a lavender cardigan). Game scenes, stickers and confetti use flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects anywhere.

## Child safety tone
No ads, no external links on kid screens, no red X or "wrong" wording. Mistakes get "Great try!" and a replay.
