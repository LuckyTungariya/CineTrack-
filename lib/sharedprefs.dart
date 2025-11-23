import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  final String userNameKey = 'USERANAMEKEY';
  final String userIdKey = 'USERIDKEY';
  final String emailKey = 'EMAILKEY';
  final String passwordKey = 'PASSWORDKEY';
  final String profileKey = 'PROFILEKEY';
  final String loginKey = "LOGINKEY";

  Future<void> setUsername(String name) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userNameKey, name);
  }

  Future<String?> getUsername() async{
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString(userNameKey);
    return name;
  }

  Future<void> setUserId(String id) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userIdKey, id);
  }

  Future<String?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(userIdKey);
    return id;
  }

  Future<void> setEmail(String eml) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(emailKey, eml);
  }

  Future<String?> getEmail() async{
    final prefs = await SharedPreferences.getInstance();
    var eml = prefs.getString(emailKey);
    return eml;
  }

  Future<void> setPassword(String pss) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(passwordKey, pss);
  }

  Future<String?> getPassword() async{
    final prefs = await SharedPreferences.getInstance();
    var pss = prefs.getString(passwordKey);
    return pss;
  }

  Future<void> setUserProfile(String profilePath) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(profileKey, profilePath);
  }

  Future<String?> getUserProfile() async{
    final prefs = await SharedPreferences.getInstance();
    var profile = prefs.getString(profileKey);
    return profile;
  }

  Future<void> setLoginState(bool value) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(loginKey, value);
  }

  Future<bool?> getLoginState() async{
    final prefs = await SharedPreferences.getInstance();
    var state = prefs.getBool(loginKey);
    return state;
  }

}