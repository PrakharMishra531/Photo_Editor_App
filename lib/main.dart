import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(PhotoEditorApp());
}

class PhotoEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Editor App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: PhotoEditorHomePage(),
    );
  }
}

class PhotoEditorHomePage extends StatefulWidget {
  @override
  _PhotoEditorHomePageState createState() => _PhotoEditorHomePageState();
}

class _PhotoEditorHomePageState extends State<PhotoEditorHomePage> {
  File? _image;
  img.Image? _editedImage;
  // Add this variable to hold the edited image

  // Function to open the image picker
  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to apply a filter to the image
  void _applyFilter() {
    if (_image != null) {
      final image = img.decodeImage(_image!.readAsBytesSync())!;
      final editedImage = img.grayscale(
          image); // You can replace 'grayscale' with other filters like 'sepia'

      setState(() {
        _editedImage = editedImage;
      });
    }
  }

  // Function to save the edited image
  Future<void> _saveImage() async {
    // Check and request permissions
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if (_editedImage != null) {
        final directory = await getExternalStorageDirectory();

        if (directory != null) {
          final imagePath = '${directory.path}/edited_image.png';
          final file = File(imagePath);

          await file.writeAsBytes(img.encodePng(_editedImage!));

          // Refresh the gallery to make the image immediately visible
          await ImageGallerySaver.saveFile(imagePath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved successfully'),
            ),
          );
        } else {
          // Handle the case where the directory is null (e.g., if there was an error)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image. Directory is null.'),
            ),
          );
        }
      }
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission to save image denied.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Photo Editor',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 200,
                    )
                  : Placeholder(
                      fallbackHeight: 200,
                    ),
              SizedBox(height: 20),
              _editedImage != null
                  ? Image.memory(Uint8List.fromList(
                      img.encodePng(_editedImage!))) // Display the edited image
                  : Placeholder(
                      fallbackHeight: 200,
                    ),
              ElevatedButton(
                onPressed: _applyFilter,
                child: Text('Apply Filter'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveImage,
                child: Text('Save'),
              ),
              SizedBox(height: 30),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.deepPurple)),
                child: Text(
                  'MADE BY PRAKHAR',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 15.0,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
