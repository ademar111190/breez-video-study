import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_playout/player_state.dart';
import 'package:flutter_playout/video.dart';

class VideoPlayer extends StatefulWidget {
  final String _videoUri;

  const VideoPlayer(
    this._videoUri, {
    Key? key,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  var _desiredState = PlayerState.PLAYING;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(
              autoPlay: true,
              showControls: false,
              title: "A title",
              subtitle: "A subtitle",
              isLiveStream: false,
              position: 0,
              url: widget._videoUri,
              loop: false,
              desiredState: _desiredState,
            ),
          ),
          Row(
            children: [
              Container(width: 8.0),
              ElevatedButton(
                child: Text(
                  _desiredState == PlayerState.PLAYING ? 'Pause' : 'Play',
                ),
                onPressed: () => _toogle(),
              ),
              Expanded(child: Container()),
              Container(width: 8.0),
            ],
          ),
        ],
      ),
    );
  }

  void _toogle() {
    if (_desiredState == PlayerState.PLAYING) {
      _changeState(PlayerState.PAUSED);
    } else {
      _changeState(PlayerState.PLAYING);
    }
  }

  void _changeState(PlayerState desiredState) {
    if (mounted) {
      setState(() {
        _desiredState = desiredState;
      });
    }
  }
}
