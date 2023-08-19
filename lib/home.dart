import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';



class Home extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Flushit',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2.0,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bathroom), ),
              Tab(icon: Icon(Icons.add_box_rounded)),
              Tab(icon:Icon(Icons.person)),
            ],
          ),

        ),
        body: TabBarView(
            children: [
              Center(child: Text('Hi Guys this is page 1')),
              Center(child: Text('Hi Guys this is page 2')),
              Center(child: Text('Hi Guys this is page 3')),
            ]
        )


      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}