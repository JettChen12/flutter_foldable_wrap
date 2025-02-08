import 'package:flutter/material.dart';
import 'package:flutter_foldable_wrap/foldable_wrap/foldable_wrap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isFold = false;

  static final List<String> _strList = [
    'Americano',
    'Cappuccino',
    'Espresso',
    'Latte',
    'Mocha',
    'Macchiato',
    'Flat White',
    'Cortado',
    'Irish Coffee',
    'Affogato'
  ];

  Widget _buildChild(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildFoldWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFold = !_isFold;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: _isFold ? Icon(Icons.expand_more_outlined) : Icon(Icons.expand_less_outlined),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.only(bottomRight: Radius.circular(15))),
              child: Center(child: Text('There are some coffee brands: ', style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FoldableWrap(
                  spacing: 10,
                  runSpacing: 10,
                  childHeight: 50,
                  foldWidget: _buildFoldWidget(),
                  isFold: _isFold,
                  foldLine: 2,
                  children: _strList.map((e) => _buildChild(e)).toList()),
            )
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
