import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'Database.dart';
import 'HistoryModel.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double defaultSize;
  static Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

class MyModel with ChangeNotifier {
  double _counter;
  double _counterFrom;

  double get counter => _counter;

  double get counterFrom => _counterFrom;

  void set counter(double value) {
    counter = value;
    notifyListeners();
  }

  void set counterFrom(double value) {
    counterFrom = value;
    notifyListeners();
  }
}

double ConvertTo(double value, double course) {
  return value / course;
}

double ConvertFrom(double value, double course) {
  return value * course;
}

void main() {
  // SharedPreferences.setMockInitialValues({});
  runApp(ChangeNotifierProvider<MyModel>(
      create: (context) => MyModel(),
      child: MaterialApp(
        home: MyApp(),
      )));
}

enum CustomPopupMenu { USD, RUB, EUR }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: Text('Convert To'),
                  onPressed: () {
                    developer.log("ConvTo selected");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConvTo()),
                    );
                  },
                ),
                ElevatedButton(
                  child: Text('Convert From'),
                  onPressed: () {
                    developer.log("ConvFrom selected");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConvFrom()),
                    );
                  },
                ),
                Text(
                  "History",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Container(
                        height: 500,
                        child: FutureBuilder<List<HistoryModel>>(
                          future: DBProvider.db.getAllHistoryModels(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<HistoryModel>> snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  HistoryModel item = snapshot.data[index];
                                  return Dismissible(
                                    key: UniqueKey(),
                                    background: Container(color: Colors.red),
                                    onDismissed: (direction) {
                                      DBProvider.db.deleteHistoryModel(item.id);
                                      developer
                                          .log("deleted line from database");
                                    },
                                    child: ListTile(
                                      title: Text(item.firstName.toString() +
                                          " " +
                                          item.firstVal.toString() +
                                          " = " +
                                          item.lastName.toString() +
                                          " " +
                                          item.secondVal.toString()),
                                      leading: Text(item.id.toString()),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}

class ConvTo extends StatefulWidget {
  @override
  _ConvToState createState() => _ConvToState();
}

class _ConvToState extends State {
  List data;

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://www.nbrb.by/api/exrates/rates?periodicity=0"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
    });
    developer.log("API get succeed");
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    _loadValueIn();
    getData();
  }

  _loadValueIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      valueIn = (prefs.getDouble('valueInConvTo') ?? 0.0);
    });
  }

  _saveValueIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('valueInConvTo', valueIn);
    });
    developer.log("Shared prefs updated");
  }

  final _formKey = GlobalKey<FormState>();
  CustomPopupMenu _selection = null;
  double _counter = 0;
  double valueIn;
  String _val = "<-Choose currency";
  double backUpcounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Convert To"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Convert BEL to USD,EUR,RUB',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (double.tryParse(value) == null) {
                              developer.log("sum validation failed");
                              return 'Please enter correct sum';
                            }
                            valueIn = double.parse(value);
                            developer.log("sum validation succeed");
                            return null;
                          },
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: valueIn.toString(),
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PopupMenuButton<CustomPopupMenu>(
                                onSelected: (CustomPopupMenu result) {
                                  _selection = result;
                                  switch (_selection) {
                                    case CustomPopupMenu.USD:
                                      {
                                        _val = "USD";
                                      }
                                      break;
                                    case CustomPopupMenu.RUB:
                                      {
                                        _val = "RUB";
                                      }
                                      break;
                                    case CustomPopupMenu.EUR:
                                      {
                                        _val = "EUR";
                                      }
                                      break;
                                    default:
                                      {
                                        _val = "";
                                      }
                                      break;
                                  }
                                  ;
                                  setState(() {});
                                },
                                itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<CustomPopupMenu>>[
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.USD,
                                    child: Text('USD'),
                                  ),
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.RUB,
                                    child: Text('RUB'),
                                  ),
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.EUR,
                                    child: Text('EUR'),
                                  ),
                                ],
                              ),
                              Text('$_val')
                            ]),
                        ElevatedButton(
                          onPressed: () async {
                            _saveValueIn();
                            if (_formKey.currentState.validate() &&
                                _selection != null) {
                              switch (_selection) {
                                case CustomPopupMenu.USD:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counter = ConvertTo(
                                        valueIn, data[4]['Cur_OfficialRate']);
                                    backUpcounter = model._counter;
                                  }
                                  break;
                                case CustomPopupMenu.RUB:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counter = ConvertTo(valueIn,
                                        data[16]['Cur_OfficialRate'] / 100);
                                    backUpcounter = model._counter;
                                  }
                                  break;
                                case CustomPopupMenu.EUR:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counter = ConvertTo(
                                        valueIn, data[5]['Cur_OfficialRate']);
                                    backUpcounter = model._counter;
                                  }
                                  break;
                                default:
                                  {
                                    _counter = 0;
                                  }
                                  break;
                              }
                              ;
                              HistoryModel rnd = HistoryModel(
                                  firstName: "BEL",
                                  firstVal: valueIn.toString(),
                                  lastName: _val,
                                  secondVal: backUpcounter.toString());
                              await DBProvider.db.newHistoryModel(rnd);
                              developer
                                  .log("converted + added new line to history");
                              setState(() {});
                            }
                          },
                          child: Text('Convert'),
                        ),
                        Consumer<MyModel>(
                          builder: (context, value, child) =>
                              Text(value._counter.toString()),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Go back!'),
                        ),
                      ],
                    ),
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

class ConvFrom extends StatefulWidget {
  @override
  _ConvFromState createState() => _ConvFromState();
}

class _ConvFromState extends State {
  List data;

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://www.nbrb.by/api/exrates/rates?periodicity=0"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
    });
    developer.log("API get succeed");
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    _loadValueIn();
    getData();
  }

  _loadValueIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      valueIn = (prefs.getDouble('valueInConvFrom') ?? 0.0);
    });
  }

  _saveValueIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('valueInConvFrom', valueIn);
    });
    developer.log("Shared prefs updated");
  }

  final _formKey = GlobalKey<FormState>();
  CustomPopupMenu _selection = null;
  double _counterFrom = 0;
  double valueIn;
  String _val = "<-Choose currency";
  double backUpcounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Convert From"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Convert USD,EUR,RUB to BEL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (double.tryParse(value) == null) {
                              developer.log("sum validation failed");
                              return 'Please enter correct sum';
                            }
                            valueIn = double.parse(value);
                            developer.log("sum validation succeed");
                            return null;
                          },
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: valueIn.toString(),
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PopupMenuButton<CustomPopupMenu>(
                                onSelected: (CustomPopupMenu result) {
                                  _selection = result;
                                  switch (_selection) {
                                    case CustomPopupMenu.USD:
                                      {
                                        _val = "USD";
                                      }
                                      break;
                                    case CustomPopupMenu.RUB:
                                      {
                                        _val = "RUB";
                                      }
                                      break;
                                    case CustomPopupMenu.EUR:
                                      {
                                        _val = "EUR";
                                      }
                                      break;
                                    default:
                                      {
                                        _val = "";
                                      }
                                      break;
                                  }
                                  ;
                                  setState(() {});
                                },
                                itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<CustomPopupMenu>>[
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.USD,
                                    child: Text('USD'),
                                  ),
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.RUB,
                                    child: Text('RUB'),
                                  ),
                                  const PopupMenuItem<CustomPopupMenu>(
                                    value: CustomPopupMenu.EUR,
                                    child: Text('EUR'),
                                  ),
                                ],
                              ),
                              Text('$_val')
                            ]),
                        ElevatedButton(
                          onPressed: () async {
                            _saveValueIn();
                            if (_formKey.currentState.validate() &&
                                _selection != null) {
                              switch (_selection) {
                                case CustomPopupMenu.USD:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counterFrom = ConvertFrom(
                                        valueIn, data[4]['Cur_OfficialRate']);
                                    backUpcounter = model._counterFrom;
                                  }
                                  break;
                                case CustomPopupMenu.RUB:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counterFrom = ConvertFrom(valueIn,
                                        data[16]['Cur_OfficialRate'] / 100);
                                    backUpcounter = model._counterFrom;
                                  }
                                  break;
                                case CustomPopupMenu.EUR:
                                  {
                                    final model = Provider.of<MyModel>(context);
                                    model._counterFrom = ConvertFrom(
                                        valueIn, data[5]['Cur_OfficialRate']);
                                    backUpcounter = model._counterFrom;
                                  }
                                  break;
                                default:
                                  {
                                    _counterFrom = 0;
                                  }
                                  break;
                              }
                              ;
                              HistoryModel rnd = HistoryModel(
                                  firstName: _val,
                                  firstVal: valueIn.toString(),
                                  lastName: "BEL",
                                  secondVal: backUpcounter.toString());
                              await DBProvider.db.newHistoryModel(rnd);
                              developer
                                  .log("converted + added new line to history");
                              setState(() {});
                            }
                          },
                          child: Text('Convert'),
                        ),
                        Consumer<MyModel>(
                          builder: (context, value, child) =>
                              Text(value._counterFrom.toString()),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Go back!'),
                        ),
                      ],
                    ),
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

