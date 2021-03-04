import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

const appName = 'Name Generator';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF333533),
        secondaryHeaderColor: Color(0xFF242423),
        accentColor: Color(0xFFF5CB5C),
        buttonColor: Color(0xFFF5CB5C),
        cardColor: Color(0xFF323232),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  // TabView controller
  late TabController tabController = TabController(vsync: this, length: 2);

  // Shared preferences instance
  late SharedPreferences prefs;

  // Shared preferences key for the favorites list
  String favKey = "FAV";

  // List of the alphabet letters
  static const letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

  // Letters selection
  static final selection = List<bool>.filled(letters.length, true);

  // Selected letters
  List<String> getSelectedLetters() {
    List<String> sL = [];
    for(var i = 0; i < letters.length; i++){
      if(selection[i]) sL.add(letters[i]);
    }
    return sL;
  }

  static final Random rnd = Random();

  // Favorites list from the shared preferences
  List<String> favorites = [];

  // List of the generated names
  List<String> names = [];

  // Number of words to be generated
  double wordsCount = 20;

  // Range of the number of letters in the words to be generated
  RangeValues lettersRange = RangeValues(3, 9);

  // Is the letter ExpansionPanel opened
  bool isPanelOpened = false;
  
  // Generates the names according to the parameters
  generate(){
    List<String> newNames = [];
    var selectedLetters = getSelectedLetters();
    for(int i = 0; i < wordsCount; i++){
      var newName = "";
      var lettersCount = lettersRange.start + rnd.nextInt(lettersRange.end.toInt() - lettersRange.start.toInt());
      for(int i = 0; i < lettersCount; i++){
        newName += selectedLetters[rnd.nextInt(selectedLetters.length)];
      }
      newNames.add(newName);
    }
    setState(() => names = newNames);
  }

  @override
  void initState() {
    super.initState();
    () async {
      var p = await SharedPreferences.getInstance();
      setState(() {
        prefs = p;
        favorites = prefs.getStringList(favKey) ?? [];
      });
    }();
  }

  toggleFavorite(String name){
    setState(() {
      if(favorites.contains(name)){
        favorites.remove(name);
      } else {
        favorites.add(name);
      }
    });
    prefs.setStringList(favKey, favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Center(child: Text(appName, style: TextStyle(fontSize: 24,))),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: TabBarView(
            controller: tabController,
            children: <Widget>[
              // Generator tab
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ExpansionPanelList(
                        animationDuration: Duration(milliseconds: 300),
                        expansionCallback: (i, open) => setState(() => isPanelOpened = !open),
                        children: <ExpansionPanel>[
                          ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded: isPanelOpened,
                            headerBuilder: (context, open){
                              return Container(
                                padding: EdgeInsets.only(left: 16),
                                alignment: Alignment.centerLeft,
                                child: Text("Letters", style: TextStyle(fontSize: 20),));
                            },
                            body: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: <Widget>[
                                for(var i = 0; i < letters.length; i++)
                                  GestureDetector(
                                    onTap: () => setState(() => selection[i] = !selection[i]),
                                    child: Chip(
                                      label: Text(letters[i], style: TextStyle(
                                      fontSize: 20,
                                      color: selection[i] ? Colors.black : Colors.white),),
                                    backgroundColor: selection[i] ? Theme.of(context).accentColor : Theme.of(context).secondaryHeaderColor,),
                                  )
                              ],),
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 32,),
                      Text("Letters in the words", style: TextStyle(fontSize: 20),),
                      RangeSlider(
                        activeColor: Theme.of(context).accentColor,
                        inactiveColor: Theme.of(context).secondaryHeaderColor,
                        divisions: 14,
                        min: 2,
                        max: 16,
                        onChanged: (RangeValues rv) => setState(() => lettersRange = rv),
                        labels: RangeLabels(lettersRange.start.toInt().toString(), lettersRange.end.toInt().toString()),
                        values: lettersRange,
                      ),
                      SizedBox(height: 16,),
                      Text("Words to generate", style: TextStyle(fontSize: 20),),
                      Slider(
                        activeColor: Theme.of(context).accentColor,
                        inactiveColor: Theme.of(context).secondaryHeaderColor,
                        divisions: 19,
                        min: 1,
                        max: 20,
                        onChanged: (double nb) => setState(() => wordsCount = nb),
                        label: wordsCount.toInt().toString(),
                        value: wordsCount
                      ),
                      SizedBox(height: 16,),
                      ElevatedButton.icon(

                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                          shape: StadiumBorder()
                        ),
                        icon: Icon(Icons.refresh, color: Colors.black,),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Generate names", 
                            style: TextStyle(color: Colors.black, fontSize: 18,)),
                        ),
                        onPressed: () => generate(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Theme.of(context).accentColor),
                      ),
                      if(names.isNotEmpty)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                          for(var name in names)
                            GestureDetector(
                              onTap: () => toggleFavorite(name),
                              child: Chip(
                                label: Text(name, style: TextStyle(
                                  fontSize: 18,
                                  color: favorites.contains(name) ? Colors.black : Colors.white),),
                                backgroundColor: favorites.contains(name) ? Theme.of(context).accentColor : Theme.of(context).secondaryHeaderColor,
                              )
                            )
                        ],)
                    ],
                  ),
                ),
              ),

              // Favorites tab
              ListView(
                children: <Widget>[
                  if(favorites.isNotEmpty)
                    for(var fav in favorites)
                    Dismissible(
                      key: Key(fav),
                      background: Container(
                            alignment: Alignment.center,
                            color: Colors.red,
                            child: Icon(Icons.delete),),
                      onDismissed: (direction) => toggleFavorite(fav),
                      child: ListTile(
                        onTap: () async {
                          // Copy the text in the clipboard
                          await Clipboard.setData(ClipboardData(text: fav));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 16,
                              backgroundColor: Colors.grey[850],
                              content: Text("Named copied to clipboard.", 
                                style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                textAlign: TextAlign.center,)
                            )
                          );
                        } ,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        title: Text(fav, textAlign: TextAlign.center, style: TextStyle(fontSize: 20),)),
                    )
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: TabBar(
        indicatorWeight: 1,
        controller: tabController,
        labelColor: Theme.of(context).accentColor,
        unselectedLabelColor: Color(0xFFCFDBD5),
        tabs: <Widget>[
          Tab(icon: Icon(Icons.add), /*child: Text("Generate")*/),
          Tab(icon: Icon(Icons.star), /*child: Text("Favorites")*/),
        ],
        onTap: (i) => tabController.animateTo(i),
      ),
    );
  }
}
