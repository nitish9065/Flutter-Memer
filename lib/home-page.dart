import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:toast/toast.dart';
import 'package:image/image.dart' as Img;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  XFile? _image; //for captured image
  File? _imagefile;
  String headerText='', footerText='';
  var randomNumber = Random();
  bool? imageSelected = false;
  final headerController = TextEditingController();
  final footerController = TextEditingController();
  final ssController = ScreenshotController();

  Future getImage() async {
    var image;
    try {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } catch (platformException) {
      print("not allowing " + platformException.toString());
    }
    setState(() {
      if (image != null) {
        imageSelected = true;
      } else {}
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 130,
                    margin: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple,
                      border:Border.all(color: Colors.deepOrange,width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.grey,spreadRadius: 10,blurRadius: 20)
                      ]

                    ),
                    child: Image.asset('assets/albert.png'),
                  ),
                  Text('CREATE YOUR MEME',style: TextStyle(color: Colors.deepPurple,fontSize: 28,fontWeight: FontWeight.w800,),),

                  SizedBox(height: 10,),

                  // Main Frame for the Meme....
                  mainFrame(),
                  SizedBox(height: 15,),

                  TextField(
                    onChanged: (value){
                      setState(() {
                        headerText = value;
                      });
                    },
                    controller: headerController,
                    enableSuggestions: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Enter Header Text',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      suffixIcon: Icon(
                        Icons.vertical_align_top,
                        color: Colors.deepPurple,
                      ),

                      // when the user is typing..
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          borderSide: BorderSide(color: Colors.purple, width: 2)),

                      //usually the textinput looks like this...
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          borderSide: BorderSide(color: Colors.orange, width: 2)),
                    ),
                  ),
                  SizedBox(height: 15,),
                  TextField(
                    controller: footerController,
                    enableSuggestions: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Enter Footer Text',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      suffixIcon: Icon(
                        Icons.vertical_align_bottom,
                        color: Colors.deepPurple,
                      ),

                      // when the user is typing..
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          borderSide: BorderSide(color: Colors.purple, width: 2)),

                      //usually the textinput looks like this...
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          borderSide: BorderSide(color: Colors.orange, width: 2)),
                    ),
                    onChanged: (value){
                      setState(() {
                        footerText = value;
                      });
                    },
                  ),
                  SizedBox(height: 15,),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () async{
                            final _ssImage = await ssController.captureFromWidget(mainFrame());
                            if(_ssImage == null) {
                              Toast.show('Please Select Image First',duration: Toast.lengthShort,gravity: Toast.bottom);
                              return;
                            }
                            saveImage(_ssImage);
                            },
                          child:
                          Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w800,fontSize: 20),
                            ),
                          )),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            getImage();
          },
          child: Icon(Icons.camera_alt_outlined,color: Colors.white,),
        ),
      ),
    );
  }

 Widget mainFrame() {
    return Stack(
      children: <Widget>[
        Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.deepOrange,width: 4),
          ),
          child: _image!= null?
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(_image!.path),
              filterQuality: FilterQuality.high,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          )
              :Icon(Icons.image,color: Colors.black45,size: 100,),
        ),

        // Header Text  & footer Text on the image...
        Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:EdgeInsets.symmetric(vertical: 8),
                child: Text(headerText.toUpperCase(),textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black87,
                        ),
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 8.0,
                          color: Colors.black87,
                        ),
                      ]
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(footerText.toUpperCase(),textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black87,
                        ),
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 8.0,
                          color: Colors.black87,
                        ),
                      ]
                  ),),
              )
            ],
          ),
        ),

      ],
    );
 }

  Future<String> saveImage(Uint8List ssImage) async{
    await [Permission.storage].request();
    final timeStamp = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
    final ssName ="MemeMaker $timeStamp";
    final result = await ImageGallerySaver.saveImage(ssImage,name: ssName);
    if(result!=null){
      final snackBar = SnackBar(
        content: const Text('Yay! Image Saved to Gallery!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return result['filepath'];

  }
}
