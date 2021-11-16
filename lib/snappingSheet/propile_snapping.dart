import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services/auth_repository.dart';
import 'package:hello_me/services/data_base_favorites.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class ProfileSnapping extends StatefulWidget {
  Widget MyOwnPageContent;
  bool firt_time_snap = true;
  bool init_snap_pos = true;
  SnappingPosition InitSnappingPose =
      const SnappingPosition.factor(positionFactor: 0.3);
  final MySnappingSheetController = SnappingSheetController();

  bool blur = false;

  ProfileSnapping(this.MyOwnPageContent, {Key? key}) : super(key: key);

  @override
  _ProfileSnappingState createState() => _ProfileSnappingState();
}

class _ProfileSnappingState extends State<ProfileSnapping> {
  @override
  Widget build(BuildContext context) {
    var controller = StreamController<double>();
    var authRepositoryInst =
        Provider.of<AuthRepository>(context, listen: false);
    return SnappingSheet(
      // Connect it to the SnappingSheet

      controller: widget.MySnappingSheetController,
      lockOverflowDrag: true,
      // (Recommended) Set this to true.
      onSheetMoved: (sheetPosition) {
        try {
          controller.add(widget.MySnappingSheetController.currentPosition);
          if (widget.MySnappingSheetController.currentPosition <= 40 &&
              widget.blur == true) {
            setState(() {
              widget.blur = false;
            });
          }
          if (widget.MySnappingSheetController.currentPosition > 40 &&
              widget.blur == false) {
            //print("current is " + widget.MySnappingSheetController.currentPosition.toString());
            //print("set to blur - " + widget.InitSnappingPose.grabbingContentOffset.toString());
            setState(() {
              widget.blur = true;
            });
          }
        } catch (e) {
          print("controller is attached? - " +
              widget.MySnappingSheetController.isAttached.toString());
        }
        //print("Moved - Current position ${sheetPosition.pixels}");
        //print("Moved - Current position snapping ${widget.MySnappingSheetController.currentPosition}");
        //print(widget.MySnappingSheetController.currentlySnapping);
      },
      onSnapCompleted: (sheetPosition, snappingPosition) {
        //print("Completed - Current position ${sheetPosition.pixels}");
        //print("Current snapping position $snappingPosition");
        //print(widget.MySnappingSheetController.isAttached);
      },

      onSnapStart: (sheetPosition, snappingPosition) {
        if (widget.MySnappingSheetController.isAttached == false) {
          print("controller is attached? - " +
              widget.MySnappingSheetController.isAttached.toString());
          Navigator.pop(context, 'not attached');
        }

        //print("Start - Current position ${sheetPosition.pixels}");
        //print("Next snapping position $snappingPosition");
      },
      child: widget.blur ? buildStack(controller) : widget.MyOwnPageContent,
      // TODO: Add your content here
      grabbingHeight: 75,
      grabbing: GestureDetector(
          onTap: _pushToggle, child: MyOwnGrabbingWidget(authRepositoryInst)),
      //welcome back
      // TODO: Add your grabbing widget here,
      sheetBelow: SnappingSheetContent(
        draggable: true,
        child: MyOwnSheetContent(authRepositoryInst), // avatar below
      ),

      // initialSnappingPosition: init_snap_pos
      //     ? null
      //     : SnappingPosition.factor(positionFactor: 0.3),
    );
    // You can now control the sheet in multiple ways.
  }

  StreamBuilder buildStack(StreamController<double> controller) {
    return StreamBuilder(
        stream: controller.stream,
        builder: (context, snapshot) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              widget.MyOwnPageContent,
              BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: (snapshot.hasData) ? snapshot.data / 80 : 2.0,
                    sigmaY: (snapshot.hasData) ? snapshot.data / 80 : 2.0,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ))
            ],
          );
        });
  }

  void _pushToggle() {
    try {
      if (widget.firt_time_snap) {
        widget.InitSnappingPose =
            widget.MySnappingSheetController.currentSnappingPosition;
        widget.firt_time_snap = false;
      }

      if (widget.init_snap_pos) {
        widget.MySnappingSheetController.snapToPosition(
            const SnappingPosition.factor(positionFactor: 0.3));
      } else {
        widget.MySnappingSheetController.snapToPosition(
            widget.InitSnappingPose);
      }
      widget.init_snap_pos = !widget.init_snap_pos;
    } catch (e) {
      print("controller is attached? - " +
          widget.MySnappingSheetController.isAttached.toString());
      Navigator.pop(context, 'not attached');
    }
  }
}

// class MyOwnPageContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Placeholder();
//   }
// }

class MyOwnGrabbingWidget extends StatelessWidget {
  AuthRepository authRepositoryInst;

  MyOwnGrabbingWidget(this.authRepositoryInst, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            'Welcome back, ${authRepositoryInst.user!.email} ',
            style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 18),
          )),
          Icon(Icons.keyboard_arrow_up_rounded, size: 27),
        ],
      ),
    );
  }
}

class MyOwnSheetContent extends StatefulWidget {
  AuthRepository authRepositoryInst;
  DatabaseServiceFavorites? favoritesDb;
  final ImagePicker _picker = ImagePicker();

  MyOwnSheetContent(this.authRepositoryInst, {Key? key}) : super(key: key) {
    favoritesDb = DatabaseServiceFavorites(uid: authRepositoryInst.user!.uid);
  }

  @override
  _MyOwnSheetContentState createState() => _MyOwnSheetContentState();
}

class _MyOwnSheetContentState extends State<MyOwnSheetContent> {
  SnackBar get imageSelectSnackBar =>
      const SnackBar(content: Text('No image selected'));

  @override
  Widget build(BuildContext context) {
    final Future<String> avatarUrl = widget.favoritesDb!.getUserAvatarUrl();
    return FutureBuilder(
      future: avatarUrl,
      builder: (BuildContext context, AsyncSnapshot<String> _url) {
        if (_url.connectionState == ConnectionState.done && _url.hasData) {
          if (_url.hasError) {
            return const Center(child: Text("Sorry, an error occurred"));
          } else if (_url.hasData) {
            final data = _url.data as String;
            return Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.topLeft,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: CircleAvatar(
                      backgroundImage:
                          data == "no_avatar" ? null : NetworkImage(data),
                      radius: 50,
                    ),
                  ),
                  const SizedBox(width: 30), // give it width
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          width: 250,
                          child: Text(
                            '${widget.authRepositoryInst.user!.email}',
                            style: const TextStyle(
                                fontStyle: FontStyle.normal, fontSize: 25),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 250,
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: TextButton(
                              child: const Text(
                                '   Change avatar   ',
                                style: TextStyle(
                                    fontStyle: FontStyle.normal, fontSize: 18),
                              ),
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                onSurface: Colors.grey,
                              ),
                              onPressed: () async {
                                //Pick an image
                                final XFile? image = await widget._picker
                                    .pickImage(source: ImageSource.gallery);
                                // FilePickerResult? result =
                                //     await FilePicker.platform.pickFiles();

                                if (image != null) {
                                  //results is not null
                                  // File file = File(result.files.single.path!);
                                  String avatarUrl = await widget.favoritesDb!
                                      .uploadFile(image.path);
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    // Do something
                                    //print("new url is " + avatarUrl);
                                    widget.favoritesDb!
                                        .updateAvatarUrl(avatarUrl);
                                    setState(() {});
                                  });
                                } else {
                                  // User canceled the picker
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(imageSelectSnackBar);
                                }
                                // if (image != null) {
                                // } else {
                                //   ScaffoldMessenger.of(context)
                                //       .showSnackBar(imageSelectSnackBar);
                                // }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Sorry, an error occurred"));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
