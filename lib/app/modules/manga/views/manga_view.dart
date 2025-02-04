import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../generated/locales.g.dart';
import '../../../data/category_model.dart';
import '../../../data/chapter_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/emoticons.dart';
import '../controllers/manga_controller.dart';
import '../widgets/chapter_card.dart';
import '../widgets/manga_description.dart';

class MangaView extends GetView<MangaController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              controller.manga.value.title ?? LocaleKeys.mangaScreen_manga.tr,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await controller.loadCategoryList();
                Get.defaultDialog(
                  title: LocaleKeys.mangaScreen_category.tr,
                  content: SizedBox(
                    height: 250,
                    width: 250,
                    child: controller.categoryList.isNotEmpty
                        ? ListView.builder(
                            itemCount: controller.categoryList.length,
                            itemBuilder: (context, index) {
                              RxBool isEnabled = controller.mangaCategoryList
                                  .contains(controller.categoryList[index])
                                  .obs;
                              Category category =
                                  controller.categoryList[index];
                              return Obx(
                                () => SwitchListTile(
                                  value: isEnabled.value,
                                  title: Text(
                                    category.name ??
                                        LocaleKeys.mangaScreen_category.tr,
                                  ),
                                  onChanged: (value) {
                                    isEnabled.value = value;
                                    if (value) {
                                      controller.repository.addMangaToCategory(
                                          controller.manga.value.id!,
                                          category.id!);
                                    } else {
                                      controller.repository
                                          .removeMangaFromCategory(
                                              controller.manga.value.id!,
                                              category.id!);
                                    }
                                  },
                                ),
                              );
                            },
                          )
                        : ListTile(
                            title: Text(
                              LocaleKeys.mangaScreen_addCategoryHint.tr,
                            ),
                            onTap: () {
                              Get.back();
                              Get.toNamed(Routes.editCategories);
                            },
                          ),
                  ),
                  cancel: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      LocaleKeys.sourceScreen_close.tr,
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.category_outlined),
            ),
          ],
        ),
        floatingActionButton:
            Obx(() => controller.firstUnreadChapter.index != -1
                ? FloatingActionButton.extended(
                    onPressed: () {
                      if (controller.firstUnreadChapter.index == -1) {
                        Get.rawSnackbar(
                          title: LocaleKeys.mangaScreen_noNewChapter.tr,
                          message: LocaleKeys.mangaScreen_noNewChapter.tr,
                        );
                      } else {
                        Chapter chapter = controller.firstUnreadChapter;
                        Get.toNamed(Routes.manga +
                            "/${chapter.mangaId}/chapter/${chapter.index}");
                      }
                    },
                    icon: Icon(Icons.play_arrow_rounded),
                    label: controller.firstUnreadChapter.index != 1
                        ? Text("Resume")
                        : Text("Start"),
                    isExtended: context.width > 600 ? true : false,
                  )
                : Container()),
        body: Obx(
          () => controller.isPageLoading.value
              ? Center(child: CircularProgressIndicator())
              : context.width > 600
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Obx(
                            () => SingleChildScrollView(
                              controller: ScrollController(),
                              child: MangaDescription(
                                manga: controller.manga.value,
                                addMangaToLibrary: controller.addMangaToLibrary,
                                removeMangaFromLibrary:
                                    controller.removeMangaFromLibrary,
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(),
                        Expanded(
                          child: Obx(
                            () => controller.isLoading.value
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : controller.chapterList.isEmpty
                                    ? EmoticonsView(
                                        emptyType:
                                            LocaleKeys.mangaScreen_noChapter.tr,
                                        button: TextButton.icon(
                                          onPressed: () =>
                                              controller.loadChapterList(
                                                  onlineFetch: true),
                                          style: TextButton.styleFrom(),
                                          icon: Icon(Icons.refresh),
                                          label: Text(
                                            LocaleKeys.mangaScreen_reload.tr,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount:
                                            controller.chapterList.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            int length =
                                                controller.chapterList.length;
                                            return ListTile(
                                              title: Text(
                                                length.toString() +
                                                    " " +
                                                    LocaleKeys
                                                        .mangaScreen_chapters
                                                        .tr,
                                              ),
                                              trailing: IconButton(
                                                onPressed: () =>
                                                    controller.loadChapterList(
                                                        onlineFetch: true),
                                                icon: Icon(
                                                  Icons.refresh,
                                                ),
                                              ),
                                            );
                                          }
                                          Chapter? chapter =
                                              controller.chapterList[index - 1];
                                          return ChapterCard(
                                            chapter: chapter,
                                            controller: controller,
                                          );
                                        },
                                      ),
                          ),
                        ),
                      ],
                    )
                  : Obx(
                      () => controller.isLoading.value
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => MangaDescription(
                                    manga: controller.manga.value,
                                    addMangaToLibrary:
                                        controller.addMangaToLibrary,
                                    removeMangaFromLibrary:
                                        controller.removeMangaFromLibrary,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            )
                          : controller.chapterList.isEmpty
                              ? EmoticonsView(
                                  emptyType:
                                      LocaleKeys.mangaScreen_noChapter.tr,
                                  button: TextButton.icon(
                                    onPressed: () => controller.loadChapterList(
                                      onlineFetch: true,
                                    ),
                                    style: TextButton.styleFrom(),
                                    icon: Icon(Icons.refresh),
                                    label: Text(
                                      LocaleKeys.mangaScreen_reload.tr,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.chapterList.length + 2,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return Obx(
                                        () => MangaDescription(
                                          manga: controller.manga.value,
                                          addMangaToLibrary:
                                              controller.addMangaToLibrary,
                                          removeMangaFromLibrary:
                                              controller.removeMangaFromLibrary,
                                        ),
                                      );
                                    }
                                    if (index == 1) {
                                      int length =
                                          controller.chapterList.length;
                                      return ListTile(
                                        title: Text(
                                          length.toString() +
                                              " " +
                                              LocaleKeys
                                                  .mangaScreen_chapters.tr,
                                        ),
                                        trailing: IconButton(
                                          onPressed: () =>
                                              controller.loadChapterList(
                                                  onlineFetch: true),
                                          icon: Icon(
                                            Icons.refresh,
                                          ),
                                        ),
                                      );
                                    }
                                    Chapter? chapter =
                                        controller.chapterList[index - 2];
                                    return ChapterCard(
                                      chapter: chapter,
                                      controller: controller,
                                    );
                                  },
                                ),
                    ),
        ));
  }
}
