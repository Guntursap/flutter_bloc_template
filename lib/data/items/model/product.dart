class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final String thumbnail;

  const Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.thumbnail});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: json['price'] as num? ?? 0,
        thumbnail: json['thumbnail']?.toString() ?? '',
      );
}

class ProductListResponse {
  final String status;
  final List<Product> products;
  final int total;
  final String? errorMessage;

  const ProductListResponse(
      {required this.status,
      this.products = const [],
      this.total = 0,
      this.errorMessage});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['products'];
    if (list is! List) {
      return ProductListResponse(
          status: 'failed',
          errorMessage: json['message']?.toString() ?? 'Data kosong');
    }
    return ProductListResponse(
      status: 'ok',
      products: list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductDetailResponse {
  final String status;
  final Product? product;
  final String? errorMessage;

  const ProductDetailResponse(
      {required this.status, this.product, this.errorMessage});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      return ProductDetailResponse(
          status: 'failed',
          errorMessage: json['message']?.toString() ?? 'Data tidak ditemukan');
    }
    return ProductDetailResponse(
        status: 'ok', product: Product.fromJson(json));
  }
}
