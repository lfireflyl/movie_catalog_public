import 'package:flutter/material.dart';

import '../style/movies_list_style.dart';

class YearInputWidget extends StatelessWidget {
  final TextEditingController yearController;
  final Function(String) onYearChanged;

  const YearInputWidget({
    required this.yearController,
    required this.onYearChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: yearController,
      decoration: InputDecoration(
        hintText: 'Введите год',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: AppStyles.primaryColor), 
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: onYearChanged,
      cursorColor: AppStyles.primaryColor,
    );
  }
}
