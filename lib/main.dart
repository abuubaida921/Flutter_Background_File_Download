import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'download_task.dart';
import 'download_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Download Manager',
      home: DownloadManagerScreen(),
    );
  }
}

class DownloadManagerScreen extends StatelessWidget {
  final DownloadController downloadController = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Manager'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: downloadController.downloadTasks.length,
          itemBuilder: (context, index) {
            final task = downloadController.downloadTasks[index];
            return ListTile(
              leading: SizedBox(width: 50,height:50,child: CachedNetworkImage(fit:BoxFit.fill, imageUrl: task.avatars,),),
              title: Text(task.title),
              subtitle: Text(
                'Author: ${task.author}\nProgress: ${task.progress.toStringAsFixed(2)}%',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      task.isDownloading
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (task.isDownloading) {
                        downloadController.pauseDownload(task);
                      } else {
                        downloadController.resumeDownload(task);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      downloadController.deleteDownload(task);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example function to simulate adding a download task
          final exampleTask = DownloadTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'The Art of War',
            url: 'https://aiquest.org/wp-content/uploads/2024/07/Deep-Learning-Generative-AI.pdf',
            filePath: '',
            author: 'W. P. (William Price) Craighill',
            publisher: 'DigiLibraries.com',
            category: 'Fiction',
            avatars: 'https://digilibraries-com.s3.eu-central-1.amazonaws.com/covers/60894b61-8f08-4bc2-94db-0ca1edb8480d.jpg',
          );

          downloadController.downloadTasks.add(exampleTask);
          downloadController.downloadPDF(exampleTask);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
