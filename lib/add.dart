import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tes/route.dart';

class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  File _imageFile;
  final _key = GlobalKey<FormState>();
  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }
  String nama,email,telpon,image,about,id_user;
  check() {
    final from = _key.currentState;
    if (from.validate()) {
      from.save();
      submit();
    }
  }
  submit() async {
    try {
      var stream = http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();

      var uri = Uri.parse(BaseUrl.add);
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile(
          'image', stream, length,filename: path.basename(_imageFile.path))); 

      request.fields['nama'] = nama;
      request.fields['email'] = email;
      request.fields['telpon'] = telpon;
      request.fields['about'] = about;
      // request.fields['id_user'] = id_user;

      var response = await request.send();

      if (response.statusCode > 2) {
        print('succes');
        setState(() {
          Navigator.pop(context);
        });
      } else {
        print('failed');
      }
    } catch (e) {
      debugPrint('eror $e');
    }
  }
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_user = preferences.getString('id_user');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150,
      child: Image.asset('./images/camera.jpg'),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Add'),
        ),
        body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _pilihGallery();
                },
                child: Center(
                  child: _imageFile == null
                    ? placeholder
                    : 
                    CircleAvatar(radius: 100,backgroundImage: FileImage(_imageFile),)
                ),
              ),
            ),
            TextFormField(
              onSaved: (e) => nama = (e),
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextFormField(
              onSaved: (e) => email = (e),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              onSaved: (e) => telpon = (e),
              decoration: InputDecoration(labelText: 'Telpon'),
            ),
            TextFormField(
              onSaved: (e) => about = (e),
              decoration: InputDecoration(labelText: 'About'),
            ),
            MaterialButton(
              onPressed: () {
                // print('eror1');
                check();
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
      );
  }
}
