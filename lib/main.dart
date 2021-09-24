import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BLoC _bloc = BLoC();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ejemplo de builders',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(_bloc, HomeWidget()),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);
    return new Scaffold(
      appBar: new AppBar(title: Text("Builders Anidados"),actions: <Widget>[],),
      body: StreamBuilder<List<Cuadro>>(
        stream: bloc.cuadroListStream,
        initialData: bloc.initCuadroList(),
        builder: (context,snapshot){
          List<Cuadro>? cuadros = snapshot.data;
          return OrientationBuilder(builder: (context,orientation){
            return GridView.builder(
              itemCount:cuadros!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (orientation==Orientation.portrait)?3:4),
              itemBuilder: (BuildContext context,int index){
                return GridTile(child: Container(
                  color: cuadros[index].color,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(cuadros[index]._text,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,),
                  ),
                ));
              },
            );
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>bloc.addAction.add(null),
        tooltip: 'Agregar',
        child: new Icon(Icons.add),
      ),
    );
  }
}


class Cuadro{
  String _text;
  Color _color;
  Cuadro(this._text,this._color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Cuadro && runtimeType == other.runtimeType &&
              _text == other._text && _color == other._color;

  @override
  int get hashCode => _text.hashCode ^ _color.hashCode;

  Color get color => _color;

  String get text => _text;

}

class BLoC{
  final _random = new Random();
  List<Cuadro> _cuadroList = [];

  BLoC(){
    _addActionStreamController.stream.listen(_handleAdd);
  }

  int next(int min,int max) =>min+_random.nextInt(max-min);

  List<Cuadro> initCuadroList(){
    _cuadroList = [new Cuadro("Cuadro 1",Colors.tealAccent)];
    return _cuadroList;
  }

  void dispose(){
    _addActionStreamController.close();
  }

  Cuadro crearCuadro(){
    String nextCuadroNumberAsString = (_cuadroList.length+1).toString();
    return Cuadro("Cuadro "+nextCuadroNumberAsString, Color.fromRGBO(next(0,255), next(0, 255 ), next(0,255), 0.6));
  }

  void _handleAdd(void v){
    _cuadroList.add(crearCuadro());
    _cuadroListSubject.add(_cuadroList);
  }
  final _cuadroListSubject = BehaviorSubject<List<Cuadro>>();
  Stream<List<Cuadro>> get cuadroListStream=>_cuadroListSubject.stream;
  final _addActionStreamController = StreamController();
  Sink get addAction =>_addActionStreamController.sink;
}

class BlocProvider extends InheritedWidget{
  final BLoC bloc;


  BlocProvider(@required this.bloc,Widget child) : super(child:child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>true;

  static BLoC of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<BlocProvider>() as
      BlocProvider).bloc;
}


