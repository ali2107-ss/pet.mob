import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../l10n/translation.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _astanaCenter = const LatLng(51.1439, 71.4358);
  
  // Пример адресов зоомагазинов в Астане
  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'ЗооМаг "Хан Шатыр"',
      'address': 'пр. Туран 37',
      'location': const LatLng(51.1328, 71.4038),
    },
    {
      'name': 'ЗооМаг на Водно-зеленом',
      'address': 'ул. Д. Кунаева 14',
      'location': const LatLng(51.1306, 71.4310),
    },
    {
      'name': 'ЗооМаг Expo',
      'address': 'пр. Мангилик Ел 53/1',
      'location': const LatLng(51.0911, 71.4172),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['stores_map'] ?? 'Магазины на карте'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _astanaCenter,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'kz.pet.mob',
              ),
              MarkerLayer(
                markers: _stores.map((store) {
                  return Marker(
                    width: 60.0,
                    height: 60.0,
                    point: store['location'],
                    child: GestureDetector(
                      onTap: () {
                        _showStoreInfo(context, store, t);
                      },
                      child: const Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                            size: 40.0,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                _mapController.move(_astanaCenter, 12.0);
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreInfo(BuildContext context, Map<String, dynamic> store, Map<String, String> t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.store, color: AppTheme.primaryColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store['address'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.directions),
                  label: Text(t['build_route'] ?? 'Построить маршрут'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
