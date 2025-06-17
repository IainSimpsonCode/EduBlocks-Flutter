class Participant {
  final String ID;
  bool task1;
  bool task2;
  bool task3;
  bool task4;
  bool task5;
  bool seenGavin;

  Participant({
    required this.ID,
    this.task1 = false,
    this.task2 = false,
    this.task3 = false,
    this.task4 = false,
    this.task5 = false,
    this.seenGavin = false
  });

  factory Participant.fromJson(String id, Map<String, dynamic> json) {
    return Participant(
      ID: id,
      task1: json["task1"] ?? false,
      task2: json["task2"] ?? false,
      task3: json["task3"] ?? false,
      task4: json["task4"] ?? false,
      task5: json["task5"] ?? false,
      seenGavin: json["seenGavin"] ?? false
    );
  }
}