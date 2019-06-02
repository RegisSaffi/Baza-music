import 'package:meta/meta.dart';
import 'dart:convert';

class Song {

  String category;
  String image;
  String name;
  String artist;
  String url;
  bool isFavorite;

  Song({

    @required this.category,
    @required this.image,
    @required this.name,
    @required this.artist,
    @required this.url,
    this.isFavorite,
  
});
}

class Artist {

  String category;
  String name;
  String url;
  String image;

  Artist({
    this.category,
    @required this.name,
    @required this.url,
    this.image,

  });
}




