import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextInput extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  TextInputType inputType;
  TextInputFormatter formatter;

  MyTextInput({
    required this.controller,
    required this.hintText,
    required this.inputType,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: 260,
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
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: [formatter],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
