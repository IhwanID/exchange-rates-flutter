import 'package:dio/dio.dart';
import 'package:exchangerates/currency.dart';
import 'package:exchangerates/exchange_rates.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Exchange Rates'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio dio = Dio();
  ExchangeRates exchangeRates;
  bool isLoading = true;
  TextEditingController _controller;
  Currency origin = Currency(
      text: "USD - United States Dollar",
      key: "us",
      value: "USD",
      flag: "us",
      symbol: "\$");
  Currency destination = Currency(
      text: "IDR - Indonesian Rupiah",
      key: "id",
      value: "IDR",
      flag: "id",
      symbol: "Rp");
  int current = 1;
  List<Currency> c = getDataCurrency();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '$current');
    getData();
  }

  getData() async {
    Response response = await dio
        .get("https://api.exchangeratesapi.io/latest?base=${origin.value}");
    print(response.data);

    setState(() {
      exchangeRates = ExchangeRates.fromJson(response.data);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Text(
                    "Last Update: ${exchangeRates.date}",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<Currency>(
                      hint: Text(origin.text, textAlign: TextAlign.center),
                      items: c.map((Currency value) {
                        return DropdownMenuItem<Currency>(
                          value: value,
                          child: Row(
                            children: <Widget>[
                              Flags.getFullFlag('${value.flag}', 10, 20),
                              Text(' ${value.text}'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          origin = value;
                        });
                        getData();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 36),
                      keyboardType: TextInputType.number,
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {
                          current = int.parse(value);
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 100,
                    child: FlatButton(
                      onPressed: () {
                        Currency temp = origin;
                        setState(() {
                          origin = destination;
                          destination = temp;
                          getData();
                        });
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.swap_vert),
                      ),
                    ),
                  ),
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<Currency>(
                      hint: Text(destination.text, textAlign: TextAlign.center),
                      items: c.map((Currency value) {
                        return DropdownMenuItem<Currency>(
                          value: value,
                          child: Row(
                            children: <Widget>[
                              Flags.getFullFlag('${value.flag}', 10, 20),
                              Text(' ${value.text}'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          destination = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "=",
                        style: TextStyle(fontSize: 42),
                      ),
                      Text(
                        FlutterMoneyFormatter(
                                amount: exchangeRates.rates[destination.value] *
                                    current)
                            .output
                            .nonSymbol,
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  )
                ],
              ));
  }
}