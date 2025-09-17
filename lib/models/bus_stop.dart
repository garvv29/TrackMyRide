class BusStop {
  final String id;
  final String name;
  final double distance;
  final List<String> busNumbers;
  final String address;
  final String nextBusArrival;

  BusStop({
    required this.id,
    required this.name,
    required this.distance,
    required this.busNumbers,
    required this.address,
    required this.nextBusArrival,
  });
}