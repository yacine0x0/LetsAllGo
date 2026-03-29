import 'package:flutter/material.dart';
import 'dart:ui';
import '../../controllers/files/files_algo2_controller.dart';
import '../pdf_images_views/pdf_viewer_page.dart';
import '../pdf_images_views/image_viewer_page.dart';
import '../../models/files/files_algo2_model.dart';

class Algo2FilesGrid extends StatelessWidget {
  final double h;
  final double w;
  final Function(int) onFileSelected;
  final Algo2FilesController controller; // ← Ce paramètre existe bien

  const Algo2FilesGrid({
    super.key,
    required this.h,
    required this.w,
    required this.onFileSelected,
    required this.controller, // ← Il est bien défini ici
  });

  @override
  Widget build(BuildContext context) {
    final files = controller.getFilesByCategory(
      controller.model.selectedAlgo,
      controller.model.selectedCategory,
    );

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, color: Colors.white24, size: h * 0.08),
            SizedBox(height: h * 0.02),
            Text(
              _getEmptyMessage(controller.model.selectedCategory),
              style: TextStyle(color: Colors.white38, fontSize: h * 0.02),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = controller.model.selectedFileIndex == index;

        return GestureDetector(
          onTap: () {
            controller.selectFile(index);
            onFileSelected(index);

            if (file.type == FileType.pdf) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerPage(
                    filePath: file.filePath,
                    title: file.title,
                  ),
                ),
              );
            } else if (file.type == FileType.image) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerPage(
                    filePath: file.filePath,
                    title: file.title,
                  ),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(h * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      file.type == FileType.pdf
                          ? Icons.picture_as_pdf
                          : Icons.image_outlined,
                      color: file.type == FileType.pdf
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      size: h * 0.05,
                    ),
                    SizedBox(height: h * 0.01),
                    Text(
                      file.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.016,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      file.chapterId,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: h * 0.013,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: h * 0.004),
                      decoration: BoxDecoration(
                        color: file.type == FileType.pdf
                            ? Colors.redAccent.withValues(alpha: 0.2)
                            : Colors.greenAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        file.type == FileType.pdf ? "PDF" : "IMAGE",
                        style: TextStyle(
                          color: file.type == FileType.pdf
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          fontSize: h * 0.012,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getEmptyMessage(String category) {
    switch (category) {
      case "courses":
        return "No courses available for Algo 2";
      case "tds":
        return "No TD's available for Algo 2";
      case "examen":
        return "No exams available for Algo 2";
      case "sheatsheet":
        return "No sheatsheets available for Algo 2";
      default:
        return "No files available for Algo 2";
    }
  }
}
