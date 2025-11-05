import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:studytest/screenshot_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;
  List<String> screenshotPaths = [];

  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );
    log("$res: OVERLAY");
    _receivePort.listen((message) async {
      log("message from OVERLAY: $message");

      // 커맨드 처리
      if (message == 'COMMAND:TAKE_SCREENSHOT') {
        final path = await ScreenshotService.takeScreenshot();
        setState(() {
          if (path != null) {
            screenshotPaths.add(path);
            latestMessageFromOverlay = 'Screenshot saved!\n$path';
          } else {
            latestMessageFromOverlay = 'Screenshot failed!';
          }
        });

        // 결과를 오버레이로 다시 전송
        homePort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
        homePort?.send(latestMessageFromOverlay);
      } else if (message == 'COMMAND:START_AUTO_SCROLL') {
        setState(() {
          latestMessageFromOverlay = 'Starting auto scroll...';
        });

        final paths = await ScreenshotService.startAutoScroll();
        setState(() {
          screenshotPaths.addAll(paths);
          latestMessageFromOverlay = 'Auto scroll done!\n${paths.length} screenshots';
        });

        // 결과를 오버레이로 다시 전송
        homePort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
        homePort?.send('Auto scroll completed: ${paths.length} screenshots');
      } else {
        setState(() {
          latestMessageFromOverlay = 'Latest Message From Overlay: $message';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isPermissionGranted();
                log("Is Permission Granted: $status");
              },
              child: const Text("Check Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                log("status: $res");
              },
              child: const Text("Request Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await FlutterOverlayWindow.showOverlay(
                  enableDrag: false,
                  overlayTitle: "Screenshot Overlay",
                  overlayContent: 'Overlay Enabled',
                  flag: OverlayFlag.focusPointer,
                  visibility: NotificationVisibility.visibilityPublic,
                  positionGravity: PositionGravity.none,
                  height: 300,
                  width: WindowSize.matchParent,
                  startPosition: const OverlayPosition(0, 100),
                );
              },
              child: const Text("Show Overlay"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isActive();
                log("Is Active?: $status");
              },
              child: const Text("Is Active?"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await FlutterOverlayWindow.resizeOverlay(
                  WindowSize.matchParent,
                  (MediaQuery.of(context).size.height * 5).toInt(),
                  false,
                );
              },
              child: const Text("Update Overlay"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                log('Try to close');
                FlutterOverlayWindow.closeOverlay()
                    .then((value) => log('STOPPED: alue: $value'));
              },
              child: const Text("Close Overlay"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                homePort ??=
                    IsolateNameServer.lookupPortByName(_kPortNameOverlay);
                homePort?.send('Send to overlay: ${DateTime.now()}');
              },
              child: const Text("Send message to overlay"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                FlutterOverlayWindow.getOverlayPosition().then((value) {
                  log('Overlay Position: $value');
                  setState(() {
                    latestMessageFromOverlay = 'Overlay Position: $value';
                  });
                });
              },
              child: const Text("Get overlay position"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                FlutterOverlayWindow.moveOverlay(
                  const OverlayPosition(0, 0),
                );
              },
              child: const Text("Move overlay position to (0, 0)"),
            ),
            const SizedBox(height: 20),
            Text(latestMessageFromOverlay ?? ''),
            const Divider(height: 40, thickness: 2),
            const Text('스크린샷 기능 테스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final hasPermission = await ScreenshotService.hasPermission();
                log('Has Screenshot Permission: $hasPermission');
                setState(() {
                  latestMessageFromOverlay = 'Has Permission: $hasPermission';
                });
              },
              child: const Text("Check Screenshot Permission"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final result = await ScreenshotService.requestPermission();
                log('Screenshot Permission Result: $result');
                setState(() {
                  latestMessageFromOverlay = 'Permission Result: $result';
                });
              },
              child: const Text("Request Screenshot Permission"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final path = await ScreenshotService.takeScreenshot();
                log('Screenshot saved to: $path');
                if (path != null) {
                  final file = File(path);
                  if (await file.exists()) {
                    setState(() {
                      screenshotPaths.add(path);
                      latestMessageFromOverlay = 'Screenshot saved!\n$path';
                    });
                  }
                } else {
                  setState(() {
                    latestMessageFromOverlay = 'Screenshot failed!';
                  });
                }
              },
              child: const Text("Take Screenshot"),
            ),
            const Divider(height: 40, thickness: 2),
            const Text('자동 스크롤 기능 테스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final hasPermission = await ScreenshotService.checkAccessibilityPermission();
                log('Has Accessibility Permission: $hasPermission');
                setState(() {
                  latestMessageFromOverlay = 'Accessibility: $hasPermission';
                });
              },
              child: const Text("Check Accessibility Permission"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await ScreenshotService.requestAccessibilityPermission();
                log('Opening accessibility settings...');
                setState(() {
                  latestMessageFromOverlay = 'Please enable AutoScrollService in Accessibility settings';
                });
              },
              child: const Text("Request Accessibility Permission"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                setState(() {
                  latestMessageFromOverlay = 'Starting auto scroll...';
                });

                final paths = await ScreenshotService.startAutoScroll();
                log('Auto scroll completed. Total: ${paths.length} screenshots');

                setState(() {
                  screenshotPaths.addAll(paths);
                  latestMessageFromOverlay = 'Auto scroll done!\n${paths.length} screenshots saved\n${paths.isNotEmpty ? paths.first : ''}';
                });
              },
              child: const Text("Start Auto Scroll + Screenshots"),
            ),
            const SizedBox(height: 20),
            const Divider(height: 40, thickness: 2),
            const Text('찍힌 사진 갤러리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('총 ${screenshotPaths.length}장의 스크린샷', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  screenshotPaths.clear();
                  latestMessageFromOverlay = 'All screenshots cleared from gallery';
                });
              },
              child: const Text("Clear Gallery", style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 10),
            if (screenshotPaths.isNotEmpty)
              Container(
                height: 400,
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: screenshotPaths.length,
                  itemBuilder: (context, index) {
                    final path = screenshotPaths[index];
                    return GestureDetector(
                      onTap: () {
                        // 전체화면으로 보기
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Close"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            screenshotPaths.removeAt(index);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('아직 찍힌 사진이 없습니다', style: TextStyle(color: Colors.grey)),
              ),
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}