class Ticket {
  final int id;
  final String prizeLevel; // A, B, C, D, E
  bool isOpened;

  Ticket({
    required this.id,
    required this.prizeLevel,
    this.isOpened = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      prizeLevel: json['prizeLevel'] as String,
      isOpened: json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prizeLevel': prizeLevel,
      'isOpened': isOpened,
    };
  }

  String get imagePathTicket {
    if (!isOpened) {
      return 'assets/images/ticket_unopened.png';
    }

    return switch (prizeLevel) {
      'A' => 'assets/images/ticket_opened_A.png',
      'B' => 'assets/images/ticket_opened_B.png',
      'C' => 'assets/images/ticket_opened_C.png',
      'D' => 'assets/images/ticket_opened_D.png',
      'E' => 'assets/images/ticket_opened_E.png',
      'F' => 'assets/images/ticket_opened_F.png',
      'G' => 'assets/images/ticket_opened_G.png',
      _ => 'assets/images/ticket_opened.png',
    };
  }
  String get imagePathPrize {

    return switch (prizeLevel) {
      'A' => 'assets/images/prize_A.png',
      'B' => 'assets/images/prize_B.png',
      'C' => 'assets/images/prize_C.png',
      'D' => 'assets/images/prize_D.png',
      'E' => 'assets/images/prize_E.png',
      'F' => 'assets/images/prize_F.png',
      'G' => 'assets/images/prize_G.png',
      _ => 'assets/images/prize.png',
    };
  }
}
