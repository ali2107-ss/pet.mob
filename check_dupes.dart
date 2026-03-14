import 'lib/providers/product_provider.dart';
void main() {
  var p = ProductProvider().items;
  var ids = p.map((e) => e.id).toList();
  var setIds = ids.toSet();
  print('Total items: ${ids.length}, unique ids: ${setIds.length}');
  
  if (ids.length != setIds.length) {
    var seen = <String>{};
    for (var id in ids) {
      if (seen.contains(id)) {
        print('Duplicate id: $id');
      } else {
        seen.add(id);
      }
    }
  }
}
