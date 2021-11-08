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
    final media = MediaQuery.of(context);

    final size = media.size;
    final statusBar = media.padding.top != 0.0 ? media.padding.top : 24.0;
    final appbarSize = AppBar().preferredSize.height;

    final maxWidth = size.width;
    final maxHeight = size.height - statusBar - appbarSize;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Video(
                    autoPlay: true,
                    showControls: false,
                    title: "A title",
                    subtitle: "A subtitle",
                    isLiveStream: false,
                    position: 0,
                    url: widget._videoUri,
                    loop: false,
                    desiredState: _desiredState,
                    onViewCreated: (_) {},
                  ),
                  Column(
                    children: [
                      Expanded(child: Container()),
                      Container(
                        color: Colors.black.withAlpha(100),
                        child: Row(
                          children: [
                            Container(width: 8.0),
                            Expanded(child: Container()),
                            IconButton(
                              iconSize: 48.0,
                              color: Colors.white,
                              onPressed: () => _backward(),
                              icon: Icon(Icons.replay_30),
                            ),
                            Container(width: 8.0),
                            IconButton(
                              iconSize: 48.0,
                              color: Colors.white,
                              onPressed: () => _toggle(),
                              icon: Icon(
                                _desiredState == PlayerState.PLAYING
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                              ),
                            ),
                            Container(width: 8.0),
                            IconButton(
                              iconSize: 48.0,
                              color: Colors.white,
                              onPressed: () => _forward(),
                              icon: Icon(Icons.forward_30),
                            ),
                            Expanded(child: Container()),
                            Container(width: 8.0),
                          ],
                        ),
                      ),
                      Container(width: 8.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle() {
    if (_desiredState == PlayerState.PLAYING) {
      _changeState(PlayerState.PAUSED);
    } else {
      _changeState(PlayerState.PLAYING);
    }
  }

  void _backward() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("TODO backward"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _forward() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("TODO forward"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _changeState(PlayerState desiredState) {
    if (mounted) {
      setState(() {
        _desiredState = desiredState;
      });
    }
  }
}
