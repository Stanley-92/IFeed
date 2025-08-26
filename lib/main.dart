import 'package:flutter/material.dart';
import 'package:ifeed/Mainfeed.dart';



     void main() {
       runApp(MyApp());
     }

     class MyApp extends StatelessWidget {
       @override
       Widget build(BuildContext context) {
         return MaterialApp(
           home: MainfeedScreen(),
           
         );
       }
     }