import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';




class ProfileSnapping extends StatelessWidget {
  Widget MyOwnPageContent;
  bool firt_time_snap=true;
  bool init_snap_pos = true;
  SnappingPosition InitSnappingPose =
  const SnappingPosition.factor(positionFactor: 0.3);
  final MySnappingSheetController = SnappingSheetController();

  ProfileSnapping(this.MyOwnPageContent, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var authRepositoryInst =
    Provider.of<AuthRepository>(context, listen: false);

    return SnappingSheet(

          child: MyOwnPageContent,
          // TODO: Add your content here
          grabbingHeight: 75,
          grabbing: InkWell(
              onTap: _pushToggle,
              child: MyOwnGrabbingWidget(authRepositoryInst)),
          //welcome back
          // TODO: Add your grabbing widget here,
          sheetBelow: SnappingSheetContent(
            draggable: true,
            child: MyOwnSheetContent(authRepositoryInst), // avatar below
          ),
        // Connect it to the SnappingSheet
        controller: MySnappingSheetController,
          // initialSnappingPosition: init_snap_pos
          //     ? null
          //     : SnappingPosition.factor(positionFactor: 0.3),
        );
    // You can now control the sheet in multiple ways.
  }
  void _pushToggle() {
    if(firt_time_snap){
      InitSnappingPose = MySnappingSheetController.currentSnappingPosition;
      firt_time_snap = false;
    }

    if(init_snap_pos){
      MySnappingSheetController.snapToPosition(
          const SnappingPosition.factor(positionFactor: 0.3)
      );
    }else{
      MySnappingSheetController.snapToPosition(
          InitSnappingPose
      );
    }
    init_snap_pos = !init_snap_pos;

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

class MyOwnSheetContent extends StatelessWidget {
  AuthRepository authRepositoryInst;

  MyOwnSheetContent(this.authRepositoryInst, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      alignment: Alignment.topLeft,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.brown.shade800,
              child: const Text('AH'),
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
                    '${authRepositoryInst.user!.email}',
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
                      onPressed: () {
                        print('Pressed');
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
  }
}
