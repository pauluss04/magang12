import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class CustomDialog extends StatelessWidget {
  final String title, description;
  bool isOpen = false;
  //final Image image;

  CustomDialog(this.title, this.description);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 80, bottom: 16, left: 16, right: 16),
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontFamily: 'Nunito'),
              ),
              SizedBox(
                height: 16.0,
              ),
              Html(
                data: description,
                defaultTextStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 105,
          right: 105,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/images/gifseru.gif'))),
            height: 100,
          ),
        )
      ],
    );
  }
}
