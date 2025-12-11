import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/detailpage.dart';
import 'package:tmdbmovies/sharedprefs.dart';

class WatchListPage extends StatefulWidget {
  const WatchListPage({super.key});

  @override
  State<WatchListPage> createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  String? userId;
  int currentIndex = 0;
  List userWatchList = [];
  bool _isloading = false;
  bool _isSearching = false;
  List<dynamic> searchResults = [];
  final TextEditingController _searchData = TextEditingController();
  final defaultShowUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png';

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() async{
    var id = await SharedPreferenceHelper().getUserId();
    userId = id!;
    setState(() {

    });
  }

  Stream<DocumentSnapshot<Map<String,dynamic>>>  _returnSnapshots(String id){
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        backgroundColor: AppDesign().bgColor,
        title: AnimSearchBar(
          color: AppDesign().bgColor,
          style: TextStyle(color: AppDesign().bgColor),
          searchIconColor: AppDesign().textColor,
          width: MediaQuery.of(context).size.width,
          textController: _searchData,
          suffixIcon: Icon(Icons.close,color: Colors.white),
          textFieldIconColor: Colors.black,
          textFieldColor: Colors.white,
          autoFocus: false,
          helpText: currentIndex == 0 ? 'Search content' : currentIndex == 1 ? 'Search movie' : 'Search tv',
          onSuffixTap: (){
            _searchData.clear();
          },
          onSubmitted: (String value) async{
            if(value.isEmpty){
              _isSearching = false;
            }

            setState((){
              _isloading = true;
            });

            searchResults = await DatabaseOptions().searchMedia(userWatchList,value);
            setState(() {

            });

            setState(() {
              _isSearching = true;
              _isloading = false;
            });
          },
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Watchlist',style: TextStyle(color: AppDesign().textColor,
                      fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20)),

                  SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: AnimatedToggleSwitch.size(
                        indicatorSize: Size(100, 40),
                        animationCurve: Curves.easeInOut,
                        current: currentIndex,
                        values: [0,1,2],
                        padding: EdgeInsets.only(left: 20,right: 10,top: 5,bottom: 5),
                        style: ToggleStyle(
                            indicatorBorderRadius: BorderRadius.circular(15),
                            indicatorColor: AppDesign().primaryAccent,
                            borderRadius: BorderRadius.circular(15),
                            backgroundColor: Colors.grey.shade800,
                            borderColor: AppDesign().bgColor
                        ),
                        height: 50,
                        spacing: 5,
                        onChanged: (value) {
                          setState(() {
                            currentIndex = value;
                            _isSearching = false;
                            searchResults.clear();
                          });
                        },
                        iconBuilder: (value) {
                          String text;
                          switch(value){
                            case 0:
                              text = 'All';
                              break;

                            case 1:
                              text = 'Movies';
                              break;

                            case 2:
                              text = 'Tv';
                              break;

                            default:
                              text = '';
                              break;
                          }
                          return SizedBox(
                            width: 150,
                            child: Center(child: Text(text,style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto'))),
                          );
                        }),
                  ),
                ],
              ),

              _isSearching ? _buildSearchResults() : Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),

                    userId==null ? Center(child: CircularProgressIndicator(color: Colors.white)) : Expanded(
                      child: SizedBox(
                        child: StreamBuilder(
                            stream: _returnSnapshots(userId!),
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return Center(child: CircularProgressIndicator(color: Colors.white));
                              }else if(snapshot.hasError){
                                return Center(child: Text('Data fetching error'));
                              }else if(!snapshot.data!.exists){
                                return Center(child: Text("User data does not exists"));
                              } else if(snapshot.hasData){
                                List watchlist = snapshot.data?['watchlist'] ?? [];
                                if(currentIndex == 0){
                                  userWatchList.clear();
                                  userWatchList = watchlist;
                                }else if(currentIndex == 1){
                                  userWatchList.clear();
                                  if(watchlist.isNotEmpty){
                                    for(var item in watchlist){
                                      if(item['mediaType'] == 'movie'){
                                        userWatchList.add(item);
                                      }
                                    }
                                  }else{
                                    userWatchList = [];
                                  }
                                }else if(currentIndex == 2){
                                  userWatchList.clear();
                                  if(watchlist.isNotEmpty){
                                    for(var item in watchlist){
                                      if(item['mediaType'] == 'tv'){
                                        userWatchList.add(item);
                                      }
                                    }
                                  }else{
                                    userWatchList = [];
                                  }
                                }
                                return userWatchList.isEmpty ? Center(child: Text("Nothing in Watchlist",
                                    style: TextStyle(color: Colors.white,fontFamily: 'Roboto'))) : GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                    scrollDirection: Axis.vertical,
                                    itemCount: userWatchList.length,
                                    itemBuilder: (context, index) {
                                      var mediaId = userWatchList[index]['mediaId'];
                                      var mediaType = userWatchList[index]['mediaType'];
                                      var img = userWatchList[index]['imgPath'] ?? defaultShowUrl;
                                      return GestureDetector(
                                        onTap: (){
                                          try{
                                            print('Media id is $mediaId');
                                            print('Media type is $mediaType');
                                            print("Img path is $img");
                                            Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(id: mediaId.toString(), type: mediaType)));
                                          }catch (e){
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong $e")));
                                          }
                                        },
                                        child: Container(
                                          height: 350,
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: Image.network(
                                                  img,fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                                                  return ClipRRect(borderRadius: BorderRadius.circular(5),child: Image.network(defaultShowUrl,fit: BoxFit.cover));
                                                },
                                                ),
                                              ),

                                              Positioned(
                                                  top : 5,
                                                  left: 5,
                                                  child: IconButton(onPressed: () async{
                                                    await DatabaseOptions().removeFromWatchlist(userId!,userWatchList[index]['mediaId'],userWatchList[index]['mediaType']);
                                                  }, icon: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.bookmark_remove,color: Colors.white)))),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }else{
                                return Text('Some exception caught');
                              }
                            }
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(){
    if(_isloading){
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if(searchResults.isEmpty){
      return Center(
        child: currentIndex == 0 ? Text('No matching result found',style: TextStyle(color: Colors.white)) :
        currentIndex == 1 ? Text('No matching movie found',style: TextStyle(color: Colors.white)) : Text('No matching tv found',style: TextStyle(color: Colors.white))
      );
    }

    return Expanded(
      child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          scrollDirection: Axis.vertical,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            var mediaId = searchResults[index]['mediaId'];
            var mediaType = searchResults[index]['mediaType'];
            var img = searchResults[index]['imgPath'];
            return GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(id: mediaId.toString(), type: mediaType)));
              },
              child: Container(
                height: 350,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        img,fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                        return ClipRRect(borderRadius: BorderRadius.circular(5),child: Image.network(defaultShowUrl,fit: BoxFit.cover));
                      },
                      ),
                    ),

                    Positioned(
                        top : 5,
                        left: 5,
                        child: IconButton(onPressed: () async{
                          await DatabaseOptions().removeFromWatchlist(userId!,searchResults[index]['mediaId'],searchResults[index]['mediaType']);
                        }, icon: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.bookmark_remove,color: Colors.white)))),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
