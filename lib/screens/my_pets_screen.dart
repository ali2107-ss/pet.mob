import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../theme.dart';
import '../widgets/network_or_base64_image.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedSpecies = 'cat';

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showAddPetDialog() {
    _nameController.clear();
    _breedController.clear();
    _ageController.clear();
    _weightController.clear();
    _selectedSpecies = 'cat';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить питомца'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Кличка',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSpecies,
                  decoration: InputDecoration(
                    labelText: 'Тип животного',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cat', child: Text('🐱 Кот')),
                    DropdownMenuItem(value: 'dog', child: Text('🐕 Собака')),
                    DropdownMenuItem(value: 'rabbit', child: Text('🐰 Кролик')),
                    DropdownMenuItem(value: 'hamster', child: Text('🐹 Хомяк')),
                    DropdownMenuItem(value: 'bird', child: Text('🦜 Птица')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => _selectedSpecies = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    labelText: 'Порода',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Возраст',
                    hintText: '2 года',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Вес (кг)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) return;

                final petProvider = Provider.of<PetProvider>(context, listen: false);
                
                String defaultImg = 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=300&auto=format&fit=crop';
                if (_selectedSpecies == 'dog') {
                  defaultImg = 'https://images.unsplash.com/photo-1517849845537-4d257902454a?q=80&w=300&auto=format&fit=crop';
                }

                try {
                  await petProvider.addPet(
                    name: _nameController.text,
                    species: _selectedSpecies,
                    breed: _breedController.text,
                    age: _ageController.text,
                    weight: _weightController.text,
                    imageUrl: defaultImg,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Питомец добавлен!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePet(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить питомца?'),
        content: Text('Вы уверены, что хотите удалить "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final petProvider = Provider.of<PetProvider>(context, listen: false);
              try {
                await petProvider.deletePet(id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Питомец удален')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка удаления: $e')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final pets = petProvider.pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои питомцы'),
        centerTitle: true,
      ),
      body: petProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pets.isEmpty
              ? _buildEmptyState()
              : _buildPetsList(pets),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPetDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: AppTheme.greyColor),
          const SizedBox(height: 16),
          const Text(
            'Пока нет питомцев',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте информацию о своем питомце',
            style: TextStyle(color: AppTheme.greyColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPetDialog,
            icon: const Icon(Icons.add),
            label: const Text('Добавить питомца'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: NetworkOrBase64Image(
                  imageUrl: pet.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet.breed.isEmpty ? 'Порода не указана' : pet.breed,
                              style: const TextStyle(color: AppTheme.greyColor),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deletePet(pet.id, pet.name);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Удалить', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPetInfo('🎂', 'Возраст', pet.age.isEmpty ? '-' : pet.age),
                        _buildPetInfo('⚖️', 'Вес', pet.weight.isEmpty ? '-' : pet.weight),
                        _buildPetInfo('🏷️', 'Тип', _getSpeciesEmoji(pet.species)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Рекомендации для ${pet.name} скоро появятся!')),
                          );
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Рекомендуемое питание'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSpeciesEmoji(String species) {
    switch (species) {
      case 'cat': return 'Кот';
      case 'dog': return 'Собака';
      case 'rabbit': return 'Кролик';
      case 'hamster': return 'Хомяк';
      case 'bird': return 'Птица';
      default: return species;
    }
  }

  Widget _buildPetInfo(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.greyColor),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
