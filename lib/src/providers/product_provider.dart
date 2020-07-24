import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/src/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

class ProductoProvider {
  /// FIREBASE DATABASE URL
  final String _url = '';

  Future<bool> addProduct({@required final Product product}) async {
    try {
      // PRODUCTS URL
      final url = '$_url/.../products.json';
      final body = json.encode(product.toJson());
      final response = await http.post(url, body: body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct({@required final Product product}) async {
    try {
      // PRODUCT URL
      final url = '$_url/.../products/${product.id}.json';
      final body = json.encode(product.toJson());
      final response = await http.put(url, body: body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct({@required final String productId}) async {
    try {
      // PRODUCT URL
      final url = '$_url/.../products/$productId.json';
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Product>> getProductos() async {
    try {
      // PRODUCTS URL
      final url = '$_url/.../products.json';
      final response = await http.get(url);

      final Map<String, dynamic> data = json.decode(response.body);

      if (data == null) {
        return [];
      }

      final products = new List<Product>();

      data.forEach((id, value) {
        try {
          final product = Product.fromJson(value);
          product.id = id;
          products.add(product);
        } catch (e) {}
      });

      return products;
    } catch (e) {
      return [];
    }
  }

  Future<String> uploadFile(final File image) async {
    try {
      // From cloudinary
      final uploadPreset = '';
      final cloudinaryCloudName = '';
      final cloudinaryAPI =
          'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload?upload_preset=$uploadPreset';
      final mimeType = mime(image.path).split('/');

      final url = Uri.parse(cloudinaryAPI);
      final file = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      );

      final request = http.MultipartRequest('POST', url);
      request.files.add(file);

      final responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);
      final data = json.decode(response.body);
      final imageUrl = data['secure_url'];

      return imageUrl;
    } catch (e) {
      return null;
    }
  }
}
