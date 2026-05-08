import '../constants/theme_config.dart';

class Ticket {
  final int id;
  final String prizeLevel; // A, B, C, D, E
  final String themeName; // 
  bool isOpened;

  Ticket({
    required this.id,
    required this.prizeLevel,
    required this.themeName,
    this.isOpened = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      prizeLevel: json['prizeLevel'] as String,
      themeName: json['themeName'] as String,
      isOpened: json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prizeLevel': prizeLevel,
      'themeName': themeName,
      'isOpened': isOpened,
    };
  }

  String get imagePathTicket {
    if (!isOpened) {
      return 'assets/images/$themeName/ticket_unopened.png';
    }

    return switch (prizeLevel) {
      'A' => 'assets/images/$themeName/ticket_opened_A.png',
      'B' => 'assets/images/$themeName/ticket_opened_B.png',
      'C' => 'assets/images/$themeName/ticket_opened_C.png',
      'D' => 'assets/images/$themeName/ticket_opened_D.png',
      'E' => 'assets/images/$themeName/ticket_opened_E.png',
      'F' => 'assets/images/$themeName/ticket_opened_F.png',
      'G' => 'assets/images/$themeName/ticket_opened_G.png',
      'H' => 'assets/images/$themeName/ticket_opened_H.png',
      _ => 'assets/images/$themeName/ticket_opened_H.png',
    };
  }
  String get imagePathPrize {

    return switch (prizeLevel) {
      'A' => 'assets/images/$themeName/prize_A.png',
      'B' => 'assets/images/$themeName/prize_B.png',
      'C' => 'assets/images/$themeName/prize_C.png',
      'D' => 'assets/images/$themeName/prize_D.png',
      'E' => 'assets/images/$themeName/prize_E.png',
      'F' => 'assets/images/$themeName/prize_F.png',
      'G' => 'assets/images/$themeName/prize_G.png',
      'H' => 'assets/images/$themeName/prize_H.png',
      'Lastone' => 'assets/images/$themeName/prize_Lastone.png',
      _ => 'assets/images/$themeName/prize_H.png',
    };
  }

  String get prizeTitle {
    final themePrizeNames = prizeNames[themeName];
    return themePrizeNames?[prizeLevel] ?? '$prizeLevel 상';
  }
}
