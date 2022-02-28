import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:photo_album/addphoto_page.dart';
import 'package:photo_album/gmap.dart';
import 'package:photo_album/blocs/theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_album/api/firebase_api.dart';
import 'model/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'database.dart';
import 'view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FirebaseFile>> futureFiles;
  late Database db;
  List docs = [];

  bool _checkConfiguration() => true;

  Future getIngredients(String url) async {
    var list = [];
    FirebaseFirestore.instance
        .collection('details')
        .where("url", isEqualTo: url)
        .get()
        .then((data) => data.docs.forEach((doc) {
              setState(() {
                list.add(doc['ingredients']);
              });
            }));
  }

  @override
  void initState() {
    super.initState();
    _getLocationPermission();

    futureFiles = FirebaseApi.listAll('images/');
  }

  void _getLocationPermission() async {
    var location = new Location();
    try {
      location.requestPermission();
    } on Exception catch (_) {
      print('There was a problem allowing location access');
    }
  }

  initialise(String url) async {
    db = Database();
    await db.initiliase();
    await db.read2(url).then((value) => {
          setState(() {
            docs = value;
          })
        });
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.blue
          : Colors.black,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddPhoto()));
        },
      ),
      body: FutureBuilder<List<FirebaseFile>>(
        future: futureFiles,
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Some error occurred!'));
              } else {
                final files = snapshot.data!;

                return Container(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(50, 10, 0, 0),
                            child: FlatButton(
                                child: Text('Dark Theme'),
                                onPressed: () =>
                                    _themeChanger.setTheme(ThemeData.dark())),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(90, 10, 0, 0),
                            child: FlatButton(
                                child: Text('Light Theme'),
                                onPressed: () =>
                                    _themeChanger.setTheme(ThemeData.light())),
                          )
                        ]),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.grey[700],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: GridView.builder(
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                final file = files[index];

                                return buildFile(context, file);
                              },
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget buildFile(BuildContext context, FirebaseFile file) {
    return GestureDetector(
      child: GridTile(
        child: ClipRRect(
          child: Image.network(
            file.url,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10)),
        ),
      ),
      onTap: () async {
        await initialise(file.url);

        await Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Scaffold(
                    body: GestureDetector(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Hero(
                          tag: 'imageHero',
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                              ),
                              Image.network(
                                file.url,
                                height: 500,
                              ),
                              Text('Tap to minimize.'),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 150,
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Do you want to delete this image?"),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "No",
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      )),
                                                  FlatButton(
                                                      onPressed: () async {
                                                        await firebase_storage
                                                            .FirebaseStorage
                                                            .instance
                                                            .refFromURL(
                                                                file.url)
                                                            .delete();
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomePage(),
                                                        ));
                                                      },
                                                      child: Text("Yes"))
                                                ],
                                              );
                                            });
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.map),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => GMap()),
                                        );
                                      }),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(20.0),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      margin: EdgeInsets.all(10),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => View(
                                                        detail: docs[index],
                                                        db: db,
                                                        key: null,
                                                      ))).then((value) => {
                                                if (value != null)
                                                  {initialise(file.url)}
                                              });
                                        },
                                        contentPadding: EdgeInsets.only(
                                            right: 30, left: 36),
                                        title: Text(docs[index]['description']),
                                        subtitle: Wrap(
                                          spacing: 12,
                                          children: <Widget>[
                                            Text("Location: (" +
                                                docs[index]['location'] +
                                                ")"),
                                            Text("\n"),
                                            Text("Date/Time: " +
                                                docs[index]['datentime']),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }));
      },
    );
  }
}
