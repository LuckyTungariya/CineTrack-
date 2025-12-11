import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdbmovies/Apiservice.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SingleEpisodePage extends StatefulWidget {
  String seriesId,seasonNumber,episodeNumber,episodeName,link;
  List<dynamic> flatrate;
  SingleEpisodePage({super.key,required this.seriesId,required this.seasonNumber,required this.episodeNumber,required this.episodeName,required this.link,required this.flatrate});

  @override
  State<SingleEpisodePage> createState() => _SingleEpisodePageState();
}

class _SingleEpisodePageState extends State<SingleEpisodePage> {
  late final String detailsUrl;
  late YoutubePlayerController _youtubePlayerController;
  late bool isVideoPlaying;
  late String key;
  late String? userId;
  String id = '';
  bool _isloading = false;
  bool isAdded = false;
  List<String>? addedMedia;
  Map<dynamic,dynamic> detailsArray = {};
  late Future<Map<dynamic, dynamic>> _episodeFuture;
  final imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final defaultImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png';
  final defaultShowUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png';

  @override
  void initState() {
    super.initState();
    _getUserId();
    detailsUrl = 'https://api.themoviedb.org/3/tv/${widget.seriesId}/season/${widget.seasonNumber}/episode/${widget.episodeNumber}?language=en-US&append_to_response=credits,videos';
    _episodeFuture = ApiService().fetchContent(detailsUrl);
    isVideoPlaying = false;
  }

  void _getUserId() async{
    userId = await SharedPreferenceHelper().getUserId();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        backgroundColor: AppDesign().bgColor,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(widget.episodeName,style: TextStyle(color: AppDesign().textColor,
            fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20)),
      ),
      body: FutureBuilder(
          future: _episodeFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade800,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                    ),
                  ));
            }else if(snapshot.hasError){
              return Center(child: Text("Error loading data",style: TextStyle(color: Colors.white)));
            }else if(snapshot.hasData){
              detailsArray = snapshot.data!;
              var title = detailsArray['name'] ?? 'Not available';
              var posterPath = detailsArray['still_path']!=null ? '$imageBaseUrl${detailsArray['still_path']}' : defaultShowUrl;
              id = detailsArray['id'].toString();
              List crew = detailsArray['crew'];
              List cast = detailsArray['credits']?['cast'] ?? [];
              List videos = detailsArray['videos']?['results'] ?? [];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Stack(
                            children: [
                              isVideoPlaying ? YoutubePlayerBuilder(player: YoutubePlayer(
                                  controller: _youtubePlayerController,
                                  aspectRatio: 16/9,
                                  width: MediaQuery.of(context).size.width,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.white),
                                  builder: (context, player){
                                    return Column(
                                      children: [
                                        SizedBox(height: 0,width: 0),
                                        player,
                                        SizedBox(height: 0,width: 0)
                                      ],
                                    );
                                  },) : Image.network('$imageBaseUrl${detailsArray['still_path']}',fit: BoxFit.fill,
                                      errorBuilder: (context, error, stackTrace) {
                                    return Image.network(defaultShowUrl,fit: BoxFit.fill);
                                  }),

                              isVideoPlaying ? Text('') : Positioned(
                                  top : 70,
                                  left: 150,
                                  child: IconButton(onPressed: (){
                                    if(videos.isNotEmpty){
                                      for(var video in videos){
                                        if(video['site'] == 'YouTube' && video['type'] == 'Clip'){
                                          key = video['key'];
                                          print('Key $key');
                                          break;
                                        }else{
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Episode Clip not available')));
                                        }
                                      }

                                      if(key!=''){
                                        _youtubePlayerController = YoutubePlayerController(
                                          initialVideoId: key,
                                          flags: YoutubePlayerFlags(
                                            showLiveFullscreenButton: true,
                                            autoPlay: false,
                                            forceHD: true,
                                            mute: false,
                                          )
                                        );
                                        
                                        setState(() {
                                          isVideoPlaying = true;
                                        });
                                      }
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Episode clip not found')));
                                    }
                                  }, icon: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.play_arrow,color: Colors.white)))),],
                      )),

                      Container(
                          color: AppDesign().bgColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(detailsArray['name'] ?? 'Not Available',style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Text("Air Date",style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal)),
                                  Text(detailsArray['air_date'] ?? 'Not available',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal))
                                ],
                              ),

                              SizedBox(
                                height: 20,
                              ),

                              Text("Synopsis",style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)),

                              (detailsArray['overview']!=null || detailsArray['overview']!='') ? Text(detailsArray['overview'],style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontWeight: FontWeight.normal)) : Text("Overview not available",style: TextStyle(color: AppDesign().textColor)),

                              SizedBox(
                                height: 5,
                              ),

                              crew.isNotEmpty ? Text("Crew",style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)) : Text(''),

                              crew.isNotEmpty ? SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    itemCount: crew.length,
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
                                                child: Image.network('$imageBaseUrl${detailsArray['crew'][index]['profile_path']}',fit: BoxFit.cover,height: 50,width: 50,errorBuilder: (context, error, stackTrace) {
                                                  return Image.network(defaultImageUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white);
                                                })),
                                            Text(detailsArray['crew'][index]['name'],style: TextStyle(color: AppDesign().textColor,fontWeight: FontWeight.normal,fontSize: 12))
                                          ],
                                        ),
                                      );
                                    }),
                              ) : Text(''),

                              cast.isNotEmpty ? Text("Cast",style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)) : Text(''),

                              cast.isNotEmpty ? SizedBox(
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
                                                  return Image.network(defaultImageUrl,fit: BoxFit.cover,height: 50,width: 50,color: Colors.white);
                                                })),
                                            Text(cast[index]['name'],style: TextStyle(color: AppDesign().textColor,fontWeight: FontWeight.normal,fontSize: 12))
                                          ],
                                        ),
                                      );
                                    }),
                              ) : Text(''),

                              widget.flatrate.isNotEmpty ? Text("Available On",style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)) : SizedBox(height: 0),

                              widget.flatrate.isNotEmpty ? Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppDesign().bgColor,
                                ),
                                child: ListView.builder(
                                  itemCount: widget.flatrate.length,
                                  padding: EdgeInsets.only(bottom: 5),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Container(
                                        padding: EdgeInsets.only(right: 10,bottom: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
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
                                                  child: Image.network('$imageBaseUrl${widget.flatrate[index]['logo_path']}',fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                                                    return Image.network(defaultShowUrl,fit: BoxFit.fill);
                                                  })),
                                            ),

                                            Expanded(
                                              child: Text(widget.flatrate[index]['provider_name'],
                                                  style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',
                                                      fontSize: 18,fontWeight: FontWeight.bold)),
                                            ),

                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(onPressed: () async{
                                                  if((widget.link!='') && await(canLaunchUrl(Uri.parse(widget.link)))){
                                                    await launchUrl(Uri.parse(widget.link),mode: LaunchMode.externalApplication);
                                                  }else{
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Url cannot be launched')));
                                                  }
                                                },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppDesign().primaryAccent,
                                                    ),
                                                    child: Icon(Icons.arrow_circle_right,color: Colors.white)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                },),
                              ) : SizedBox(height: 0)

                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }else{
              return Center(child: Text("Data fetching error"));
            }
          }),
    );
  }
}
