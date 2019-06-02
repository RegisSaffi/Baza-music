import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baza_music/models/items.dart';
import 'package:baza_music/utils/waves.dart';
import 'package:baza_music/utils/zigzag.dart';

typedef void OnError(Exception exception);

const Color color = Color(0xFF007e9a);
const Color mainColor = Color(0xFF1f1f54);

enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  String songDataAddress;
  static String songUrl;
  String songImage;
  String artist;
  String category;
  String name;

  AudioApp(Song sng) {
    this.songDataAddress = sng.url;
    this.songImage = sng.image;
    this.artist = sng.artist;
    this.name = sng.name;
    category = sng.category;
    songUrl = "none";
  }

  @override
  _AudioAppState createState() => new _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  String newSongUrl = AudioApp.songUrl;

  Duration duration;
  Duration position;
  AudioPlayer audioPlayer;
  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    _fetchSongDataFromWeb();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(newSongUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    final bytes = await _loadFileBytes(newSongUrl,
        onError: (Exception exception) =>
            print('_loadFile => exception $exception'));

    final dir = await getApplicationDocumentsDirectory();
    final file = new File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
      });
  }

/////////////////////////////////////////// data related part //////////////////////////////
  List<Song> songs;
  int currentPosition = 0;
  String songImageUrl='none';

// Future<List<Song>> _fetchData() {
//   return this._memoizer.runOnce(() async {
//     await Future.delayed(Duration(seconds: 2));
//     return 'REMOTE DATA';
//   });
// }

  _fetchSongDataFromWeb() async {
    String url = widget.songDataAddress;
    String fullUrl =
        "http://bazaassistant.herokuapp.com/music/song_data?song_url=" + url;

    final response = await http.get(fullUrl);

    print(
        "--------------------------     song   data fetched from internet          ----------------------------");
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      List<Song> mySongs = createSongsList(jsonData["songs"]);

      setState(() {
        songs = mySongs;
        newSongUrl = jsonData["song"];
        songImageUrl=jsonData["artist_image"];
      });
    } else {
      setState(() {
        newSongUrl = "error";
        songs = null;
      });
    }
  }

  List<Song> createSongsList(List data) {
    List<Song> finList = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]['name'];
      String artist = widget.artist;
      String image = data[i]['image'];
      String url = data[i]['url'];
      String category = widget.category;

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

  _next(int pos) {
    setState(() {
      newSongUrl = "none";
      songs = new List();
      _fetchSongDataFromWeb();
    });
  }

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    Size size = new Size(MediaQuery.of(context).size.width, 80.0);

    Widget _buildWave(int x, int y, int secs) {
      return Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: new Opacity(
            opacity: 0.2,
            child: new DemoBody(
              size: size,
              xOffset: x,
              yOffset: y,
              color: color,
              secs: secs,
            ),
          ));
    }

    Widget createClippedWidget() {
      return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(children: <Widget>[
              ZigZag(
                  clipType: ClipType.arc,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset(
                        "images/placeholder.png",
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.srcOver,
                        color: new Color.fromARGB(120, 20, 10, 40),
                      ),
                      Image.network( 
                        songImageUrl=="none"?widget.songImage:songImageUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.srcOver,
                        color: new Color.fromARGB(120, 20, 10, 40),
                      ),
                    ],
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    splashColor: color,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  padding: EdgeInsets.only(top: 20.0, left: 5.0),
                ),
              ),
            ]),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  widget.artist,
                  style: TextStyle(fontSize: 22, color: color),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      );
    }

    return new Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 10.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              createClippedWidget(),
              new Stack(
                children: <Widget>[
                  Column(mainAxisSize: MainAxisSize.max, children: [
                    new Row(mainAxisSize: MainAxisSize.min, children: [
                      new IconButton(
                          onPressed: () {},
                          iconSize: 30.0,
                          icon: new Icon(Icons.playlist_play),
                          color: color),
                      new Padding(
                          padding: new EdgeInsets.all(5.0),
                          child:
                              new Stack(alignment: Alignment.center, children: [
                            new SizedBox(
                              height: 150.0,
                              width: 150.0,
                              child: new CircularProgressIndicator(
                                  value: 1.0,
                                  valueColor: new AlwaysStoppedAnimation(
                                      Colors.grey[300])),
                            ),
                            new SizedBox(
                              height: 150.0,
                              width: 150.0,
                              child: new CircularProgressIndicator(
                                value: position != null &&
                                        position.inMilliseconds > 0
                                    ? (position?.inMilliseconds?.toDouble() ??
                                            0.0) /
                                        (duration?.inMilliseconds?.toDouble() ??
                                            0.0)
                                    : 0.0,
                                valueColor: new AlwaysStoppedAnimation(color),
                                backgroundColor: Colors.yellow,
                              ),
                            ),
                            Container(
                              height: 145.0,
                              width: 145.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          widget.songImage))),
                            ),
                            songs == null
                                ? newSongUrl == "none"
                                    ? new SizedBox(
                                        height: 150.0,
                                        width: 150.0,
                                        child: new CircularProgressIndicator())
                                    : new SizedBox(
                                        height: 150.0,
                                        width: 150.0,
                                        child: new CircularProgressIndicator(
                                          value: 1.0,
                                          valueColor:
                                              new AlwaysStoppedAnimation(
                                                  Colors.red),
                                        ))
                                : Container(),
                          ])),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        iconSize: 30.0,
                      ),
                    ]),
                    new Text(
                        position != null
                            ? "${positionText ?? ''} / ${durationText ?? ''}"
                            : duration != null ? durationText : '',
                        style: new TextStyle(fontSize: 12.0)),
                    new Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: new Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            isPlaying ? Container() : _buildWave(0, 0, 100),
                            isPlaying ? Container() : _buildWave(9, 27, 110),
                            isPlaying ? Container() : _buildWave(33, 6, 120),
                            isPlaying ? _buildWave(0, 0, 1) : Container(),
                            isPlaying ? _buildWave(13, 17, 2) : Container(),
                            isPlaying ? _buildWave(33, 6, 3) : Container(),
                            Container(
                              margin: EdgeInsets.only(bottom: 0),
                              child: duration == null
                                  ? new Container()
                                  : new Slider(
                                      value: position?.inMilliseconds
                                              ?.toDouble() ??
                                          0.0,
                                      onChanged: (double value) => audioPlayer
                                          .seek((value / 1000).roundToDouble()),
                                      min: 0.0,
                                      max: duration.inMilliseconds.toDouble(),
                                    ),
                            )
                          ]),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new IconButton(
                              onPressed: () {},
                              iconSize: 30.0,
                              icon: new Icon(Icons.skip_previous),
                              color: color),
                          newSongUrl == "none"
                              ? new SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: new CircularProgressIndicator(strokeWidth: 1.0,))
                              : newSongUrl == "error"? 
                              new SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: new CircularProgressIndicator(strokeWidth: 1.0, valueColor: AlwaysStoppedAnimation(Colors.red),))
                              
                              :new FloatingActionButton(
                                  onPressed: () {
                                    isPlaying ? pause() : play();
                                  },
                                  backgroundColor: color,
                                  child: Icon(isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                ),
                          new IconButton(
                              onPressed: () {},
                              iconSize: 30.0,
                              icon: new Icon(Icons.skip_next),
                              color: color),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ]),
      ),
    );
  }
}

// class RoundedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         new SizedBox.fromSize(
//           size: preferredSize,
//           child: new LayoutBuilder(builder: (context, constraint) {
//             final width = constraint.maxWidth * 1.3;
//             return new ClipRect(
//               child: new OverflowBox(
//                 maxHeight: double.infinity,
//                 maxWidth: double.infinity,
//                 child: Stack(
//                   children: <Widget>[
//                     new SizedBox(
//                       width: width,
//                       height: width,
//                       child: new Padding(
//                         padding: new EdgeInsets.only(
//                             bottom: width / 2 - preferredSize.height / 3),
//                         child: new DecoratedBox(
//                           decoration: new BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,

//                             image: new DecorationImage(
//                               colorFilter: ColorFilter.mode(
//                                   Colors.grey, BlendMode.dstATop),
//                               image: new CachedNetworkImageProvider(
//                                   "http://www.eachamps.rw/images/artists/fc221309746013ac554571fbd180e1c8.jpg"),
//                               fit: BoxFit.cover,
//                             ),

//                             // boxShadow: [
//                             //   new BoxShadow(color: Colors.black54, blurRadius: 10.0)
//                             // ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         )
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(250.0);
// }
