import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:breezvideo/consts.dart';
import 'package:breezvideo/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReceivePort _port = ReceivePort();
  var _moment = Moment.INITIAL;
  var _errorMsg = "";
  var _downloadMsg = "";
  var _name = "";
  var _file = "";
  String? _taskId;

  _HomePageState() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_port');
    _port.listen((dynamic data) {
      final id = data[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;

      switch (status.value) {
        case 1: // enqueued
          _downloadMsg = 'Download requested';
          _setMoment(Moment.DOWNLOADING);
          break;
        case 2: // running
          _downloadMsg = 'Downloading $progress%';
          _setMoment(Moment.DOWNLOADING);
          break;
        case 3: // complete
          _downloadMsg = 'Download completed';
          _setMoment(Moment.DONE);
          break;
        case 4: // failed
          _downloadMsg = 'Download failed';
          _setMoment(Moment.DOWNLOADING);
          Future.delayed(Duration(seconds: 3)).then((_) {
            final taskId = _taskId;
            if (taskId != null) {
              FlutterDownloader.retry(taskId: taskId);
            }
          });
          break;
        case 5: // canceled
          _downloadMsg = 'Download canceled';
          _setMoment(Moment.DOWNLOADING);
          break;
        case 6: // paused
          _downloadMsg = 'Download pause';
          _setMoment(Moment.DOWNLOADING);
          break;
        default:
          _downloadMsg = 'Downloading ???';
          _setMoment(Moment.DOWNLOADING);
          break;
      }
    });
    FlutterDownloader.registerCallback(_callback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Breez Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () {
              _setMoment(Moment.INITIAL);
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    switch (_moment) {
      case Moment.INITIAL:
        return _bodyInitial();
      case Moment.STREAMED:
        return _bodyStreamed();
      case Moment.DOWNLOADING:
        return _bodyDownloading();
      case Moment.DONE:
        return _bodyDone();
      case Moment.ERROR:
        return _bodyError();
    }
  }

  Widget _bodyInitial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            child: Text('Start download to play file locally'),
            onPressed: () => _download(),
          ),
        ),
        Center(
          child: ElevatedButton(
            child: Text('Start streamed play'),
            onPressed: () => _streamed(),
          ),
        ),
      ],
    );
  }

  Widget _bodyStreamed() => VideoPlayer(URL);

  Widget _bodyDone() => VideoPlayer(_file);

  Widget _bodyDownloading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(_downloadMsg),
        ),
      ],
    );
  }

  Widget _bodyError() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('Error: $_errorMsg.'),
          ),
        ],
      ),
    );
  }

  void _setMoment(Moment newMoment) {
    setState(() {
      if (mounted) {
        _moment = newMoment;
      }
    });
  }

  void _download() async {
    _name = "a_name_${DateTime.now().millisecondsSinceEpoch}.mp4";
    _downloadMsg = 'Downloading…';
    _setMoment(Moment.DOWNLOADING);

    final dir = await _getStorageDirectory();
    _file = join(dir, _name);
    try {
      _taskId = await FlutterDownloader.enqueue(
        url: URL,
        fileName: _name,
        savedDir: dir,
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (e) {
      _errorMsg = e.toString();
      _setMoment(Moment.ERROR);
    }
  }

  void _streamed() {
    _setMoment(Moment.STREAMED);
  }

  static void _callback(String id, DownloadTaskStatus status, int progress) {
    final send = IsolateNameServer.lookupPortByName('downloader_port');
    send?.send([id, status, progress]);
  }

  Future<String> _getStorageDirectory() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'BreezVideo');
    await Directory(path).create(recursive: true);
    return path;
  }
}

enum Moment {
  INITIAL,
  STREAMED,
  DOWNLOADING,
  DONE,
  ERROR,
}
