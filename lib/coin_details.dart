class CoinDetails {
  late String id;
  late String symbol;
  late String name;
  late String image;
  late double currentPrice;
  late double priceChange24h;

  CoinDetails(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.image,
      required this.currentPrice,
      required this.priceChange24h});

  CoinDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    symbol = json['symbol'];
    name = json['name'];
    image = json['image'];
    currentPrice = json['current_price'].toDouble();
    priceChange24h = json['price_change_24h'].toDouble();
  }

  //* Code Below to send the data to server
  // * here in our case, we dont need it.

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = this.id;
  //   data['symbol'] = this.symbol;
  //   data['name'] = this.name;
  //   data['image'] = this.image;
  //   data['current_price'] = this.currentPrice;
  //   data['price_change_24h'] = this.priceChange24h;
  //   return data;
  // }
}
