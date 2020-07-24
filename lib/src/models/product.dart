class Product {
  String id;
  String title;
  double price;
  bool available;
  String photoUrl;

  Product({
    this.id,
    this.title = '',
    this.price = 0,
    this.available = true,
    this.photoUrl,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    available = json['available'];
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['available'] = this.available;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}
