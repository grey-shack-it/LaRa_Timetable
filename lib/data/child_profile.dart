import 'package:hive/hive.dart';

part 'child_profile.g.dart';

@HiveType(typeId: 1)
class ChildProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  ChildProfile({required this.id, required this.name});
}
