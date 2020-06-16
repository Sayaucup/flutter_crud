import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tes/list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:tes/route.dart';

class Edit extends StatefulWidget {
  final Listt model;
  final VoidCallback reload;
  Edit(this.model, this.reload);
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  final _key = new GlobalKey<FormState>();
  String nama, about, id_user;
  TextEditingController txtnama, txtabout;
  ngambil() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_user = preferences.getString('id_user');
    });
    txtnama = TextEditingController(text: widget.model.nama);
    txtabout = TextEditingController(text: widget.model.about);
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      submit();
    } else {
      print('eror');
    }
  }

  submit() async {
    try {
      var uri = Uri.parse(BaseUrl.edit);
      var request = http.MultipartRequest('POST', uri);

      request.fields['nama'] = nama;
      request.fields['about'] = about;
      request.fields['id_user'] = widget.model.id_user;
      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      request.files.add(http.MultipartFile('image', stream, length,
          filename: path.basename(_imageFile.path)));
      var response = await request.send();
      if (response.statusCode > 2) {
        print('succes');
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
      } else {
        print('failed');
      }
    } catch (e) {
      debugPrint('eror $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ngambil();
  }

  File _imageFile;
  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
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
                    ? CircleAvatar(radius: 100,backgroundImage: NetworkImage(BaseUrl.insertImage + widget.model.image),)
                    // Image.network(BaseUrl.insertImage + widget.model.image)
                    : 
                    CircleAvatar(radius: 100,backgroundImage: FileImage(_imageFile),)
                    // Image.file(_imageFile,fit: BoxFit.cover,),
                ),
              ),
            ),
            TextFormField(
              controller: txtnama,
              onSaved: (e) => nama = (e),
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextFormField(
              controller: txtabout,
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
