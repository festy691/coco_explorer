import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  String title;
  String subtitle;
  EmptyScreen({Key? key, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      width: _width - 48,
      height: 200,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.3),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(title, style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),),

          const SizedBox(height: 32,),

          SizedBox(
            width: _width - 48,
            child: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.normal),)),

        ],
      ),
    );
  }
}
