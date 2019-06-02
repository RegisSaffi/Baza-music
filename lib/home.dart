import 'package:flutter/material.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baza_music/utils/slider.dart';
import 'package:baza_music/models/items.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const Color color = Color(0xFF007e9a);

class HomeHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class HomeState extends State<HomeHome> with SingleTickerProviderStateMixin {
  bool loaded = false;

  SliverPersistentHeader makeHeader(String headerText, {Color co = color}) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: co == color ? 50.0 : 120.0,
        maxHeight: co == color ? 50.0 : 200.0,
        child: Container(
            child: Center(
                child: Text(
          headerText,
          style: TextStyle(
              color: co,
              fontWeight: co == color ? FontWeight.bold : FontWeight.normal),
        ))),
      ),
    );
  }

  SliverPersistentHeader makeLoader() {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: 120.0,
        maxHeight: 200.0,
        child: Container(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  saveData(String data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("data", data);
  }

  Future<List<Song>> _fetchSongsFromWeb() async {
    final response = await http.get(
      "http://bazaassistant.herokuapp.com/music/all_songs",
    );
    print(
        "--------------------------     home   data fetched from internet          ----------------------------");
    print(response.body);
    final List jsonData = json.decode(response.body);
    saveData(response.body);

    List<Song> mySongs = createSongsList(jsonData);

    return mySongs;
  }

  Future<List<Song>> _fetchSongsFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String data = pref.getString("data");

    final List jsonData = json.decode(data);
    List<Song> mySongs = createSongsList(jsonData);
    print(
        "=======================================local dada fetched.================================================");

    return mySongs;
  }

  List<Song> createSongsList(List data) {
    List<Song> finList = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]['name'];
      String artist = data[i]['artist'];
      String image = data[i]['image'];
      String url = data[i]['url'];
      String category = data[i]['category'];

      Song sng = new Song(
          name: name,
          url: url,
          artist: artist,
          image: image,
          category: category);
      finList.add(sng);
    }
    return finList;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Song>>(
            future: _fetchSongsFromWeb(),
            builder: (context, snapshot) {
              List<Song> allData = snapshot.data;

              List<Song> week = new List();
              List<Song> recent = new List();
              List<Song> month = new List();
              List<Song> times = new List();

              List<Song> semanticWeek = new List();

              for (int a = 0; a < 5; a++) {
                semanticWeek.add(new Song(
                    artist: "..",
                    name: "Loading..",
                    url: "none",
                    image: "http://www.example.com/image.png",
                    category: "none"));
              }

              if (allData != null) {
                for (int a = 0; a < allData.length; a++) {
                  Song sng = allData[a];

                  switch (sng.category) {
                    case 'new':
                      recent.add(sng);
                      break;
                    case 'week':
                      week.add(sng);
                      break;
                    case 'month':
                      month.add(sng);
                      break;
                    default:
                      times.add(sng);
                      break;
                  }
                }
              }

              return allData == null
                  ? FutureBuilder<List<Song>>(
                      future: _fetchSongsFromLocal(),
                      builder: (context, snapshot) {
                        List<Song> allData = snapshot.data;

                        List<Song> week = new List();
                        List<Song> recent = new List();
                        List<Song> month = new List();
                        List<Song> times = new List();

                        if (allData != null) {
                          for (int a = 0; a < allData.length; a++) {
                            Song sng = allData[a];

                            switch (sng.category) {
                              case 'new':
                                recent.add(sng);
                                break;
                              case 'week':
                                week.add(sng);
                                break;
                              case 'month':
                                month.add(sng);
                                break;
                              default:
                                times.add(sng);
                                break;
                            }
                          }
                        }

                        return CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              backgroundColor: Colors.white,
                              pinned: false,
                              title: Text(
                                "Popular this week",
                                style: TextStyle(color: Colors.grey),
                              ),
                              expandedHeight: 180.0,
                              elevation: 2.0,
                              flexibleSpace: FlexibleSpaceBar(
                                background: snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError
                                    ? new CarouselWithIndicator(semanticWeek)
                                    : new CarouselWithIndicator(week),
                              ),
                            ),
                            makeHeader('New tracks'),
                            snapshot.connectionState == ConnectionState.waiting
                                ? makeLoader()
                                : snapshot.hasError ||
                                        snapshot.connectionState ==
                                            ConnectionState.none
                                    ? makeHeader("Can't load songs.",
                                        co: Colors.grey)
                                    : SliverGrid(
                                        gridDelegate:
                                            new SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200.0,
                                          mainAxisSpacing: 5.0,
                                          crossAxisSpacing: 5.0,
                                        ),
                                        delegate:
                                            new SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                          return recent != null
                                              ? MyCard(recent[index], false)
                                              : null;
                                        },
                                                childCount: recent != null
                                                    ? recent.length
                                                    : 0),
                                      ),
                            makeHeader('Popular this month.'),
                            snapshot.connectionState == ConnectionState.waiting
                                ? makeLoader()
                                : snapshot.hasError ||
                                        snapshot.connectionState ==
                                            ConnectionState.none
                                    ? makeHeader("Loading...",
                                        co: Colors.grey)
                                    : SliverGrid(
                                        gridDelegate:
                                            new SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 120.0,
                                          mainAxisSpacing: 5.0,
                                          crossAxisSpacing: 5.0,
                                        ),
                                        delegate:
                                            new SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                          return month != null
                                              ? MyCard(month[index], true)
                                              : null;
                                        },
                                                childCount: month != null
                                                    ? month.length
                                                    : 0),
                                      ),
                            makeHeader('Popular all the times.'),
                            snapshot.connectionState == ConnectionState.waiting
                                ? makeLoader()
                                : snapshot.data == null
                                    ? makeHeader("Loading...",
                                        co: Colors.grey)
                                    : SliverGrid(
                                        gridDelegate:
                                            new SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 120.0,
                                          mainAxisSpacing: 5.0,
                                          crossAxisSpacing: 5.0,
                                        ),
                                        delegate:
                                            new SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                          return times != null
                                              ? MyCard(times[index], true)
                                              : null;
                                        },
                                                childCount: times != null
                                                    ? times.length
                                                    : 0),
                                      ),
                          ],
                        );
                      })

              //Internet future builder to load data from internet
              // if local doesn't have saved data, we'll fall back to internet loading and vice versa        
                  : CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          pinned: false,
                          title: Text(
                            "Popular this week",
                            style: TextStyle(color: Colors.grey),
                          ),
                          expandedHeight: 180.0,
                          elevation: 2.0,
                          flexibleSpace: FlexibleSpaceBar(
                            background: snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.hasError
                                ? new CarouselWithIndicator(semanticWeek)
                                : new CarouselWithIndicator(week),
                          ),
                        ),
                        makeHeader('Recently added.'),
                        snapshot.hasData
                            ? SliverGrid(
                                gridDelegate:
                                    new SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                ),
                                delegate: new SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  return recent != null
                                      ? MyCard(recent[index], false)
                                      : null;
                                },
                                    childCount:
                                        recent != null ? recent.length : 0),
                              )
                            : snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? makeLoader()
                                : makeHeader("Loading...",
                                    co: Colors.grey),
                        makeHeader('Popular this month.'),
                        snapshot.hasData
                            ? SliverGrid(
                                gridDelegate:
                                    new SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 120.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                ),
                                delegate: new SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  return month != null
                                      ? MyCard(month[index], true)
                                      : null;
                                },
                                    childCount:
                                        month != null ? month.length : 0),
                              )
                            : snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? makeLoader()
                                : makeHeader("Cant load songs",
                                    co: Colors.grey),
                        makeHeader('Popular all the times.'),
                        snapshot.hasData
                            ? SliverGrid(
                                gridDelegate:
                                    new SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 120.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                ),
                                delegate: new SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  return times != null
                                      ? MyCard(times[index], true)
                                      : null;
                                },
                                    childCount:
                                        times != null ? times.length : 0),
                              )
                            : snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? makeLoader()
                                : makeHeader("Loading...", co: Colors.grey)
                      ],
                    );
            }));
  }
}

class MyCard extends StatelessWidget {
  bool small;
  Song song;

  MyCard(Song song, final bool isSmall) {
    this.small = isSmall;
    this.song = song;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(0.0),
      shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0))),
      elevation: 2.0,
      child: Stack(
        children: <Widget>[
          AspectRatio(
            child: CachedNetworkImage(
              imageUrl: song.image,
              placeholder: Image.asset("images/placeholder.png"),
              fit: BoxFit.cover,
            ),
            aspectRatio: 1.0,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x00000000),
                    const Color(0x00000000),
                    const Color(0x00000000),
                    const Color(0xcc000000),
                  ]),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  small
                      ? SizedBox(
                          width: 60.0,
                          child: OutlineButton.icon(
                            highlightColor: Colors.amber,
                            splashColor: Colors.amber,
                            highlightedBorderColor: Colors.amber,
                            color: color,
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => AudioApp(song)),
                              );
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25.0)),
                            borderSide: BorderSide(
                              color: color,
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                            icon: Icon(
                              Icons.play_arrow,
                              color: color,
                            ),
                            label: Text(""),
                          ),
                        )
                      : SizedBox(
                          child: OutlineButton.icon(
                            highlightColor: Colors.amber,
                            splashColor: Colors.amber,
                            highlightedBorderColor: Colors.amber,
                            color: color,
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => AudioApp(song)),
                              );
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25.0)),
                            borderSide: BorderSide(
                              color: color,
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                            icon: Icon(
                              Icons.play_arrow,
                              color: color,
                            ),
                            label: Text(
                              "Play",
                              style: TextStyle(
                                color: color,
                              ),
                            ),
                          ),
                        ),
                  Text(
                    song.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
