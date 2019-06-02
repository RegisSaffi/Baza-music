import 'package:flutter/material.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:baza_music/models/items.dart';
import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

const Color color = Color(0xFF007e9a);

class ArtistProfile extends StatefulWidget {

String artistUrl;
String artistName;
String artistImage;

ArtistProfile(this.artistUrl,this.artistName,this.artistImage);

  @override
  State<StatefulWidget> createState() => ArtistProfileState();

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

class ArtistProfileState extends State<ArtistProfile> with SingleTickerProviderStateMixin {
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
  void initState(){
    super.initState();
    _fetchArtistDataFromWeb();
  }

 _showDialog(){
    showDialog(context: context,
    builder: (BuildContext context){

      return AlertDialog(
        title: SingleChildScrollView( child: Text(widget.artistName+" Biography")),
        content: Text(biography),
        actions: <Widget>[
          new FlatButton(
            child: Text("Dismiss"),
            onPressed: ()=>Navigator.pop(context)
          )
        ],
      );
    }
    
    );
  }


String biography;
List<Song> songs;
bool isFavorite=false;

 _fetchArtistDataFromWeb() async {
    String url = widget.artistUrl;
    String fullUrl =
        "http://bazaassistant.herokuapp.com/music/artist_data?artist_url=" + url;

    final response = await http.get(fullUrl);

    print(
        "--------------------------     artist   data fetched from internet          ----------------------------");
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      List<Song> mySongs = createSongsList(jsonData["songs"]);

      setState(() {
        songs = mySongs;
        biography = jsonData["biography"];
      });
    } else {
      setState(() {
        biography = "error";
        songs = null;
      });
    }
  }

  List<Song> createSongsList(List data) {
    List<Song> finList = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]['name'];
      String artist = widget.artistName;
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
    // TODO: implement build

    double _imageHeight=250.0;



    Widget _buildProfileRow() {
   return new Positioned(
      top: _imageHeight - 36.0,
    child: Padding(padding: EdgeInsets.all(10.0),
    child: new Row(
      children: <Widget>[
        new CircleAvatar(
          backgroundColor: Colors.grey,
          minRadius: 30.0,
          maxRadius: 30.0,
          backgroundImage: new CachedNetworkImageProvider(widget.artistImage),
        ),
        new Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               new Text(
                'Artist',
                style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w300),
              ),
              new Text(
                widget.artistName,
                style: new TextStyle(
                    fontSize: 26.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
             
            ],
          ),
        ),
      ],
    ),
    ),
  );
}

Widget _buildIamge() {
  return new ClipPath(
    clipper: new DialogonalClipper(),
    child: new Image.asset(
        'images/icon.png',
        fit: BoxFit.cover,
        height: _imageHeight,
        width: double.infinity,
        colorBlendMode: BlendMode.srcOver,
  color: new Color.fromARGB(120, 20, 10, 40),
    ),
  );
}


  Widget _buildFab() {
    return new Positioned(
      top: _imageHeight - 36.0,
      right: 10.0,
      child: new FloatingActionButton(
        onPressed:(){

            setState(() {
             isFavorite=!isFavorite; 
            });

        },
        backgroundColor: color,
        child: new Icon(isFavorite? Icons.favorite:Icons.favorite_border),
      ),
    );
  }

   Widget _buildBioIcon() {
    return new Positioned(
      top: 23.0,
      right: 5.0,
      child: new IconButton(
        onPressed:()=>_showDialog(),
       icon:new Icon(Icons.textsms,color: Colors.white,),
      ),
    );
  }


    return new Scaffold(
      backgroundColor: Colors.white,
      body:  CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: false,
            expandedHeight: 280.0,
            elevation: 2.0,
            flexibleSpace: FlexibleSpaceBar(
              background: new Stack(
  children: <Widget>[
    _buildIamge(),
    _buildBioIcon(),
    _buildFab(),
    _buildProfileRow(),


  ],
),
            ),
          ),
        makeHeader('Artist songs'),
       songs==null? makeLoader():  SliverGrid(
          gridDelegate: 
              new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120.0,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            
         
          ),
          delegate:new SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return new
            MyCard(true,songs[index]);
            
            },childCount: songs.length),
        
        ),
       
      ],
      ),
    );


     
  }
}

class MyCard extends StatelessWidget {
  bool small;
  Song song;

  MyCard(this.small,this.song);

   @override
  Widget build(BuildContext context) => Card(
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





class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height - 60.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}