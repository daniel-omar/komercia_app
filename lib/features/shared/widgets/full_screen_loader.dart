import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // return const SizedBox.expand(
    //   child: Center(
    //     child: CircularProgressIndicator( strokeWidth: 2),
    //   ),
    // );
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(''),
      //   backgroundColor: Colors.yellow[700],
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
