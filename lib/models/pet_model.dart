class Pet {
  final String id;
  final String userId;
  final String name;
  final String species;
  final String breed;
  final String age;
  final String weight;
  final String imageUrl;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.imageUrl,
  });

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'] ?? '',
      weight: map['weight'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'image_url': imageUrl,
      'user_id': userId,
    };
  }
}
