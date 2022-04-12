library languagelenspack;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late List<LangData> _langChartData;
  late TooltipBehavior _tooltipBehavior;
  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String greetings = "";

  String originalText = "Original Text will appear here...";
  String translatedText = "Translated Text will appear here...";
  String newsArticle = "Sorry! No news to show right now!";
  String dropdownVal = "Source Language";
  String tempLang = "No data";
  String tempCount = "0";

  var statLang = [];
  var statCount = [];
  var items = [
    "Source Language",
    "Amharic",
    "Arabic",
    "Basque",
    "Bengali",
    "Bulgarian",
    "Catalan",
    "Chinese",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "English",
    "Estonian",
    "Finnish",
    "French",
    "German",
    "Greek",
    "Gujarati",
    "Hebrew",
    "Hindi",
    "Hungarian",
    "Icelandic",
    "Indonesian",
    "Italian",
    "Japanese",
    "Kannada",
    "Korean",
    "Latvian",
    "Lithuanian",
    "Malay",
    "Malayalam",
    "Marathi",
    "Norwegian",
    "Polish",
    "Romanian",
    "Russian",
    "Serbian",
    "Slovak",
    "Slovenian",
    "Spanish",
    "Swahili",
    "Swedish",
    "Tamil",
    "Telugu",
    "Thai",
    "Turkish",
    "Urdu",
    "Ukrainian",
    "Vietnamese",
    "Welsh"
  ];
  String dropdownVal1 = "Destination Language";
  var items1 = [
    "Destination Language",
    "Amharic",
    "Arabic",
    "Basque",
    "Bengali",
    "Bulgarian",
    "Catalan",
    "Chinese",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "English",
    "Estonian",
    "Finnish",
    "French",
    "German",
    "Greek",
    "Gujarati",
    "Hebrew",
    "Hindi",
    "Hungarian",
    "Icelandic",
    "Indonesian",
    "Italian",
    "Japanese",
    "Kannada",
    "Korean",
    "Latvian",
    "Lithuanian",
    "Malay",
    "Malayalam",
    "Marathi",
    "Norwegian",
    "Polish",
    "Romanian",
    "Russian",
    "Serbian",
    "Slovak",
    "Slovenian",
    "Spanish",
    "Swahili",
    "Swedish",
    "Tamil",
    "Telugu",
    "Thai",
    "Turkish",
    "Urdu",
    "Ukrainian",
    "Vietnamese",
    "Welsh"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _langChartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  uploadImage() async {
    final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://02d1-49-36-97-45.ngrok.io')); //put new ngrok link every time
    final headers = {"content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: "src" +
            dropdownVal +
            "dest" +
            dropdownVal1 +
            selectedImage!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response decRes = await http.Response.fromStream(response);
    final resJSON = jsonDecode(decRes.body);
    originalText = resJSON['originalText'];
    translatedText = resJSON['translatedText'];
    newsArticle = resJSON['newsFlash'];
    tempLang = resJSON['statLang'];
    tempCount = resJSON['statCount'];
    selectedImage = null;
    _langChartData = getChartData();
    setState(() {});
  }

  Future getImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  playLocal(audioPlayer, localPath) async {
    audioPlayer.clear();
    audioPlayer.play(localPath);
  }

  List<LangData> getChartData() {
    final List<LangData> langChartData = [];

    // LangData("German", 5),
    // LangData("Turkish", 7),
    // LangData("English", 2),
    // LangData("Hindi", 2),
    // LangData("Korean", 4),
    // LangData("French", 2),
    // LangData("Arabic", 3),
    statLang = tempLang.split("|");
    statCount = tempCount.split("|");

    for (var i = 0; i < statLang.length; i++) {
      langChartData.add(LangData(statLang[i], int.parse(statCount[i])));
    }
    return langChartData;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "LANGUAGE LENS",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xEE366BA1),
            //leading: , --to add logo https://www.youtube.com/watch?v=Afm3uouzYqA 2mins
            bottom: TabBar(
              indicatorWeight: 3,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                  child: Text("HOME"),
                ),
                Tab(
                  icon: Icon(Icons.chrome_reader_mode),
                  child: Text("PRACTICE"),
                ),
                Tab(
                  icon: Icon(Icons.account_circle),
                  child: Text("PROFILE"),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                  child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Color(0xAA366BA1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Center(
                              child: Text(
                            "IMAGE",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ))),
                      selectedImage == null
                          ? Text(
                              "Please select an image",
                              style: TextStyle(fontSize: 20, height: 3),
                            )
                          : Image.file(
                              selectedImage!,
                              fit: BoxFit.contain,
                              height: 200,
                              width: 400,
                            ),

                      // Text(
                      //   "SOURCE LANGUAGE",
                      //   style: TextStyle(
                      //       height: 2,
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.w400),
                      // ),
                      DropdownButton(
                        elevation: 5,
                        iconSize: 30,
                        dropdownColor: Color(0xEB366BA1),
                        focusColor: Color(0xEB366BA1),
                        isExpanded: true,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        items: items.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownVal = newValue.toString();
                          });
                        },
                        value: dropdownVal,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          height: 200,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Color(0x1129224f),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    String localPath = "srcTTS.mp3";
                                    final audioPlayer = AudioCache(
                                        prefix:
                                            "C:/Users/Anandamayee Modak/Documents/SEM V/PSDL/flask_Server/audio_files/");
                                    playLocal(audioPlayer, localPath);
                                  },
                                  icon: Icon(Icons.audiotrack_rounded),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 350),
                                  iconSize: 30,
                                  color: Color(0xEE366BA1),
                                  tooltip: "Learn how to pronounce",
                                  splashRadius: 10,
                                ),
                                Expanded(
                                    child: Text(
                                  originalText,
                                  style: TextStyle(fontSize: 20),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Text(
                      //   "DESTINATION LANGUAGE",
                      //   style: TextStyle(
                      //       height: 2,
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.w400),
                      // ),
                      DropdownButton(
                        isExpanded: true,
                        iconSize: 30,
                        dropdownColor: Color(0xEF366BA1),
                        //29224f
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        elevation: 5,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        items: items1.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                        onChanged: (newValue1) {
                          setState(() {
                            dropdownVal1 = newValue1.toString();
                          });
                        },
                        value: dropdownVal1,
                      ),
                      SingleChildScrollView(
                        child: Container(
                          height: 200,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Color(0x1129224f),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    String localPath = "destTTS.mp3";
                                    final audioPlayer = AudioCache(
                                        prefix:
                                            "C:/Users/Anandamayee Modak/Documents/SEM V/PSDL/flask_Server/audio_files/");
                                    playLocal(audioPlayer, localPath);
                                  },
                                  icon: Icon(Icons.audiotrack_rounded),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 350),
                                  iconSize: 30,
                                  color: Color(0xEE366BA1),
                                  tooltip: "Learn how to pronounce",
                                  splashRadius: 10,
                                ),
                                Expanded(
                                    child: Text(
                                  translatedText,
                                  style: TextStyle(fontSize: 20),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(10),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xEE366BA1))),
                          onPressed: uploadImage,
                          icon: Icon(
                            Icons.upload_file,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ),
              )),
              SingleChildScrollView(
                  child: Container(
                      color: Colors.white,
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                            Container(
                              height: 40,
                              width: 180,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: Color(0xEE366BA1)),
                              child: Center(
                                  child: Text("NEWS FLASH",
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white))),
                            ),
                            Container(
                                width: 400,
                                height: 1000,
                                decoration: BoxDecoration(
                                    color: Color(0x66366BA1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        newsArticle,
                                        style: TextStyle(
                                          fontSize: 25,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ))
                          ])))),
              Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 500,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xCC366BA1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "USER PROFILE",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            )),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: 30,
                                    width: 500,
                                    child: Text(
                                      "USERNAME:   xxxxxxx  \t\t\t FIRST NAME:   xxxxxxx  \t",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 18),
                                    )),
                                Container(
                                    height: 30,
                                    width: 500,
                                    child: Text(
                                      "PASSWORD:    xxxxxxx  \t\t\t LAST NAME:   xxxxxxx  \t",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 18),
                                    )),
                                Container(
                                    height: 30,
                                    width: 500,
                                    child: Text(
                                      " \t EMAIL:  random.user@something.com ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 18),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 500,
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xEE366BA1)),
                              color: Color(0xCC366BA1),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  child: Text(
                                    "PROFILE STATISTICS",
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                              border: Border.all(color: Colors.blue)),
                          child: SfCircularChart(
                            centerX: "160",
                            legend: Legend(
                                title: LegendTitle(
                                    text: "LEGEND",
                                    textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        height: 2)),
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.scroll,
                                alignment: ChartAlignment.far,
                                width: "60",
                                textStyle: TextStyle(fontSize: 14),
                                position: LegendPosition.left),
                            tooltipBehavior: _tooltipBehavior,
                            series: <CircularSeries>[
                              PieSeries<LangData, String>(
                                  dataSource: _langChartData,
                                  xValueMapper: (LangData data, _) =>
                                      data.language,
                                  yValueMapper: (LangData data, _) =>
                                      data.count,
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true),
                                  radius: "100",
                                  enableTooltip: true)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          // Center(
          //     child: Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         children: <Widget>[
          //       selectedImage == null
          //           ? Text("Please select an image")
          //           : Image.file(selectedImage!),
          //       TextButton.icon(
          //           style: ButtonStyle(
          //               backgroundColor: MaterialStateProperty.all(Colors.blue)),
          //           onPressed: uploadImage,
          //           icon: Icon(
          //             Icons.upload_file,
          //             color: Colors.white,
          //           ),
          //           label: Text(
          //             "Upload",
          //             style: TextStyle(color: Colors.white),
          //           )),
          //       Text(
          //         originalText,
          //         style: TextStyle(fontSize: 20),
          //       ),
          //       Text(
          //         translatedText,
          //         style: TextStyle(fontSize: 20),
          //       )
          //     ])),
          floatingActionButton: FloatingActionButton(
            elevation: 10,
            tooltip: "Add an image",
            backgroundColor: Color(0xEE366BA1),
            splashColor: Colors.blueGrey,
            onPressed: getImage,
            child: Icon(Icons.add_a_photo_outlined),
          ),
        ));
  }

  // void filePicker() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  //   Text(image!.path);
  //   final original = await http.get(Uri.parse('http://192.168.0.108:5000/'));
  //   final decoded = json.decode(original.body) as Map<String, dynamic>;
  //   setState(() {
  //     greetings = decoded['greetings'];
  //     this.image = XFile(image.path);
  //   });
  // }

  // Future<dynamic> doUpload() async {
  //   final mimeTypeData =
  //       lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])!.split('/');
  //        // Intilize the multipart request
  //   final imageUploadRequest = http.MultipartRequest('PUT', Uri.parse('http://192.168.0.108:5000/'));
  //   // Attach the file in the request
  //   final file = await http.MultipartFile.fromPath('image', image.path,
  //       contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
  //   imageUploadRequest.files.add(file);

  //   try {
  //     final streamedResponse = await imageUploadRequest.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     return response;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }

  // }
//   void doUpload() {

//   }
// }
}

class LangData {
  LangData(this.language, this.count);
  final String language;
  final int count;
}
