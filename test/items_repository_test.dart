import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

Map<String, dynamic> prod(int id) => {
      'id': id, 'title': 'Item $id', 'description': 'Desc',
      'price': 100, 'thumbnail': 'https://x/y.png',
    };

void main() {
  test('getItems → list + total', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => http.Response(
            json.encode({'products': [prod(1), prod(2)], 'total': 194}),
            200)));
    final res = await repo.getItems(limit: 2);
    expect(res.status, 'ok');
    expect(res.products.length, 2);
    expect(res.total, 194);
  });

  test('getItems products null → failed, tidak crash', () async {
    final repo = ItemsRepo(
        client: MockClient(
            (_) async => http.Response(json.encode({'products': null}), 200)));
    final res = await repo.getItems();
    expect(res.status, 'failed');
    expect(res.products, isEmpty);
  });

  test('getItemDetail 404 → failed bawa pesan server', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => http.Response(
            json.encode({'message': 'Product with id 0 not found'}), 404)));
    final res = await repo.getItemDetail(0);
    expect(res.status, 'failed');
    expect(res.errorMessage, contains('not found'));
  });

  test('offline → pesan Indonesia', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => throw const SocketException('x')));
    final res = await repo.getItems();
    expect(res.errorMessage, contains('koneksi internet'));
  });
}
