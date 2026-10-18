# Watch Play Talk - Source Brief

## Title
Watch Play Talk - bilingual lessons for little learners

## Description
Watch Play Talk is a safe, ad-free family app where toddlers and young kids (ages 2 to 6) learn Spanish and English with an on-screen teacher, Maestra Luna. A child picks their profile and follows a winding lesson path. Each lesson has three steps: watch a short clip from the weekly episode, play an action game that reinforces the words, then answer a voice quiz that listens for the answer on the device and never says "wrong". Stars and stickers reward every lesson. Parents sign in, start a free trial, set up child profiles, and follow weekly progress, words practiced and Talk results behind a grown-up gate.

## Store links
Not yet published (proof of concept).

## Platform
Both - iOS (iPhone, iPad) and Android (phones, tablets) from one Flutter codebase.

## Category
Education / Kids (Apple Kids Category, Google Play Families).

## Features
- Parent sign-in (Apple, Google, email) and a 7-day free trial with annual or monthly plans, restore purchases.
- Parental gate (type a spelled-out number) before purchases, settings, the parent area and mic permission.
- Up to 4 child profiles with nickname, age band, avatar and lesson language.
- Learn path with done, current and locked lessons, a glowing current node and a teacher badge.
- Lesson intro with the three steps and time estimate.
- Watch: lesson clip with timed vocabulary cards (word, translation, pronunciation, repetitions).
- Play: Flame "Catch" game with arrow and drag controls, score, stars and floating feedback; content loaded from validated game settings.
- Talk: teacher prompt, giant mic button, on-device answer check (right, close, none), gentle correction, two-try limit, tap answers.
- Lesson complete: stars, new sticker reveal, confetti.
- Episodes library with filters and an episode player with ES/EN captions and lesson chapters.
- Sticker book with progress, latest unlocked sticker and locked slots.
- Parent dashboard: learner switcher, weekly goal and daily practice, words practiced, recent lessons, subscription.
- Child progress: topic progress, Talk results (right, close, taps), lesson history, streak.
- Settings: lesson language, daily time limit, microphone toggle with a consent screen, data export, account deletion.
- Phone layout with a bottom tab bar; tablet layout with a side tab rail and two-column learn path.

## Tech stack
- Flutter (Dart), one codebase for iOS and Android, phone and tablet layouts.
- State: Riverpod 3 Notifiers.
- Navigation: go_router with a stateful shell for the kid tabs.
- Games: Flame 2D engine with template settings validated against a schema.
- Speech: on-device answer matcher over closed answer lists, toddler forms and bilingual sound-alike keys (recognizer simulated for the demo).
- Design system: Readex Pro + Quicksand (bundled), lavender and peach tokens, 64 pt kid tap targets.
- Testing: unit tests for the matcher and game settings; integration_test walkthroughs for screenshots and demos.

## Industry
Children's education and entertainment (EdTech, language learning, kids streaming).

## Metrics
Unpublished proof of concept, no store metrics. Scope: 19 phone screens plus a tablet learn path, 3 playable lessons (Hello and Goodbye, Numbers 1 to 5, Colors), 4 episodes, 12 sticker slots, 3 child profiles.

## Research notes
- Verified in the app: full parent and child journeys, the Catch game loop, the Talk state machine, the answer matcher and the game settings validation (unit tested).
- Mocked: sign-in, trial purchase, episode video (still image with a simulated clock), the speech recognizer (scripted N-best guesses behind the mic tap), teacher audio, and all data (in memory).
- Future expansion: real HLS streaming, StoreKit 2 / Play Billing through RevenueCat, Apple and Android on-device speech recognition, Supabase backend for approved lessons and progress events, more game templates (runner, drive, pop, feed, sort), smart TV apps (Apple TV, Google TV, Fire TV, Roku).
