import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final query = Uri.encodeComponent('royal canin maxi');
  final url = Uri.parse('https://search.wb.ru/exactmatch/ru/common/v4/search?dest=-1257786&query=$query&resultset=catalog');
  
  final client = HttpClient();
  client.userAgent = 'Mozilla/5.0';
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    final jsonResponse = jsonDecode(body);
    final products = jsonResponse['data']['products'] as List;
    if (products.isNotEmpty) {
      final id = products[0]['id'];
      print('Found WB product ID: $id');
      
      // Compute WB image URL
      // Logic for basket:
      int vol = id ~/ 100000;
      int part = id ~/ 1000;
      int basket = 1;
      if (vol >= 0 && vol <= 143) {
        basket = 1;
      } else if (vol <= 287) basket = 2;
      else if (vol <= 431) basket = 3;
      else if (vol <= 719) basket = 4;
      else if (vol <= 1007) basket = 5;
      else if (vol <= 1061) basket = 6;
      else if (vol <= 1115) basket = 7;
      else if (vol <= 1169) basket = 8;
      else if (vol <= 1313) basket = 9;
      else if (vol <= 1601) basket = 10;
      else if (vol <= 1655) basket = 11;
      else if (vol <= 1919) basket = 12;
      else basket = 13;
      
      String imgUrl = 'https://basket-$basket.wb.ru/vol$vol/part$part/$id/images/big/1.webp';
      print('URL: $imgUrl');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
