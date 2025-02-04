import 'package:get/get.dart';

import '../../../data/about_model.dart';
import '../repository/about_repository.dart';

class AboutController extends GetxController {
  final Rx<About?> _about = About().obs;
  final AboutRepository repository = AboutRepository();

  About? get getAbout => _about.value;
  set setAbout(About? about) => _about.value = about;

  @override
  void onReady() async {
    setAbout = await repository.getAbout();
    super.onReady();
  }
}
