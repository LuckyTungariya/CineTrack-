import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ApiService{

  Future<Map<dynamic,dynamic>> fetchContent(String url) async{
    final finalUrl = Uri.parse(url);

    var response = await http.get(finalUrl,headers: {
      'Authorization': 'Bearer $_autHeader',
      'accept' : 'application/json'
    });

    if(response.statusCode == 200){
      Map finalArray = jsonDecode(response.body);
      return finalArray;
    }else{
      print("Something went wrong with status code ${response.statusCode}");
      return {};
    }
  }

  Future<Map<dynamic,dynamic>> fetchDetails(String url) async{
    final finalUrl = Uri.parse(url);
    var response = await http.get(finalUrl,headers: {
      'Authorization' : 'Bearer $_autHeader',   // Access your authheader by logging in on tmdb
      'accept' : 'application/json'
    });

    if(response.statusCode == 200){
      Map finalArray = jsonDecode(response.body);
      return finalArray;
    }else{
      print("Something went wrong ${response.statusCode}");
      return {};
    }
  }

  Future<String?> uploadImage(String filePath) async {

    var url = Uri.parse("https://api.pinata.cloud/pinning/pinFileToIPFS");

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        "Authorization": "Bearer $jwt"   // Access your jwt token by logging in on pinata service
      })
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      print("Pinata response body $responseData");
      return responseData["IpfsHash"]; // This is the CID
    } else {
      print("Failed to upload to Pinata: ${response.statusCode}");
      return null;
    }
  }

  Future<void> shareApp(BuildContext context) async{
    final params = ShareParams(
      title: "Download the CineTrack app now!!",
      text: "Explore trending movies,tv shows manage watchlist, profile.",
    );

    final result = await SharePlus.instance.share(params);
    if(result.status == ShareResultStatus.success){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thankyour for sharing CineTrack")));
    }
  }

}
