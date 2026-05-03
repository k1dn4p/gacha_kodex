# Gacha Kodex - Flutter Gacha App

A fun Flutter application where users can select unopened tickets and discover prize levels with fancy animations!

## Features

✨ **Three Main Pages:**
1. **Main Page** - Introduction to Gacha mechanics and prize levels
2. **Gacha Page** - View and select unopened tickets
3. **Result Page** - Display prize with fancy animations (A-C prizes)

🎯 **Key Functionality:**
- 8 pre-loaded tickets with different prize levels (A, B, C, D, E)
- Only unopened tickets can be selected
- Opened tickets are visually distinguished
- Prize levels: A (Legendary), B (Epic), C (Rare), D (Uncommon), E (Common)
- Fancy scale and rotate animations for A, B, C prizes
- State management using Provider

## Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── models/
│   └── ticket.dart          # Ticket data model
├── providers/
│   └── ticket_provider.dart  # State management with Provider
└── pages/
    ├── main_page.dart       # Intro and instructions
    ├── gacha_page.dart      # Ticket selection
    └── result_page.dart     # Prize reveal with animations
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK

### Installation

1. Clone or extract the project
2. Navigate to the project directory:
   ```bash
   cd gacha_kodex
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **flutter**: UI framework
- **provider**: State management
- **cupertino_icons**: Icon library

## How to Play

1. Start the app on the Main Page
2. Read the Gacha introduction and prize levels
3. Click "Start Gacha" to go to the Gacha Page
4. Select an unopened ticket (purple cards with 🎟️)
5. View your prize on the Result Page with animations
6. Opened tickets (✅) cannot be selected again

## Customization

### Adding More Tickets
Edit `lib/providers/ticket_provider.dart` in the `_initializeTickets()` method

### Changing Prize Colors and Emojis
Modify `lib/pages/result_page.dart`:
- `_getPrizeColor()` - Change colors
- `_getPrizeEmoji()` - Change emojis
- `_getPrizeTitle()` - Change titles

### Adjusting Animations
In `lib/pages/result_page.dart`, modify:
- Animation duration (currently 1500ms)
- Tween values for scale and rotation
- Curve types for different feel

## Future Enhancements

- Add actual images for tickets
- Implement persistence (save opened tickets)
- Add sound effects
- Add more animation variations
- Implement probability distribution for prizes
- Add user progression system

---

Built with Flutter ❤️
