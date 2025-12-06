import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/detailpage.dart';
import 'package:tmdbmovies/notification_services.dart';
import 'package:once/once.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:shimmer/shimmer.dart';
import 'Apiservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationServices services = NotificationServices();

  String? usr;
  final List<String> trendingHints = [
    'Search anything',
    'Search popular people',
    'Search rated movies',
    'Search popular tv'
  ];
  final List<String> movieHints = [
    'Search top movies',
    'Search popular movies',
    'Search upcoming movies',
    'Search movies now playing'
  ];
  final List<String> tvHints = [
    'Search rated tv show',
    'Search airing today',
    'Search popular movies',
    'Search on the air tv'
  ];
  int currentIndex = 0;
  TextEditingController searchField = TextEditingController();
  Map<dynamic,dynamic> trendingContentArray = {};
  bool _isloading = false;
  bool _isSearching = false;
  List<dynamic> searchResults = [];
  final baseUrl = 'https://image.tmdb.org/t/p/w500';
  final defaultImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png';

  @override
  void initState() {
    super.initState();
    Once.runOnce("Ask Permission",
        callback: () => services.requestUserAboutNotify());
    getUserName();
  }

  Future<void> getUserName() async{
    var nm = await SharedPreferenceHelper().getUsername();
    usr = nm!;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        leading: ClipOval(child: Image.asset("assets/usedIcons/onlyappico.png")),
        backgroundColor: Colors.black,
        titleSpacing: 2,
        title: Text("WELCOME $usr",style: TextStyle(fontFamily: 'Roboto',fontSize: 18,fontWeight: FontWeight.bold,color: AppDesign().textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(height: 0.5,
            color: AppDesign().bgColor),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchField,
                style: TextStyle(color: AppDesign().textColor),
                decoration: InputDecoration(
                  suffixIcon: searchField.text.isNotEmpty  ? IconButton(onPressed: (){
                    searchField.clear();
                    setState(() {
                      _isloading = false;
                      _isSearching = false;
                    });
                  },
                      icon: Icon(Icons.clear,color: Colors.white)) : null,
                  hintText: currentIndex == 0 ? 'Search any category' : (currentIndex == 1) ? 'Search top movies' : 'Search top tv shows',
                  hintStyle : TextStyle(color: AppDesign().secondaryTextColor,fontWeight: FontWeight.normal),
                  fillColor: AppDesign().secondaryTextColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: AppDesign().textColor
                      )
                  ),
                ),
                onChanged: (value) {
                  currentIndex == 0 ? searchContent(value,'https://api.themoviedb.org/3/search/multi') :
                      currentIndex == 1 ? searchContent(value,'https://api.themoviedb.org/3/search/movie') :
                      searchContent(value,'https://api.themoviedb.org/3/search/tv');
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
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
                  });
                },
                iconBuilder: (value) {
                    String text;
                  switch(value){
                    case 0:
                      text = 'Trending';
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
            ),

            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: AppDesign().bgColor
                ),
                child: _isSearching ? _buildSearchResults() : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: currentIndex == 0 ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("All",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),
                  
                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/trending/all/day?language=en-US")),
                  
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Movies",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),
                  
                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/trending/movie/day?language=en-US")),
                  
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Tv",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),
                  
                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/trending/tv/day?language=en-US")),
                  
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("People",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),
                  
                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/trending/person/day?language=en-US"))
                  
                    ],
                  ) : (currentIndex == 1) ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Now Playing",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/movie/now_playing?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Popular",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/movie/popular?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Top Rated",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/movie/top_rated?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Upcoming",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/movie/upcoming?language=en-US"))

                    ],
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Airing today",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/tv/airing_today?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("On The Air",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/tv/on_the_air?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Popular",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/tv/popular?language=en-US")),

                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(alignment: Alignment.topLeft
                            ,child: Text("Top Rated",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20))
                        ),
                      ),

                      _returnContent(ApiService().fetchContent("https://api.themoviedb.org/3/tv/top_rated?language=en-US"))

                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _returnContent(Future<Map<dynamic,dynamic>> futureData){
    return FutureBuilder(future: futureData,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return AspectRatio(
              aspectRatio: 16/9,
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade800,
                  child: Container(
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.grey.shade900,
                      ),
                    ),
                  )),
            );

          }else if(snapshot.hasError){
            return Text("Data fetching error");
          }else if(snapshot.hasData){
            trendingContentArray = snapshot.data!;
            List trendingResults = trendingContentArray['results'];
            return CarouselSlider.builder(itemCount: trendingResults.length,
                itemBuilder: (context, index, realIndex) {
                  final content = trendingResults[index];
                  final backDropPath = content['backdrop_path'];
                  final profilePath = content['profile_path'];
                  final image = backDropPath!=null ? '$baseUrl$backDropPath': (profilePath!=null ?'$baseUrl$profilePath' : defaultImageUrl);
                  final id = content['id'];
                  final title = content['title'];
                  final name = content['name'];
                  final media = content['media_type'];
                  final knownFor = content['known_for_department'];
                  return GestureDetector(
                    onTap: (){
                      if(currentIndex == 0){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(id: id.toString(),type: media)));
                      }else if(currentIndex == 1){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(id: id.toString(),type: 'movie')));
                      }else if(currentIndex == 2){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => DetailPage(id: id.toString(),type: 'tv')));
                      }else{
                        print('Incorrect index');
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(image,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(defaultImageUrl,fit: BoxFit.cover,color: Colors.white);
                                },
                                fit: BoxFit.cover),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(name!=null ? '$name ' : '$title ',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                                      ,fontFamily: 'Roboto',overflow: TextOverflow.ellipsis)),

                                  Text(media!=null? '- $media': '',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                                      ,fontFamily: 'Roboto',overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 16/9,
                    autoPlayCurve: Curves.easeInOut,
                    height: 200,
                    animateToClosest: true
                ));
          }else{
            print("null");
            return Text('No data available');
          }
        });
  }

  void searchContent(String query,String link) async{
    if(query.isEmpty){
      setState(() {
        _isSearching = false;
        searchResults = [];
      });
    }else{
      setState(() {
        _isSearching = true;
        _isloading = true;
      });

      final url = '$link?query=$query';
      final data = await ApiService().fetchContent(url);

      setState(() {
        searchResults = data['results'] ?? [];
        _isloading = false;
      });
    }
    }

  Widget _buildSearchResults(){
    if(_isloading){
      return AspectRatio(
        aspectRatio: 16/9,
        child: Shimmer.fromColors(
            baseColor: Colors.grey.shade900,
            highlightColor: Colors.grey.shade800,
            child: Container(
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.grey.shade900,
                ),
              ),
            )),
      );
    }

    if(searchResults.isEmpty){
      return Center(
        child: currentIndex == 0 ? Text("No matching results found",style: TextStyle(color: AppDesign().textColor,
            fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20)) :

            currentIndex == 1 ?

        Text("No matching movies found",style: TextStyle(color: AppDesign().textColor,
            fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20)) :

            Text("No matching tv found",style: TextStyle(color: AppDesign().textColor,
                fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20))
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
        itemBuilder: (context, index) {
        final id1 = searchResults[index]['id'].toString();
        final posterPath1 = currentIndex == 0 ? searchResults[index]['poster_path'] ?? searchResults[index]['profile_path'] : searchResults[index]['poster_path'] ?? [];
        final title1 = currentIndex == 0 ? searchResults[index]['name'] ?? searchResults[index]['title'] : currentIndex == 1 ? searchResults[index]['title'] ?? [] : searchResults[index]['name'] ?? [];
        final type1 = currentIndex == 0 ? searchResults[index]['media_type'] : currentIndex == 1 ? 'movie' : 'tv';
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(id: id1,
                type: type1)));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10)
            ),
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network('$baseUrl$posterPath1',fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                        return Image.network(defaultImageUrl,fit: BoxFit.cover);
                      }),
                    ),
                  ),
                ),

                // Positioned(
                //   top: 200,
                //     left: 25,
                //     child: Text(title1,
                //     style: TextStyle(color: AppDesign().textColor,
                //         fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 25)))
              ],
            ),
          ),
        ),
      );
    });

  }

}
