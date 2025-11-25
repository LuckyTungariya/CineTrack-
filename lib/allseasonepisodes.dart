import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdbmovies/Apiservice.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/singleepisode.dart';

class AllSeasonEpisodes extends StatefulWidget {
  String name,seasonNumber,id;
  AllSeasonEpisodes({super.key , required this.name, required this.seasonNumber,required this.id});

  @override
  State<AllSeasonEpisodes> createState() => _AllSeasonEpisodesState();
}

class _AllSeasonEpisodesState extends State<AllSeasonEpisodes> {
  late final id = widget.id;
  late final seasonNumber = widget.seasonNumber;
  late final String detailsUrl;
  Map<dynamic,dynamic> detailsArray = {};
  Map<dynamic,dynamic> indiaWatchProviders = {};
  Map<dynamic,dynamic> usWatchProviders = {};
  List<dynamic> episodesArray = [];
  Map<dynamic,dynamic> watchProviders = {};
  final imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final defaultShowUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png';

  @override
  void initState() {
    super.initState();
    detailsUrl = 'https://api.themoviedb.org/3/tv/${widget.id}/season/${widget.seasonNumber}?append_to_response=watch/providers';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        backgroundColor: AppDesign().bgColor,
        iconTheme: IconThemeData(
          color: AppDesign().textColor
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name,style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)),
            Text('Season ${widget.seasonNumber}',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 18,fontWeight: FontWeight.normal))
          ],
        ),
      ),
      body: FutureBuilder(
        future: ApiService().fetchContent(detailsUrl),
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
            return Center(child: Text("Data fetching error"));
          }else if(snapshot.hasData){
            detailsArray = snapshot.data!;
            episodesArray = detailsArray['episodes'] ?? [];
            indiaWatchProviders = detailsArray['watch/providers']?['results']?['IN'] ?? {};
            usWatchProviders = detailsArray['watch/providers']?['results']?['US'] ?? {};
            watchProviders = {
              ...indiaWatchProviders,
              ...usWatchProviders
            };
            print(watchProviders);
            String link;
            List<dynamic> flatRate;
            watchProviders.isNotEmpty ? link = watchProviders['link'] : link='' ;
            watchProviders.isNotEmpty ? flatRate = watchProviders['flatrate'] ?? watchProviders['buy'] : flatRate = [];
            return episodesArray.isNotEmpty ? ListView.builder(
              itemCount: episodesArray.length,
                itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8,bottom: 8,top: 8),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SingleEpisodePage(seriesId: widget.id,
                        seasonNumber: episodesArray[index]['season_number'].toString(),
                        episodeNumber: episodesArray[index]['episode_number'].toString(),
                        episodeName: episodesArray[index]['name'],
                        link: link,
                        flatrate: flatRate)));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width : 100,
                          height: 80,
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.all(5),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network('$imageBaseUrl${episodesArray[index]['still_path']}',fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                                  return Image.network(defaultShowUrl,fit: BoxFit.fill);
                                })),
                          ),
                        ),
                              
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Episode ${episodesArray[index]['episode_number'].toString()}",
                                  style: TextStyle(color: AppDesign().primaryAccent,fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.normal)),
                              
                              Text("${episodesArray[index]['name']}",
                                  style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.bold),maxLines: 1),
                              
                              Text("${episodesArray[index]['overview']}",
                                  softWrap: true,
                                  style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal,overflow: TextOverflow.ellipsis),maxLines: 1)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }) : Center(child: Text("No episodes for this season",
                style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.bold)));
          }else{
            return Center(child: Text("Something internet error"));
          }
        },
      )
    );
  }
}
