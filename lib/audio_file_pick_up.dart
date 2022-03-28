import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AudioFilePickUpUI extends StatefulWidget {
  const AudioFilePickUpUI({Key? key}) : super(key: key);

  @override
  _AudioFilePickUpUIState createState() => _AudioFilePickUpUIState();
}

class _AudioFilePickUpUIState extends State<AudioFilePickUpUI> with WidgetsBindingObserver{

  late AudioPlayer audioPlayer;
  late List<String> audios;
  late bool playing;
  bool loading = false;
  int duration = 0;
  int played = 0;
  double audioPlayed = 0;
  Uint8List uint8list = Uint8List.fromList([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initializeVariables();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      // pause();
    }
    if(state == AppLifecycleState.resumed){
      print('resumed');
    }
  }

  void initializeVariables(){
    audioPlayer = AudioPlayer();
    audios = <String>[];
    playing = false;

    audioPlayer.onPlayerStateChanged.listen(playStateChanged);
    audioPlayer.onPlayerError.listen(playError);
    audioPlayer.onDurationChanged.listen(durationChanged);
    audioPlayer.onAudioPositionChanged.listen(positionChanged);
  }

  void durationChanged(Duration time){
    duration = time.inSeconds;
    setState(() {

    });
  }

  void positionChanged(Duration time){
    played = time.inSeconds;
    setState(() {
      audioPlayed = (played/duration);
    });
  }

  void playError(String event){
    print('error');
    print(event);
    if(audioPlayer.state == PlayerState.PLAYING){
      pause();
    }
    played = 0;
    duration = 0;
    audioPlayed = 0;
    setState(() {
      playing = false;
    });
  }

  void playStateChanged(PlayerState state){
    print('state changed');
    print(state.toString());
  }

  Future<void> play(String audio) async {
    setState(() {
      loading = true;
    });
    int result = 0;
    if(played > 0){
      result = await audioPlayer.resume();
      if(result == 1){
        playing = true;
        setState(() {

        });
      }
    }else{
      if(Platform.isAndroid || Platform.isIOS){
        try{
          if(uint8list.isEmpty){
            String temp = 'http://demo.jarvis.live/media/poi_auth_audios/145/0b6238d05e294b4480dc9403f1916933.mp3';
            String temp2 = 'http://demo.jarvis.live/media/poi_auth_audios/125/d462f49c13ef4882b0b0668fb874cfbc.mp3';
            String temp3 = 'http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3';
            var url = Uri.parse(temp3);
            var response = await http.get(url);
            uint8list = response.bodyBytes;
          }

          result = await audioPlayer.playBytes(uint8list);
        }catch(e){
          print('exception caught');
          print(e.toString());
        }
      }else{
        List<int> list = audio.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);
        result = await audioPlayer.playBytes(bytes);
      }
      if(result == 1){
        playing = true;
        setState(() {

        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> pause() async {
    var result = await audioPlayer.pause();
    if(result == 1){
      playing = false;
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    releaseAudioPlayer();
    super.dispose();
  }

  Future<void> releaseAudioPlayer() async {
    await audioPlayer.stop();
    await audioPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Audio Files'),),
      body: Audios(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.audiotrack
        ),
        onPressed: (){
          PickFiles();
        },
      ),
    );
  }

  Widget Audios(){
    return ListView.builder(
      itemCount: audios.length,
      itemBuilder: (context, i){
        return AudioTile(i);
      },
    );
  }

  Widget AudioTile(int i){
    return ListTile(
      leading: Icon(
        Icons.music_video,
        color: Colors.red,
      ),
      title: loading?Center(child: CircularProgressIndicator(),):LinearProgressIndicator(value: audioPlayed,),
      trailing: loading?Icon(
        CupertinoIcons.ellipsis,
      ):playing?Icon(
            Icons.pause
        ):Icon(Icons.play_arrow),
      onTap: () async {
        if(audioPlayer.state == PlayerState.PLAYING){
          await pause();
        }else{
          await play(audios[i]);
        }
        // AudioPlayerDialog(audios[i]);
      },
    );
  }

  Future<void> PickFiles() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if(result != null){
      print(result.toString());
      if(result.files[0].bytes != null){
        print(result.files[0].bytes);
        audios.add(String.fromCharCodes(result.files[0].bytes!));
      }else if(result.files[0].path != null){
        print(result.files[0].path);
        audios.add(result.files[0].path!);
      }
      setState(() {

      });
    }
  }

  Future<void> AudioPlayerDialog(String url) async {
    await showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Container(
          color: Colors.greenAccent,
          width: MediaQuery.of(context).size.width/2,
          height: MediaQuery.of(context).size.height/5,
          child: loading?Center(
            child: Text(url),
          ):Text(played.toString()),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
    if(audioPlayer.state == PlayerState.PLAYING){
      audioPlayer.pause();
    }
  }
}
