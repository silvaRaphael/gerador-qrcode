import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QRCode Generator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Q R C O D E'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imgPath = '';
  final TextEditingController _textcontroller = TextEditingController();

  Future getQRCode() async {
    FocusScope.of(context).unfocus();

    if (_textcontroller.text.trim().isNotEmpty) {
      String url =
          'https://geradordeqrcode.com.br/phpqrcode/?type=text&text=${_textcontroller.text.trim()}';

      final response = await get(Uri.parse(url), headers: {'Accept': '*'});
      var result = jsonDecode(response.body);

      setState(() {
        imgPath = 'https://geradordeqrcode.com.br${result['img_path']}';
        _textcontroller.text = '';
      });
    } else {
      setState(() {
        imgPath = '';
      });

      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Houve um erro'),
            content: const Text('Digite alguma coisa!\nE tente novamente.'),
            actions: [
              CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  }),
            ],
          );
        },
        barrierDismissible: true,
        useRootNavigator: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imgPath.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(13),
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'lib/images/placeholder.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Image(
                                fit: BoxFit.contain,
                                image: NetworkImage(imgPath, scale: 1)),
                          ),
                          TextButton(
                            child: const Text('Compartilhar'),
                            onPressed: () async {
                              final uri = Uri.parse(imgPath);
                              final response = await get(uri);
                              final bytes = response.bodyBytes;
                              final temp = await getTemporaryDirectory();
                              final path = '${temp.path}/qrcode.png';
                              File(path).writeAsBytesSync(bytes);
                              await Share.shareFiles([path], text: '');
                            },
                          ),
                        ],
                      ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple,
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textcontroller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Seu texto aqui...',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: getQRCode,
                  child: const Text('G E R A R  Q R C O D E'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
