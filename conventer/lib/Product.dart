class Product {
  final int Cur_ID;
  final String Date;
  final String Cur_Abbreviation;
  final int Cur_Scale;
  final String Cur_Name;
  final double Cur_OfficialRate;

  Product(this.Cur_ID, this.Date, this.Cur_Abbreviation, this.Cur_Scale, this.Cur_Name, this.Cur_OfficialRate);
  factory Product.fromMap(Map<String, dynamic> json) {
    return Product(
      json['Cur_ID'],
      json['Date'],
      json['Cur_Abbreviation'],
      json['Cur_Scale'],
      json['Cur_Name'],
      json['Cur_OfficialRate'],
    );
  }
}
//{"":170,"":"2020-12-09T00:00:00","":"AUD","":1,"":"Австралийский доллар","":1.9008}