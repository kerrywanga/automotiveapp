import 'dart:io';

import 'package:automotiveapp/constants/colors.dart';
import 'package:automotiveapp/models/service_model.dart';
import 'package:automotiveapp/usecase/firebasestorage_apis.dart';
import 'package:automotiveapp/widgets/custom_button.dart';
import 'package:automotiveapp/widgets/text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  TextEditingController nameController = TextEditingController();

  late String urlDownload;
  late String filename;

// Handling file upload

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    setState(() {
      pickedFile = result?.files.first;
    });
  }

  Future uploadFile() async {
    final path = 'services/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final filename = pickedFile!.name;

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    urlDownload = await snapshot.ref.getDownloadURL();

    print("Download link: $urlDownload");
    print("______________________________________");
    print("File name is: $filename");
    uploadTask = null;
  }

  buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go("/service_management");
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Add Service"),
        centerTitle: true,
        backgroundColor: blackfade,
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: ListView(
          children: [
            SizedBox(
              width: size.width,
              height: size.width * 0.3,
              child: pickedFile == null
                  ? const Text("Please pick a file")
                  : Expanded(
                      child: Container(
                      color: blue[100],
                      child: Center(
                        // child: Text(pickedFile!.name),
                        child: Image.file(
                          File(pickedFile!.path!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
            ),
            const SizedBox(height: 10,),
            buildProgress(),
            const SizedBox(
              height: 20,
            ),
            CustomTextField2(
                size: size,
                inputController: nameController,
                obsecureText: false,
                labeltext: "Service name"),
            const SizedBox(
              height: 30,
            ),
            CustomButton(titleText: "Add Service", onPressed: () {
              FirebaseStorageApis().addService(ServiceModel(name: nameController.text, downloadurl: urlDownload, imageName: filename));
            })
          ],
        ),
      ),
    );
  }
}
