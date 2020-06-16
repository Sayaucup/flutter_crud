import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tes/add.dart';
import 'package:tes/edit.dart';
import 'package:tes/list.dart';
import 'package:http/http.dart' as http;
import 'package:tes/route.dart';

void main() => runApp(MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final list = new List<Listt>();
  var loading = false;

  Future allUser() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(BaseUrl.user);

    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new Listt(api['id_user'], api['nama'], api['telpon'],
            api['image'], api['about']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            allUser();
          },
          child: loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      BaseUrl.insertImage + x.image),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      x.nama,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(x.about),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Edit(x, allUser)));
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.blueAccent[300],
                            height: 1,
                            thickness: 2,
                          )
                        ],
                      ),
                    );
                  })),
    );
  }
}
