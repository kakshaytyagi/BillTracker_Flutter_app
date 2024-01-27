class CardData {
  final String image;
  final String text;
  bool isPinned;

  CardData({
    required this.image,
    required this.text,
    this.isPinned = false,
  });
}

List<CardData> cardList = [
];


