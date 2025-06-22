import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const kBgColor = Color(0xff252421);
const kAppBarColor = Color(0xff322e2c);
const kButtonColor = Color(0xff7fa751);

class Settings extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Settings> {
  String _time = '';

  List<String> _times = ['1 min', '2 min', '3 min', '5 min', '10 min'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Time Controls'),
        ),
        body: Column(
          children: [
            Text("Presets"),
            Column(
              children: _times
                  .map((time) => RadioListTile(
                        // tileColor: Colors.green,

                        title: Text(
                          time,
                          // style: TextStyle(color: Colors.white),
                        ),
                        groupValue: _time,
                        value: time,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (val) {
                          setState(() {
                            _time = "$val";
                          });
                        },
                      ))
                  .toList(),
            ),
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: Text("Start"))
          ],
        ),
      ),
    );
  }
}
