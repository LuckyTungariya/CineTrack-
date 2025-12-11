import 'package:flutter/material.dart';
import 'package:tmdbmovies/allseasonepisodes.dart';
import 'package:tmdbmovies/appdesign.dart';

class AllEpisodes extends StatefulWidget {
  String name,imgUrl,noOFSeasons,id;
  List seasons;
  AllEpisodes({super.key, required this.name,required this.imgUrl,required this.noOFSeasons,required this.seasons,required this.id});

  @override
  State<AllEpisodes> createState() => _AllEpisodesState();
}

class _AllEpisodesState extends State<AllEpisodes> {
  final imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final defaultShowUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      body: Expanded(
        child: Container(
          color: AppDesign().bgColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height/2.3,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(widget.imgUrl,fit: BoxFit.fill),
                ),
              ),
        
              Positioned(
                top : 30,
                  left: 15,
                  child: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.arrow_back_rounded,color: Colors.white)))),
        
              Positioned(
                top : MediaQuery.of(context).size.height/2.5,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppDesign().bgColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  height: 500,
                  child: ListView.builder(
                    itemCount: int.parse(widget.noOFSeasons),
                      itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8,bottom: 8),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width : 100,
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                margin: EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                    child: Image.network('$imageBaseUrl${widget.seasons[index]['poster_path']}',fit: BoxFit.fill,errorBuilder: (context, error, stackTrace) {
                                      return Image.network(defaultShowUrl,fit: BoxFit.fill);
                                    })),
                              ),
                            ),
        
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Season ${widget.seasons[index]['season_number']}",
                                    style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 20,fontWeight: FontWeight.bold)),
        
                                Text("${widget.seasons[index]['episode_count']} Episodes",
                                    style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal)),
        
                                Text("Aired ${widget.seasons[index]['air_date']}",
                                    style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.normal))
                              ],
                            ),
        
                            ElevatedButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AllSeasonEpisodes(name: widget.name,seasonNumber: widget.seasons[index]['season_number'].toString(),id: widget.id)));
                            },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppDesign().primaryAccent
                                ),
                                child: Icon(Icons.arrow_circle_right,color: Colors.white))
                          ],
                        ),
                      ),
                    );
                  }),
                  ),
                ),
            ],
          )
        ),
      ),
    );
  }
}
