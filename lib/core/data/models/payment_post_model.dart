class PaymentPostModel {
  String? customerName;
  String? address;
  int? totalCost;
  String? paymentMethod;

  PaymentPostModel({
    this.customerName,
    this.address,
    this.totalCost,
    this.paymentMethod,
  });

  PaymentPostModel copyWith({
    String? customerName,
    String? address,
    int? totalCost,
    String? paymentMethod,
  }) =>
      PaymentPostModel(
        customerName: customerName ?? this.customerName,
        address: address ?? this.address,
        totalCost: totalCost ?? this.totalCost,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
}
