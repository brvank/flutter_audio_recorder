import 'dart:io';

import 'package:audio_player/uses_permissions.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  Record record = Record();
  bool recording = false;
  bool playing = false;
  AudioPlayer audioPlayer = AudioPlayer();

  late String path, location;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getDirectory();
  }

  Future<void> getDirectory() async {
    if (Platform.isAndroid) {
      Directory? directory = await getTemporaryDirectory();
      if (directory != null) {
        path = directory.path;
        print(path);

        location = path +
            '/audio ' +
            DateTime.now().hour.toString() +
            DateTime.now().microsecond.toString() +
            '.m4a';
      }
    }
  }

  Future<void> startRecording() async {
    bool result = await record.hasPermission();

    if (result) {
      setState(() {
        recording = true;
      });

      await record.start(
        path: location, // required
        encoder: AudioEncoder.AAC, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
    }
  }

  Future<void> stopRecording() async {
    await record.stop();
    recording = false;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Record'),
      ),
      body: audioRecord(),
    );
  }

  Widget audioRecord() {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              //start recording
              if (recording) {
                stopRecording();
              } else {
                startRecording();
              }
            },
            child: !recording ? Text('Start') : Text('Stop')),
        ElevatedButton(onPressed: () {
          if(playing){
            pauseAudio();
          }else{
            playAudio();
          }
        }, child: playing ? Text('Play') : Text('Pause'))
      ],
    );
  }


  Future<void> playAudio() async {
    int result = await audioPlayer.play(location, isLocal: true);
    print(result);
    if(result == 1){
      playing = true;
      setState(() {
        
      });
    }
  }

  Future<void> pauseAudio() async {
    int result = await audioPlayer.pause();
    if(result == 1){
      playing = false;
      setState(() {
        
      });
    }
  }
}