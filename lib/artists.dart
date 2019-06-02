import 'package:flutter/material.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:baza_music/models/items.dart';
import 'package:baza_music/artist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const Color color = Color(0xFF007e9a);

class ArtistHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ArtistState();
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

class ArtistState extends State<ArtistHome>
    with SingleTickerProviderStateMixin {
  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 50.0,
        child: Container(
            child: Center(
                child: Text(
          headerText,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
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


  Future<List<Artist>> _fetchArtistsFromWeb() async {
    String url = "http://bazaassistant.herokuapp.com/music/artists";
    final response = await http.get(url);

    print(response.body);

    final List jsonData = json.decode(response.body);

    List<Artist> myArtists = createArtistList(jsonData);

    return myArtists;
  }

  List<Artist> createArtistList(List data) {
    List<Artist> finList = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]['name'];
      String image = data[i]['image'];
      String url = data[i]['url'];
      String category = data[i]['category'];

      Artist ar =
          new Artist(name: name, url: url, image: image, category: category);
      finList.add(ar);
    }
    return finList;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Artist>>(
            future: _fetchArtistsFromWeb(),
            builder: (context, snapshot) {
              List<Artist> allData = snapshot.data;

              List<Artist> week = new List();
              List<Artist> recent = new List();
              List<Artist> month = new List();
              List<Artist> times = new List();

              if (allData != null) {
                for (int a = 0; a < allData.length; a++) {
                  Artist ar = allData[a];

                  switch (ar.category) {
                    case 'new':
                      recent.add(ar);
                      break;
                    case 'week':
                      week.add(ar);
                      break;
                    case 'month':
                      month.add(ar);
                      break;
                    default:
                      times.add(ar);
                      break;
                  }
                }
              }

              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    pinned: false,
                    expandedHeight: 160.0,
                    elevation: 2.0,
                    flexibleSpace: FlexibleSpaceBar(
                        background: Stack(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 23.0),
                          child: snapshot.hasData
                              ? GridView.count(
                                  padding: EdgeInsets.all(10.0),
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 5.0,
                                  scrollDirection: Axis.horizontal,
                                  childAspectRatio: 1.0,
                                  children: List.generate(recent.length,
                                      (index) {
                                    return BigCard(false, recent[index]);
                                  }),
                                )
                              :
                              Container(
                                padding: EdgeInsets.all(10.0),
            child: Center(
                child: Text(
          "Loading contents...",
          style: TextStyle(color: Colors.grey),
        ))),
                              ),
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Container(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "New artists",
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.bold),
                              ))),
                    ])),
                  ),
                  makeHeader('Most popular artists'),
                  snapshot.hasData
                              ? SliverGrid(
                    gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
                    delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return BigCard(true, times[index]);
                    }, childCount: times.length),
                  ):makeLoader(),
                  makeHeader('Popular this month.'),
                 snapshot.hasData
                              ?  SliverGrid(
                    gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120.0,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
                    delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return BigCard(false, month[index]);
                    }, childCount: month.length),
                  ):makeLoader(),
                ],
              );
            }));
  }
}

class BigCard extends StatelessWidget {
  final bool isBig;
  final Artist art;
  BigCard(this.isBig, this.art);

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 100,
        width: 100,
        color: Colors.white,
        // decoration: new BoxDecoration(
        //   color: Colors.white,
        //   shape: BoxShape.rectangle,
        //   boxShadow: [
        //     new BoxShadow(
        //         color: Colors.grey[400],
        //         blurRadius: 10.0,
        //         spreadRadius: 2.0,
        //         offset: const Offset(1.0, 1.0))
        //   ],
        //   borderRadius: new BorderRadius.only(
        //       bottomRight: new Radius.circular(7.00),
        //       bottomLeft: new Radius.circular(7.00)),
        // ),
        child: Column(children: <Widget>[
          InkWell(
            splashColor: Colors.lightGreenAccent,
            highlightColor: Colors.amber,
            enableFeedback: true,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ArtistProfile(art.url,art.name,art.image)));
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                art.image,
              ),
              backgroundColor: Colors.grey.shade200,
              maxRadius: isBig ? 60.0 : 40.0,
              minRadius: 20.0,
            ),
          ),
          Text(
            art.name,
            maxLines: 1,
            style: TextStyle(color: Colors.black,  fontWeight: FontWeight.bold,),
          )
        ]));
  }
} 
