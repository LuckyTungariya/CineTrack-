import 'package:flutter/material.dart';
import 'package:tmdbmovies/Apiservice.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/allseasons.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailPage extends StatefulWidget {
  String id,type;
  DetailPage({super.key, required this.id, required this.type});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late YoutubePlayerController _youtubePlayerController;
  late bool isVideoPlaying;
  late String? userId;
  bool isAdded = false;
  bool isloading = false;
  Map<dynamic,dynamic> indiaWatchProviders = {};
  Map<dynamic,dynamic> usWatchProviders = {};
  Map<dynamic,dynamic> watchProviders = {};
  late String key;
  Map<dynamic,dynamic> detailsArray = {};
  late var id = widget.id;
  late var type = widget.type;
  final imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final defaultImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png';
  final defaultShowUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png';
  late Future<Map<dynamic,dynamic>> detailsUrl;
  String? videoUrl;

  @override
  void initState() {
    super.initState();
    getUserId();
    isVideoPlaying = false;
    if(type == 'person'){
      detailsUrl = ApiService().fetchDetails('https://api.themoviedb.org/3/$type/$id?language=en-US&append_to_response=images,movie_credits,tv_credits');
    }else{
      detailsUrl = ApiService().fetchDetails('https://api.themoviedb.org/3/$type/$id?language=en-US&append_to_response=videos,credits,similar,watch/providers');
    }
  }
  
  void getUserId() async{
    userId = await SharedPreferenceHelper().getUserId();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
          future: detailsUrl,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }else if(snapshot.hasError){
              return Text("Error fetching the content");
            }else if(snapshot.hasData){
              detailsArray = snapshot.data!;
              final String posterPath;
              final String department;
              type == 'person' ? department = detailsArray['known_for_department'] ?? 'Not available' : department = '';
              (type == 'movie' || type == 'tv') ? posterPath = '$imageBaseUrl${detailsArray['poster_path']}' : posterPath = '$imageBaseUrl${detailsArray['profile_path']}';
              final String title;
              type == 'movie' ? title = detailsArray['title'] : title = detailsArray['name'] ?? 'Not available';
              final String releaseDate;
              type == 'movie' ? releaseDate = detailsArray['release_date'].toString() : type == 'tv' ? releaseDate = detailsArray['first_air_date'].toString() : releaseDate = '';
              final String revenue;
              type == 'movie' ? revenue = detailsArray['revenue'].toString() : revenue = '';
              final List videos = (type == 'movie' || type == 'tv') ? (detailsArray['videos']?['results'] ?? []) : [];
              final List seasons = (type == 'tv') ? (detailsArray['seasons'] ?? []) : [];
              final String totalSeasons;
              type == 'tv' ? totalSeasons = detailsArray['number_of_seasons'].toString() : totalSeasons = '';
              final List cast = (type == 'movie' || type == 'tv') ? (detailsArray['credits']?['cast'] ?? []) : (detailsArray['movie_credits']?['cast'] ?? []);
              final List tvCredits = (type == 'person') ? (detailsArray['tv_credits']?['cast'] ?? []) : [];
              final List similar = (type == 'movie' || type == 'tv') ? (detailsArray['similar']?['results'] ?? []) : [];
              final String voteCount;
              (type == 'movie' || type == 'tv' ) ? voteCount = detailsArray['vote_count'].toString() : voteCount = '';
              final String status;
              (type == 'movie' || type == 'tv' ) ? status = detailsArray['status'] : status = '';
              final String overView;
              (type == 'movie' || type == 'tv' ) ? overView  = detailsArray['overview'] : overView = detailsArray['biography'] ?? 'No biography available';
              final id = detailsArray['id'];
              indiaWatchProviders = detailsArray['watch/providers']?['results']?['IN'] ?? {};
              usWatchProviders = detailsArray['watch/providers']?['results']?['US'] ?? {};
              watchProviders = {
                ...indiaWatchProviders,
                ...usWatchProviders
              };
              String link;
              List<dynamic> flatRate;
              watchProviders.isNotEmpty ? link = watchProviders['link'] : link='' ;
              watchProviders.isNotEmpty ? flatRate = (watchProviders['flatrate'] ?? watchProviders['buy']) ?? [] : flatRate = [];
              final belongToCollection = (type == 'movie') ? detailsArray['belongs_to_collection'] ?? [] : [];
              if(belongToCollection.isNotEmpty && belongToCollection!=null){
                  final collectionId = detailsArray['belongs_to_collection']['id'];
                  final collectionName = detailsArray['belongs_to_collection']['name'];
              }
              final String budget;
              if(type == 'movie'){
                budget = detailsArray['budget'].toString();
              }
              // final video = detailsArray['video'];
              return Container(
                decoration: BoxDecoration(color:  AppDesign().bgColor),
                width: w,
                child: Stack(
                  children: [
                    (isVideoPlaying == true && key!='') ? YoutubePlayerBuilder(player: YoutubePlayer(
                controller: _youtubePlayerController,
                    aspectRatio: 16/10,
                    width: MediaQuery.of(context).size.width,
                    progressIndicatorColor: AppDesign().textColor,
                    showVideoProgressIndicator: true),
                  builder: (context,player){
                    return Column(
                      children: [
                        SizedBox(height: 0,width: 0),
                        player,
                        SizedBox(height: 0,width: 0),
                      ],
                    );
                  }) : Container(
                      height: 250,
                      width: w,
                      decoration: BoxDecoration(
                          color: AppDesign().bgColor,
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(posterPath,fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                            return (type == 'movie' || type == 'tv') ? Image.network(defaultShowUrl,fit: BoxFit.cover) : Image.network(defaultImageUrl,fit: BoxFit.cover);
                          },)),
                    ),

                    Positioned(
                        top : 20,
                        left: 15,
                        child: IconButton(onPressed: (){
                          Navigator.pop(context);
                        }, icon: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.arrow_back_rounded,color: Colors.white)))),

                    (type == 'movie' || type == 'tv') ? isVideoPlaying ? SizedBox(height: 0) : Positioned(
                      top: 100,
                      left: 150,
                      child: IconButton(onPressed: (){
                        if(videos.isNotEmpty){
                          for(var video in videos){
                            if((video['type'] == 'Trailer' && video['site'] == 'YouTube')||(video['type'] == 'Clip' && video['site'] == 'YouTube')){
                              key = video['key'];
                              break;
                            }
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Youtube video not found")));
                        }

                        if(key!='') {
                          _youtubePlayerController = YoutubePlayerController(
                              initialVideoId: key,
                              flags: YoutubePlayerFlags(
                                mute: false,
                                forceHD: true,
                                autoPlay: false,
                                showLiveFullscreenButton: true,
                              ));

                          setState(() {
                            isVideoPlaying = true;
                          });
                        }
                      }, icon: CircleAvatar(backgroundColor: Colors.black,radius: 25,child: Icon(Icons.play_arrow,size: 50,color: Colors.white))),
                    ) : Text(''),

                    Padding(
                      padding: EdgeInsets.only(
                        top: w / 1.5,
                        bottom: 0,
                        left: 0,
                        right: 0,
                      ),
                      child: Container(
                        width: w,
                        height: h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadiusGeometry.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10,left: 8,right: 8,bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(title,style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 18)),
                                Text(type == 'movie' ? 'Release Date : $releaseDate' : (type == 'tv') ? 'First Air Date : $releaseDate' : 'Department : $department' ,style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal,fontSize: 18)),
                                type == 'movie' ? Text('Revenue : $revenue',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal,fontSize: 18)) : type == 'tv' ? Text('Total Seasons : $totalSeasons',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal,fontSize: 18)) : Text(''),
                                (type == 'movie' || type == 'tv') ? SizedBox(height: 20) : SizedBox(height: 0),
                                (type == 'movie' || type == 'tv') ?
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(onPressed: () async {
                                        setState(() {
                                          isAdded = !isAdded;
                                        });
                                        print('User id is $userId');
                                        setState(() {
                                          isloading = true;
                                        });
                                        isAdded ? await DatabaseOptions().addToWatchlist(userId!,id.toString(),title,type,posterPath) : await DatabaseOptions().removeFromWatchlist(userId!, id.toString(), type);
                                        setState(() {
                                          isloading = false;
                                        });
                                      },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(10),
                                            backgroundColor: AppDesign().primaryAccent,
                                          ),
                                          child: Row(
                                            spacing: 5,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: isloading ? [
                                              Center(child: CircularProgressIndicator(color: Colors.black))
                                            ] : [
                                              isAdded ? Icon(Icons.check,color: Colors.white) : Icon(Icons.add,color: Colors.white),
                                              Text(isAdded ? "Added to watchlist" : "Add to watchlist",style: TextStyle(color: Colors.white,fontFamily: 'Roboto'))
                                            ],
                                          )),
                                    ) : SizedBox(height: 0),

                                (type == 'movie' || type == 'tv') ? Align(
                                  alignment: Alignment.centerLeft,
                                    child: Text("Overview",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))) : (overView == 'No biography available') ? SizedBox(height: 0) : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Biography",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))),

                                Align(
                                  alignment: Alignment.centerLeft,
                                    child: Text(overView,style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal,fontSize: 12))),

                                SizedBox(height: 10),

                                cast.isNotEmpty ? (type == 'movie' || type == 'tv' ) ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Cast",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))) : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Movie Cast",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))) : SizedBox(height: 0),

                                  cast.isNotEmpty ? (type == 'movie' || type == 'tv') ? SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    itemCount: cast.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 120,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 1.5,
                                        children: [
                                          ClipRRect(
                                              borderRadius: BorderRadius.circular(25),
                                                child: Image.network('$imageBaseUrl${cast[index]['profile_path']}',fit: BoxFit.cover,height: 50,width: 50,errorBuilder: (context, error, stackTrace) {
                                                  return (type == 'movie' || type == 'tv') ? Image.network(defaultShowUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white) : Image.network(defaultImageUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white);
                                                })),
                                          Text(cast[index]['name'],style: TextStyle(color: AppDesign().textColor,fontWeight: FontWeight.normal,fontSize: 12))
                                        ],
                                      ),
                                    );
                                  }),
                                ) : SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                        itemCount: cast.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(id: cast[index]['id'].toString(), type: 'movie')));
                                              },
                                              child: SizedBox(
                                                width: 200,
                                                height: 120,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  spacing: 1.5,
                                                  children: [
                                                    SizedBox(
                                                      width : 200,
                                                      child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(5),
                                                          child: Image.network('$imageBaseUrl${cast[index]['poster_path']}',fit: BoxFit.fill,height: 100,width: 50,errorBuilder: (context, error, stackTrace) {
                                                            return Image.network(defaultImageUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white);
                                                          })),
                                                    ),
                                                    Text(cast[index]['title'],style: TextStyle(color: AppDesign().textColor,fontWeight: FontWeight.normal,fontSize: 12),maxLines: 1)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ) : SizedBox(height: 0),

                                (type == 'person' && tvCredits.isNotEmpty) ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Tv Cast",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))) : SizedBox(height: 0),

                                (type == 'person' && tvCredits.isNotEmpty) ? SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                      itemCount: tvCredits.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(id: tvCredits[index]['id'].toString(), type: 'tv')));
                                            },
                                            child: SizedBox(
                                              width: 200,
                                              height: 150,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 1.5,
                                                children: [
                                                  SizedBox(
                                                    width : 200,
                                                    height: 120,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(5),
                                                        child: Image.network('$imageBaseUrl${tvCredits[index]['poster_path']}',fit: BoxFit.fill,height: 50,width: 50,errorBuilder: (context, error, stackTrace) {
                                                          return Image.network(defaultImageUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white);
                                                        })),
                                                  ),
                                                  Text(tvCredits[index]['name'],style: TextStyle(color: AppDesign().textColor,fontWeight: FontWeight.normal,fontSize: 12),maxLines: 1)
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ) : SizedBox(height: 0),

                                (type == 'movie' || type == 'tv') ? flatRate.isNotEmpty ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Available On",style: TextStyle(color: AppDesign().textColor,
                                      fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)),
                                ) : SizedBox(height: 0) : SizedBox(height: 0),

                                (type == 'movie' || type == 'tv') ? flatRate.isNotEmpty ? Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                  ),
                                  child: ListView.builder(
                                    itemCount:  flatRate.length,
                                    padding: EdgeInsets.only(bottom: 5),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          padding: EdgeInsets.only(right: 10,bottom: 5),
                                          decoration: BoxDecoration(
                                              color: AppDesign().bgColor,
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          width: MediaQuery.of(context).size.width,
                                          height: 100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                margin: EdgeInsets.all(5),
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Image.network('$imageBaseUrl${flatRate[index]['logo_path']}',fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                                                      return Image.network(defaultShowUrl,fit: BoxFit.fill);
                                                    })),
                                              ),

                                              Expanded(
                                                child: Text(flatRate[index]['provider_name'],
                                                    style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                                        fontSize: 18,fontWeight: FontWeight.bold)),
                                              ),

                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: ElevatedButton(onPressed: () async{
                                                    if((link!='') && await(canLaunchUrl(Uri.parse(link)))){
                                                      await launchUrl(Uri.parse(link),mode: LaunchMode.externalApplication);
                                                    }else{
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Url cannot be launched')));
                                                    }
                                                  },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppDesign().primaryAccent,
                                                      ),
                                                      child: type == 'movie'  ? Text('Watch full movie',style: TextStyle(color: Colors.white)) : Text('Watch full series',style: TextStyle(color: Colors.white))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },),
                                ) : SizedBox(height: 0) : SizedBox(height: 0),

                                similar.isNotEmpty ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(type == 'movie' ? "Similar Movies" : "Similar Tv",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,fontSize: 18))) : SizedBox(height: 0),

                                similar.isNotEmpty ? SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: similar.length,
                                    itemBuilder: (context, index) {
                                    return SizedBox(
                                      height: 110,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                detailsUrl = ApiService().fetchDetails('https://api.themoviedb.org/3/$type/${similar[index]['id']}?language=en-US&append_to_response=videos,credits,similar');
                                                isVideoPlaying = false;
                                                key = '';
                                              });
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              color: Colors.white,
                                              elevation: 5,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  '$imageBaseUrl${similar[index]['poster_path']}',
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.network(
                                                      defaultImageUrl,fit: BoxFit.cover,
                                                    );
                                                  },
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ) : SizedBox(height: 0),

                                type == 'tv' ? SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(onPressed: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => AllEpisodes(name: title,imgUrl: posterPath,noOFSeasons: totalSeasons,seasons: seasons,id: id.toString())));
                                  },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppDesign().primaryAccent,
                                      ),
                                      child: Text("View all seasons",style: TextStyle(color: AppDesign().textColor))),
                                ) : SizedBox(height: 0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }else{
              return Text("No data available");
            }
          })
    );
  }
}
