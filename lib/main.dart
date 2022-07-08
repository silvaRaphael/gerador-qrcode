// ignore_for_file: prefer_const_constructors

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
  final TextEditingController _firstnamecontroller = TextEditingController();
  final TextEditingController _lastnamecontroller = TextEditingController();
  final TextEditingController _telnumbercontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _sitecontroller = TextEditingController();
  final TextEditingController _companycontroller = TextEditingController();
  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _faxcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  final TextEditingController _citycontroller = TextEditingController();
  final TextEditingController _cepcontroller = TextEditingController();
  final TextEditingController _statecontroller = TextEditingController();

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
      case 'contato':
        url =
            'https://geradordeqrcode.com.br/phpqrcode/?type=$qrcodeSelected&cel=${phoneNumberMask.getUnmaskedText()}&nome=${_firstnamecontroller.text.trim()}&ultimo_nome=${_lastnamecontroller.text.trim()}&empresa=${_companycontroller.text.trim()}&cargo=${_titlecontroller.text.trim()}&fax=${_faxcontroller.text.trim()}&endereco=${_addresscontroller.text.trim()}&cidade=${_citycontroller.text.trim()}&cep=${_cepcontroller.text.trim()}&estado=${_statecontroller.text.trim()}&email=${_emailcontroller.text.trim()}&site_url=${_sitecontroller.text.trim()}';
        bool emailValid = true;
        if (_emailcontroller.text.trim().isNotEmpty) {
          emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(_emailcontroller.text.trim());
        }
        if (phoneNumberMask.getUnmaskedText().isNotEmpty && emailValid) {
          valid = true;
        }
        break;
    }

    print(phoneNumberMask.getUnmaskedText());

    if (valid && url.isNotEmpty) {
      final response = await get(Uri.parse(url), headers: {'Accept': '*'});
      var result = jsonDecode(response.body);

      setState(() {
        imgPath = 'https://geradordeqrcode.com.br${result['img_path']}';
        _textcontroller.text = '';
        wifiCriptation = 'WPA';
        _wifipasswordcontroller.text = '';
        phoneNumberMask.clear();
        _phonenumbercontroller.text = '';
        _firstnamecontroller.text = '';
        _lastnamecontroller.text = '';
        _telnumbercontroller.text = '';
        _sitecontroller.text = '';
        _companycontroller.text = '';
        _titlecontroller.text = '';
        _faxcontroller.text = '';
        _addresscontroller.text = '';
        _citycontroller.text = '';
        _cepcontroller.text = '';
        _statecontroller.text = '';
        _emailcontroller.text = '';
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
    Widget contentToReturn;

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
              hintText: 'Número',
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
          hintText: 'Número',
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
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'WPA',
                    child: Text('WPA/WPA2'),
                  ),
                  DropdownMenuItem(
                    value: 'WEP',
                    child: Text('WEP'),
                  ),
                  DropdownMenuItem(
                    value: 'none',
                    child: Text('Nenhuma'),
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
      case 'contato':
        contentToReturn = Column(
          children: [
            MyTextInput(
              inputType: TextInputType.text,
              controller: _firstnamecontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Primeiro nome',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _lastnamecontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Último nome',
            ),
            MyTextInput(
              inputType: TextInputType.number,
              controller: _phonenumbercontroller,
              formatter: phoneNumberMask,
              hintText: 'Celular',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _emailcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'E-mail',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _sitecontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Site',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _companycontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Empresa',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _titlecontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Cargo',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _faxcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Fax',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _addresscontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Endereço',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _citycontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Cidade',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _cepcontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'CEP',
            ),
            MyTextInput(
              inputType: TextInputType.text,
              controller: _statecontroller,
              formatter: MaskTextInputFormatter(),
              hintText: 'Estado',
            ),
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
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'text',
                          child: Text('Texto'),
                        ),
                        DropdownMenuItem(
                          value: 'link',
                          child: Text('Link'),
                        ),
                        DropdownMenuItem(
                          value: 'whatsapp',
                          child: Text('Whatsapp'),
                        ),
                        DropdownMenuItem(
                          value: 'tel',
                          child: Text('Ligação'),
                        ),
                        DropdownMenuItem(
                          value: 'wifi',
                          child: Text('WI-FI'),
                        ),
                        DropdownMenuItem(
                          value: 'contato',
                          child: Text('Contato'),
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
