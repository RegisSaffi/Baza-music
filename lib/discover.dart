import 'package:flutter/material.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:baza_music/models/items.dart';
import 'package:baza_music/artist.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

const Color color = Color(0xFF007e9a);

class DiscoverHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DiscoverState();
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
      BuildContext context, 
      double shrinkOffset, 
      bool overlapsContent) 
  {
    return new SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }

 
}

class DiscoverState extends State<DiscoverHome>
    with SingleTickerProviderStateMixin {

SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: 30.0,
        maxHeight: 30.0,
        child: Container(
          color: Colors.transparent,
             child: Center(child:
                Text(headerText,style: TextStyle(color: color,fontWeight: FontWeight.bold),))),
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

  @override
  void initState() {
    super.initState();

    _grabAllArtists();
  }

  List<Artist> artists;

  _grabAllArtists() async {
    String url = "http://bazaassistant.herokuapp.com/music/all_artists";

    final response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      List<Artist> myArtists = createArtistList(jsonData);

      setState(() {
        artists = myArtists;
      });
    } else {
      setState(() {
        artists = null;
      });
    }
  }

  List<Artist> createArtistList(List data) {
    List<Artist> finList = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]['name'];
      //String image = data[i]['image'];
      String url = data[i]['url'];
      String category = data[i]['category'];

      Artist ar =
          new Artist(name: name, url: url, image: "image", category: category);
      finList.add(ar);
    }
    return finList;
  }


  

  @override
  Widget build(BuildContext context) => new Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: false,
              expandedHeight: 160.0,
              elevation: 2.0,
              flexibleSpace: FlexibleSpaceBar(
                  background: Stack(children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 23.0), child: Container()),
                Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Discover all artists",
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold),
                        ))),
              ])),
            ),
            artists == null
                ? makeLoader()
                : SliverGrid(
                    gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 120.0,
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                        childAspectRatio: 4.0),
                    delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return new MyChip(artists[index]);
                    }, childCount: artists.length),
                  ),
          ],
        ),
      );
}

class MyChip extends StatelessWidget {
  final Artist art;
  MyChip(this.art);

  @override
  Widget build(BuildContext context) => Container(
  
        alignment: Alignment.center,
        child:RawChip(
          label: Text(art.name), 
          avatar: new CircleAvatar(
            backgroundImage: AssetImage("images/avatar.png"),
            backgroundColor: Colors.grey,
          
          ),
          showCheckmark: true,
          tooltip: art.name,
          selectedColor: color,
          labelStyle: TextStyle(
            color: color
          ),
         pressElevation: 7.0,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onPressed: () {

            Navigator.push(context, new MaterialPageRoute(builder: (context)=>ArtistProfile(art.url,art.name,art.image),));
          },
          
        ),
      );
}
