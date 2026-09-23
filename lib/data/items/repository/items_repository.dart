import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc_template/core/constants/api_config.dart';
import 'package:flutter_bloc_template/data/items/model/product.dart';

class ItemsRepo {
  final http.Client client;
  ItemsRepo({http.Client? client}) : client = client ?? http.Client();

  Future<ProductListResponse> getItems({int limit = 20, int skip = 0}) async {
    try {
      final res = await client
          .get(Uri.parse('$apiUrl/products?limit=$limit&skip=$skip'));
      if (res.body.isEmpty) {
        return const ProductListResponse(
            status: 'failed', errorMessage: 'Respon server kosong');
      }
      return ProductListResponse.fromJson(json.decode(res.body));
    } on SocketException {
      return const ProductListResponse(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const ProductListResponse(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  Future<ProductDetailResponse> getItemDetail(int id) async {
    try {
      final res = await client.get(Uri.parse('$apiUrl/products/$id'));
      if (res.body.isEmpty) {
        return const ProductDetailResponse(
            status: 'failed', errorMessage: 'Respon server kosong');
      }
      return ProductDetailResponse.fromJson(json.decode(res.body));
    } on SocketException {
      return const ProductDetailResponse(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const ProductDetailResponse(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }
}
