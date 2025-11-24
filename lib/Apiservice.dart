import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ApiService{
  // final _apikey = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YjM1ODZmMTgyNzU3NTBkNGJmZWFjOGZmYTg4YmZhZCIsIm5iZiI6MTc2MTY1NTk5Mi4xODEsInN1YiI6IjY5MDBiY2I4MDc1MzU1YjQyMWMzZTBmYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.DSsFTszvwMgSsru7enAQQYhGdvtPdIHfQS_VZTGKo1U';
  final _autHeader = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YjM1ODZmMTgyNzU3NTBkNGJmZWFjOGZmYTg4YmZhZCIsIm5iZiI6MTc2MTY1NTk5Mi4xODEsInN1YiI6IjY5MDBiY2I4MDc1MzU1YjQyMWMzZTBmYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.DSsFTszvwMgSsru7enAQQYhGdvtPdIHfQS_VZTGKo1U';

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
      'Authorization' : 'Bearer $_autHeader',
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

  // API Key: 64cfe2e01b88214ca06e
  // API Secret: 784e48b2b9683d28b7e723324491c81afb03068aa392e3f5fa5f3fa19c997562
  // JWT: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI2Y2FjMTM3My01NmI5LTQxYjAtO
  // WE0NS0wMTBmZDhmNmY2M2UiLCJlbWFpbCI6Imx1Y2t5dHVuZ2FyaXlhNDEyQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLC
  // JwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXB
  // saWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElW
  // RSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI2NGNmZTJlMDFiODgyMTRjYTA2ZSIsInNjb
  // 3BlZEtleVNlY3JldCI6Ijc4NGU0OGIyYjk2ODNkMjhiN2U3MjMzMjQ0OTFjODFhZmIwMzA2OGFhMzkyZTNmNWZhNWYzZmExOWM5OTc1Nj
  // IiLCJleHAiOjE3OTUwOTcxMDZ9.MrssY50Oy04eymBgAepAlgmh8orftafacldmiKJqZ4w

  Future<String?> uploadImage(String filePath) async {
    final String jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI2Y2FjMTM3My01NmI5LTQxYjAtOWE0NS0wMTBmZDhmNmY2M2UiLCJlbWFpbCI6Imx1Y2t5dHVuZ2FyaXlhNDEyQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiJhZGNiYTIyZmY0NjM3ZDIyNjNlNyIsInNjb3BlZEtleVNlY3JldCI6IjEzNDQ5YzVlM2FhNzU5MDgyMThlN2RkMTZmNmQ1ZmJhY2UwZjAwMDNiZTIxYWNhMzM1ZGE5YTUxOGI1ODhjYjYiLCJleHAiOjE3OTUzNTY3NzR9.5hxaKcqXU2qQScQdDx4erZ6Vt_koffZ1it8tQbPnt8M";
    var url = Uri.parse("https://api.pinata.cloud/pinning/pinFileToIPFS");

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        "Authorization": "Bearer $jwt"
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

// API Key: adcba22ff4637d2263e7
// API Secret: 13449c5e3aa75908218e7dd16f6d5fbace0f0003be21aca335da9a518b588cb6
// JWT: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI2Y2FjMTM3My01NmI5LTQxYjAtOWE0NS0wMTBmZDhmNmY2M2UiLCJlbWFpbCI6Imx1Y2t5dHVuZ2FyaXlhNDEyQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiJhZGNiYTIyZmY0NjM3ZDIyNjNlNyIsInNjb3BlZEtleVNlY3JldCI6IjEzNDQ5YzVlM2FhNzU5MDgyMThlN2RkMTZmNmQ1ZmJhY2UwZjAwMDNiZTIxYWNhMzM1ZGE5YTUxOGI1ODhjYjYiLCJleHAiOjE3OTUzNTY3NzR9.5hxaKcqXU2qQScQdDx4erZ6Vt_koffZ1it8tQbPnt8M