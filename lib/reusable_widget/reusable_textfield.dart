import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obSecure;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? label;
  final Widget? sufIcon;
  final Widget? preIcon;
  final bool isMulti;
  final String title;
  final bool readOnly;
  final VoidCallback? OnTap;
  final int? maxLength;

  const ReusableTextField(
      {super.key,
      this.controller,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.obSecure = false,
      this.isMulti = false,
      this.readOnly = false,
      this.errorText,
      this.label,
      this.sufIcon,
      this.preIcon,
      this.onChanged,
      this.maxLength,
      this.OnTap,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: TextSpan(text: title,children: [TextSpan(text: "*",style: TextStyle(color: Colors.red))])),
        TextFormField(
            onChanged: onChanged,
            obscureText: obSecure,
            keyboardType: keyboardType,
            controller: controller,
            maxLines: isMulti ? 3 : 1,
            readOnly: readOnly,
            maxLength: maxLength,
            onTap: OnTap,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                prefixIcon: preIcon,
                hintText: title,
                hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.9), fontSize: 15),
                suffixIcon: sufIcon,
                counterText: '',
                labelText: label,
                floatingLabelStyle:
                    TextStyle(color: Color(0xff002233), fontSize: 20),
                labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero))),
            validator: validator),
      ],
    );
  }
}
