import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Menu menu;

  const MenuCard({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: Colors.amber,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          // margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(color: Colors.blueAccent),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x000005cc),
                    blurRadius: 20,
                    offset: Offset(10, 10))
              ]),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  menu.icono,
                  size: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    textAlign: TextAlign.center,
                    menu.nombreMenu,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
