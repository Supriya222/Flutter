import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:io';

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget{
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp>{
  int temperature=20;
  String location= "Kolkata";
  int woeid=2295386;
  String weather = "clear";
  String abbrevation="";
  String searchApiUrl="https://www.metaweather.com/api/location/search/?query=";
  String locationApiUrl="https://www.metaweather.com/api/location/";
  String error_message="";

  initState(){
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async
  {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        error_message="";
      });
    }
    catch(error){
      setState((){
        error_message="Sorry, the data about this city is not available. Search for another city...";
      });
    }
  }

  void fetchLocation() async{
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data= consolidated_weather[0];

    setState((){
      temperature= data["the_temp"].round();
      weather= data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbrevation=data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();
  }
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:Container(

          child: temperature == null
              ?Center(child: CircularProgressIndicator())
              :Scaffold(
                backgroundColor:Colors.lightBlueAccent,
                body:Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:<Widget>[
                Column(
                  children:<Widget>[
                    Center(
                      child:Image.network(
                      "https://www.metaweather.com/static/img/weather/png/"+abbrevation+".png",
                        width:70,
                      )
                    ),
                   Center(
                       child:Text(
                         temperature.toString() +" °C",style:TextStyle(
                         color:Colors.white,fontSize:50
                       ),
                       ),
                     ),
                    Center(
                      child:Text(
                        location,
                        style:TextStyle(color:Colors.white,fontSize:45),
                      ),
                    ),
                 ],
                ),

             Column(
               children:<Widget>[
                Container(

                  child:TextField(
                    onSubmitted:(String input){
                      onTextFieldSubmitted(input);
                    },
                    style:TextStyle(color:Colors.white,fontSize:30),
                     decoration:InputDecoration(
                       hintText:"Enter location to be searched...",
                       hintStyle:TextStyle(color:Colors.black54,fontSize:20),
                       prefixIcon:Icon(Icons.search,color:Colors.black54),
                     ),
                  ),
                  width:300,
                ),
                 Text(
                   error_message,
                   textAlign:TextAlign.center,
                   style:TextStyle(
                     color:Colors.redAccent,
                     fontSize:Platform.isAndroid?15.0:20.0,
                   ))
               ],
              )
              ],
            ),
            ),
          ),
      );
  }
}



