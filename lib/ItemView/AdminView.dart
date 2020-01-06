import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemCreateDialog.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';
import 'package:plan_go_software_project/colors.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class AdminView extends StatefulWidget {
  final String documentId;
  final String userId;

  AdminView({
    Key key,
    this.documentId,
    this.userId,
  }) : super(key: key);

  @override
  _AdminViewState createState() => new _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  int _eventColor = 0;
  String _eventName = '';
  String _imageUrl = '';
  double offset = 0.0;
  Uri _dynamicLinkUrl;

  @override
  void initState() {
    super.initState();
    getEventInfo();
  }

  // Method how to get one variable out of database, without using
  //StreamBuilder
  void getEventInfo() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("events").document(widget.documentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _eventColor = document['eventColor'];
        _eventName = document['eventName'];
        _imageUrl = document['imageUrl'];
      });
    });
  }

  Future<void> _createDynamikLink() async {
    String _documentID = widget.documentId;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://plangosoftwareproject.page.link',
        link: Uri.parse(
            'https://plangosoftwareproject.page.link/invite/$_documentID'),
        androidParameters: AndroidParameters(
            packageName: 'com.example.plan_go_software_project',
            minimumVersion: 0),
        iosParameters: IosParameters(
            bundleId: 'com.example.planGoSoftwareProject',
            minimumVersion: '0'));
    final Uri url = await parameters.buildUrl();
    // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    // final Uri url = shortDynamicLink.shortUrl;
    setState(() {
      _dynamicLinkUrl = url;
    });
  }

  buildStream() {
    return ItemList(
      userId: widget.userId,
      documentId: widget.documentId,
      eventColor: _eventColor.toInt(),
    );
  }

  Widget createAppBar(bool value) {
    return new SliverAppBar(
      snap: true,
      pinned: true,
      floating: true,
      forceElevated: value,
      expandedHeight: 200.0,
      backgroundColor: Color(_eventColor),
      flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            _eventName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'MontserratRegular'),
          ),
          background: (_imageUrl != 'null')
              ? Image.network(_imageUrl, fit: BoxFit.cover)
              : Image.asset('images/calendar.png', fit: BoxFit.cover)),
    );
  }

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 5.0,
      child: Icon(Icons.add, color: cPlanGoWhiteBlue),
      backgroundColor: Color(_eventColor),
      onPressed: () {
        showDialog(
            context: context,
            child: new ItemCreateView(
                documentID: widget.documentId,
                eventColor: _eventColor.toInt()));
      },
    );
  }

  Widget bottomNavigation() {
    return new BottomAppBar(
      elevation: 5.0,
      shape: CircularNotchedRectangle(),
      color: Color(_eventColor),
      notchMargin: 4.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                _createDynamikLink();
                showDialog(
                    context: context,
                    child: new AlertDialog(
                        title: new Text("Sharing is caring"),
                        content:
                            new SelectableText(_dynamicLinkUrl.toString())));
              })
        ],
      ),
    );
  }

  Widget getScrollView() {
    return new NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) {
        return <Widget>[createAppBar(innerBoxScrolled)];
      },
      body: buildStream(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlanGoWhiteBlue,
      extendBody: true,
      body: getScrollView(),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}
