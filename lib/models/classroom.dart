class Classroom {
  String number;
  String floor;
  String? name; // Opcional

  // Constructor con todos los parámetros
  Classroom({required this.number, required this.floor, this.name});

  // Constructor con solo number y floor
  Classroom.withoutName({required this.number, required this.floor});

  // Constructor sin parámetros
  Classroom.empty()
      : number = '',
        floor = '',
        name = null;

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      number: json['number'],
      floor: json['floor'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'floor': floor,
      'name': name,
    };
  }

  String toFormattedString() {
    return 'Número de Aula: $number\n'
        'Planta: $floor\n'
        'Nombre del Aula: ${name ?? 'N/A'}'; // Manejo opcional para el caso de name siendo null
  }
}
