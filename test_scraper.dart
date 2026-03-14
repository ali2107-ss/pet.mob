import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final query = Uri.encodeComponent('Royal Canin Maxi Adult');
  final url = Uri.parse('https://html.duckduckgo.com/html/?q=$query');
  
  final client = HttpClient();
  client.userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    // look for img src
    final regex = RegExp(r'<img[^>]+src="([^"]+)"');
    final matches = regex.allMatches(body);
    for (var match in matches) {
      if (match.group(1)!.contains('http')) {
        print('Image: ${match.group(1)}');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
