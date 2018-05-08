// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_picker/media_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Image Picker Demo',
      home: new MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> _mediaFile;
  bool isVideo = false;
  VideoPlayerController _controller;
  VoidCallback listener;

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      if (isVideo) {
        _mediaFile = MediaPicker.pickVideo(source: source);
      } else {
        _mediaFile = MediaPicker.pickImage(source: source);
      }
    });
  }

  // void _previewVideo(ImageSource source) async {
  //   _mediaFile = MediaPicker.pickVideo(source: source).then((onFile) {
  //     if (_controller == null) {
  //       _controller = VideoPlayerController.file(onFile)
  //         ..addListener(listener)
  //         ..setVolume(1.0)
  //         ..initialize()
  //         ..setLooping(true)
  //         ..play();
  //     } else {
  //       if (_controller.value.isPlaying) {
  //         _controller.pause();
  //       } else {
  //         _controller.initialize();
  //         _controller.play();
  //       }
  //     }
  //   });
  // }

  @override
  void deactivate() {
    _controller.setVolume(0.0);
    _controller.removeListener(listener);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
    )
      ..addListener(listener)
      ..setVolume(1.0)
      ..initialize()
      ..setLooping(true)
      ..play();
  }

  @override
  Widget build(BuildContext context) {
    Widget _previewImage = new FutureBuilder<File>(
      future: _mediaFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return new Image.file(snapshot.data);
        } else if (snapshot.error != null) {
          return const Text('Error picking image.');
        } else {
          return const Text('You have not yet picked an image.');
        }
      },
    );
    Widget _previewVideo = new FutureBuilder<File>(
      future: _mediaFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
              print("File to Play: " + snapshot.data.toString());
          if (_controller == null) {
            _controller = VideoPlayerController.file(snapshot.data)
              ..addListener(listener)
              ..setVolume(1.0)
              ..initialize()
              ..setLooping(true)
              ..play();
          } else {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.initialize();
              _controller.play();
            }
          }
          return new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new AspectRatio(
              aspectRatio: 1280 / 720,
              child: new VideoPlayer(_controller),
            ),
          );
        } else if (snapshot.error != null) {
          return const Text('Error picking video.');
        } else {
          return const Text('You have not yet picked a video.');
        }
      },
    );
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Media Picker Example'),
      ),
      body: new Center(
        child: isVideo ? _previewVideo : _previewImage,
      ),
      floatingActionButton: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FloatingActionButton(
            onPressed: () {
              isVideo = false;
              _onImageButtonPressed(ImageSource.gallery);
            },
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera);
              },
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }
}
