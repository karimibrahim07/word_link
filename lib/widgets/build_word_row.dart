import 'package:flutter/material.dart';

Widget buildWordRow(String word) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < word.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildLetterBox(word.isNotEmpty ? word[i] : ''),
            ),
            const SizedBox(height: 2)
        ],
      ),
    );
  }

  Widget _buildLetterBox(String letter) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
