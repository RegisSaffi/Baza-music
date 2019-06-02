import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baza_music/models/items.dart';
import 'package:baza_music/player.dart';

//List<Song> songsList =new List();

final Widget placeholder = new Container(color: Colors.grey);

class CarouselWithIndicator extends StatefulWidget {
  final List<Song> songsList;
  CarouselWithIndicator(this.songsList);

  //CarouselWithIndicator({Key key,this.songsList}):super(Key:key);

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

/////////////// print(body:"regis");//////////////////////////////////////////
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

//////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    getChild(List<Song> lst) {
      List child = map<Widget>(widget.songsList, (index, i) {
        return InkWell(
            onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                              AudioApp(widget.songsList[index])));
            },
            child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: widget.songsList[index].image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(200, 0, 0, 0),
                                    Color.fromARGB(0, 0, 0, 0)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      widget.songsList != null
                                          ? widget.songsList[index].artist
                                          : "...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      //'No. $index image',
                                      widget.songsList != null
                                          ? widget.songsList[index].name
                                          : "Loading...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ))),
                      ],
                    ))));
      }).toList();

      return child;
    }

    return Stack(children: <Widget>[
      CarouselSlider(
        items: getChild(widget.songsList),
        pauseAutoPlayOnTouch: Duration(milliseconds: 1000),
        autoPlay: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        autoPlayInterval: Duration(milliseconds: 5000),
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        autoPlayCurve: ElasticInOutCurve(),
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
      ),
      Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: map<Widget>(widget.songsList, (index, url) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 126, 154, 0.9)
                        : Color.fromRGBO(0, 126, 154, 0.4)),
              );
            }),
          ))
    ]);
  }
}
