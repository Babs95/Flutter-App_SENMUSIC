import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SENMUSIC APP',
      theme: new ThemeData(
          primarySwatch: Colors.grey
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }

}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }

}

class _Home extends State<Home> {

  List<Musique> maListeDeMusiques = [
    new Musique('Bang', 'Pnl-Deux Frères', 'images/pnl-deux-freres.png', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('Oh Lala', 'Pnl-Le monde chico', 'images/mondechico.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription; 
  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;
  @override
  void initState(){
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double largeur = MediaQuery.of(context).size.width;
    return new Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: new AppBar(
        title: new Text(
            'SENMUSIC',
            style: new TextStyle(
              color: Colors.white
            ),
        ),
        elevation: 35.0,
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Card(
              elevation: 15.0,
              margin: EdgeInsets.only(top: 14.0),
              child: new Container(
                  width: largeur / 1.5,
                  height: 250.0,
                  child: new Image.asset(
                    maMusiqueActuelle.imagePath,
                    fit: BoxFit.cover,
                  )
              ),
            ),
            new Text(
                maMusiqueActuelle.titre,
              style: new TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                height: 2.0,
              ),
            ),
            new Text(
              maMusiqueActuelle.artiste,
              style: new TextStyle(
                color: Colors.pink,
                fontSize: 20.0,
                height: 2.0,
              ),
            ),
            new Container(
              height: largeur / 6,
              //color: Colors.blue,
              margin: EdgeInsets.only(left: 20.0, right: 20.0,top: 8.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                  button((statut == PlayerState.playing) ?Icons.pause :Icons.play_arrow, 45.0, (statut == PlayerState.playing) ?ActionMusic.pause:ActionMusic.play),
                  button(Icons.fast_forward, 30.0, ActionMusic.forward),
                ],
              ),
            ),
            new Container(
              height: largeur / 6,
              //color: Colors.blue,
              margin: EdgeInsets.only(left: 20.0, right: 20.0,top: 14.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  new Text(
                    fromDuruation(position),
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      height: 2.0,
                    ),
                  ),
                  new Text(
                    fromDuruation(duree),
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      height: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            new Slider(
              activeColor: Colors.pink,
                inactiveColor: Colors.white,
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                onChanged: (double d) {
                  setState(() {
                    /*Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position = nouvelleDuration;*/
                    audioPlayer.seek(d);
                  });
                }),
          ],
        ),
      ),
    );
  }

  IconButton button(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
      iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone), 
        onPressed: () {
          switch(action) {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
            case ActionMusic.forward:
              forward();
              break;
          }
        }
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    },onError: (message) {
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
  if (index == maListeDeMusiques.length - 1) {
    index = 0;
  }else {
    index++;
  }
  maMusiqueActuelle = maListeDeMusiques[index];
  audioPlayer.stop();
  configurationAudioPlayer();
  play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    }else {
      if (index == 0) {
        index = maListeDeMusiques.length - 1;
      } else {
        index--;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuruation(Duration duree) {
    print(duree);
    return duree.toString().split('.').first;
  }
}
enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}
enum PlayerState {
  playing,
  stopped,
  paused
}