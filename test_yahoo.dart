import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final query = Uri.encodeComponent('royal canin bag');
  final url = Uri.parse('https://images.search.yahoo.com/search/images?p=$query');
  
  final client = HttpClient();
  client.userAgent = 'Mozilla/5.0';
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    // Yahoo search sometimes puts URLs in `img src='...'` or `<a href='...img...'>`
    final regex = RegExp(r"src='(https://tse[^']+)'");
    final matches = regex.allMatches(body);
    for (var match in matches) {
      print('URL: ${match.group(1)}');
      return;
    }
    
    print('Not found in tse. Trying src="http...');
    final regex2 = RegExp(r'src="(http[^"]+)"');
    final matches2 = regex2.allMatches(body);
    for (var match in matches2) {
      if (match.group(1)!.contains('yahoo') == false) {
        print('URL: ${match.group(1)}');
      }
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
