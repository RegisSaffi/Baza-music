import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:baza_music/player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home.dart';
import 'artists.dart';
import 'discover.dart';
import 'charts.dart';
import 'package:baza_music/utils/bottomBar.dart';

const Color color = Color(0xFF007e9a);

void main() {
  runApp(new MaterialApp(
      // Title
      title: "Baza music",
      theme: new ThemeData(
        primaryColor: color,
        accentColor: color,
        primaryColorBrightness: Brightness.dark,
      ),
      // Home
      home: new Splash()));
}


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        SplashScreen(
          seconds: 5,
         loadingText: Text("Baza music",
          style: TextStyle(color: color,
          fontSize: 19.0,
          fontWeight: FontWeight.bold),),
          
          navigateAfterSeconds: new MyHome(),

          title: new Text(
            '',
            style: new TextStyle(
                fontSize: 17.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey),
          ),
          imageBackground: AssetImage("images/background.png"),
          image: null,

          backgroundColor: Colors.white,

          //imageBackground:AssetImage("images/background.jpg"),

          styleTextUnderTheLoader: new TextStyle(color: color),

          photoSize: 100.0,

          onClick: () => print("Flutter is cool"),
          loaderColor: Colors.white,
        ),

        // Container(
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [
        //           const Color(0xcc000000),
        //           const Color(0x00000000),
        //           const Color(0x00000000),
        //           const Color(0xcc000000),
        //         ]),
        //   ),
        //)
      ],
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyHomeState();
  }
}

class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {



  
  int _lastSelected = 0;

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

Widget myWid;
switch (_lastSelected) {
  case 0:
    myWid=HomeHome();
    break;
    case 1:
    myWid=ChartsHome();
    break;
  case 2:
    myWid=ArtistHome();
    break;
  case 3:
    myWid=DiscoverHome();
    break;
  default:
    myWid=HomeHome();
}
  return Scaffold(
extendBody: true,
    resizeToAvoidBottomInset: true,
    backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: color,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    title: Text("Baza Music",
    style: TextStyle(
      color: Colors.white,
      fontSize: 22.0,
      fontWeight: FontWeight.bold
      ),
      ),

       actions: <Widget>[
          // action button
           IconButton(
            icon: Icon(Icons.more_horiz),
            splashColor: Colors.white,
            onPressed: () {
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            splashColor: Colors.white,
            onPressed: () {

            },
          ),
       ],
          
  ),
body: Center(
        child:
          
          myWid,
           
      ),
      bottomNavigationBar: FABBottomAppBar(
        backgroundColor: color,
        centerItemText: '',
        color: Colors.white,
        selectedColor: Colors.amber,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.music_note, text: 'Music'),
          FABBottomAppBarItem(iconData: Icons.show_chart,text: 'Charts'),
          FABBottomAppBarItem(iconData: Icons.person_outline, text: 'Artists'),
          FABBottomAppBarItem(iconData: Icons.youtube_searched_for, text: 'Discover'),
        ],
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>ArtistHome()),);

        },
        tooltip: 'Favorites',
        child: Icon(Icons.favorite),
        elevation: 2.0,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

