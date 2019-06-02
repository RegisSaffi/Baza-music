import 'package:flutter/material.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:baza_music/models/items.dart';
import 'package:baza_music/Artist.dart';

const Color color = Color(0xFF007e9a);

class ChartsHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChartsState();
}

class ChartsState extends State<ChartsHome>
    with SingleTickerProviderStateMixin {

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
                padding: EdgeInsets.only(top: 23.0),
                child: Container()
              ),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                  child: Container(
                    alignment: Alignment.topCenter,
                      child: Text(
                "Recently added artists",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ))),
            ])),
          ),
         
          SliverGrid(
            gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120.0,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 4.0
            ),
            delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return new Container(
                color: Colors.blueAccent,
              );
            }, childCount: 40),
          ),
     
        ],
      ),
    );
}

