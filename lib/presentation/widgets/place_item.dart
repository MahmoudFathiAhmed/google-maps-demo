import 'package:flutter/material.dart';
import 'package:google_maps_demo/constants/my_colors.dart';
import 'package:google_maps_demo/data/models/place_suggestion.dart';

class PlaceItem extends StatelessWidget {
  final PlaceSuggestion suggestion;

  const PlaceItem({Key? key, required this.suggestion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subTitle = suggestion.description
        .replaceAll(suggestion.description.split(',')[0], '');
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.all(8),
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
          color: MyColors.darkBcGrnd.withOpacity(.7),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: MyColors.darkGrey),
              child: Icon(
                Icons.place,
                color: MyColors.paleGreen,
              ),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${suggestion.description.split(',')[0]}\n',
                    style: TextStyle(
                        color: MyColors.lightGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: subTitle.substring(2),
                    style: const TextStyle(
                      color: MyColors.lightGrey,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
