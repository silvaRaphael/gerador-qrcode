import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrcode_generator/utils/MyTextInput.dart';
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
  String qrcodeSelected = 'text';
  String wifiCriptation = 'WPA';
  String imgPath = '';
  final TextEditingController _textcontroller = TextEditingController();
  final TextEditingController _phonenumbercontroller = TextEditingController();
  final TextEditingController _wifipasswordcontroller = TextEditingController();

  MaskTextInputFormatter phoneNumberMask = MaskTextInputFormatter(
    mask: '+## (##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future getQRCode() async {
    FocusScope.of(context).unfocus();

    String url = '';
    bool valid = false;

    switch (qrcodeSelected) {
      case 'text':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&text=${_textcontroller.text.trim()}';
        if (_textcontroller.text.trim().isNotEmpty) valid = true;
        break;
      case 'link':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&link=${_textcontroller.text.trim()}';
        if (_textcontroller.text.trim().isNotEmpty) valid = true;
        break;
      case 'whatsapp':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&numero=${phoneNumberMask.getUnmaskedText()}&mensagem=${_textcontroller.text.trim().replaceAll(' ', '%2B')}';
        if (_textcontroller.text.trim().isNotEmpty &&
            phoneNumberMask.getUnmaskedText().isNotEmpty) valid = true;
        break;
      case 'tel':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&numero=${phoneNumberMask.getUnmaskedText()}';
        if (phoneNumberMask.getUnmaskedText().isNotEmpty) valid = true;
        break;
      case 'wifi':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&rede=${_textcontroller.text.trim()}&tipo=$wifiCriptation&senha=${_wifipasswordcontroller.text.trim()}';
        if (_textcontroller.text.trim().isNotEmpty &&
            _wifipasswordcontroller.text.trim().isNotEmpty) valid = true;
        break;
    }

    if (valid && url.isNotEmpty) {
      final response = await get(Uri.parse(url), headers: {'Accept': '*'});
      var result = jsonDecode(response.body);

      setState(() {
        imgPath = 'https://geradordeqrcode.com.br${result['img_path']}';
        _textcontroller.text = '';
        wifiCriptation = 'WPA';
        _wifipasswordcontroller.text = '';
        _phonenumbercontroller.text = '';
        phoneNumberMask.clear();
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

  contentToLoad() {
    var contentToReturn = null;

    switch (qrcodeSelected) {
      case 'text':
        contentToReturn = MyTextInput(
          inputType: TextInputType.text,
          controller: _textcontroller,
          formatter: MaskTextInputFormatter(),
          hintText: 'Seu texto aqui...',
        );
        break;
      case 'link':
        contentToReturn = MyTextInput(
          inputType: TextInputType.text,
          controller: _textcontroller,
          formatter: MaskTextInputFormatter(),
          hintText: 'https://',
        );
        break;
      case 'whatsapp':
        contentToReturn = Column(
          children: [
            MyTextInput(
              inputType: TextInputType.number,
              controller: _phonenumbercontroller,
              formatter: phoneNumberMask,
              hintText: '55 11 90000-0000',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _textcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Sua mensagem aqui...',
            )
          ],
        );
        break;
      case 'tel':
        contentToReturn = MyTextInput(
          inputType: TextInputType.number,
          controller: _phonenumbercontroller,
          formatter: phoneNumberMask,
          hintText: '55 11 90000-0000',
        );
        break;
      case 'wifi':
        contentToReturn = Column(
          children: [
            MyTextInput(
              inputType: TextInputType.text,
              controller: _textcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Nome da rede',
            ),
            Container(
              width: 260,
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Colors.deepPurple,
                    width: 1,
                  ),
                  vertical: BorderSide(
                    color: Colors.deepPurple,
                    width: 1,
                  ),
                ),
              ),
              child: DropdownButton(
                value: wifiCriptation,
                icon: Icon(Icons.keyboard_arrow_down),
                onChanged: (String? newValue) {
                  setState(() {
                    wifiCriptation = newValue!;
                  });
                },
                isExpanded: true,
                elevation: 2,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                underline: SizedBox(),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    child: Text('WPA/WPA2'),
                    value: 'WPA',
                  ),
                  DropdownMenuItem(
                    child: Text('WEP'),
                    value: 'WEP',
                  ),
                  DropdownMenuItem(
                    child: Text('Nenhuma'),
                    value: 'none',
                  ),
                ],
              ),
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _wifipasswordcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Senha',
            )
          ],
        );
        break;
      default:
        contentToReturn = SizedBox();
    }

    return contentToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              // height: MediaQuery.of(context).size.height - 80,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 80,
              ),
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
                    width: 260,
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F4FF),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: DropdownButton(
                      value: qrcodeSelected,
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          qrcodeSelected = newValue!;
                        });
                      },
                      isExpanded: true,
                      elevation: 2,
                      dropdownColor: Color(0xFFF8F4FF),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      underline: SizedBox(),
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          child: Text('Texto'),
                          value: 'text',
                        ),
                        DropdownMenuItem(
                          child: Text('Link'),
                          value: 'link',
                        ),
                        DropdownMenuItem(
                          child: Text('Whatsapp'),
                          value: 'whatsapp',
                        ),
                        DropdownMenuItem(
                          child: Text('Ligação'),
                          value: 'tel',
                        ),
                        DropdownMenuItem(
                          child: Text('WI-FI'),
                          value: 'wifi',
                        ),
                        DropdownMenuItem(
                          child: Text('Contato'),
                          value: 'contato',
                        ),
                      ],
                    ),
                  ),
                  contentToLoad(),
                  TextButton(
                    onPressed: getQRCode,
                    child: const Text('G E R A R  Q R C O D E'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
