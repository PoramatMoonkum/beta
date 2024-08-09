import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/history/propage.dart';
import 'package:pettakecare/view/history/propet.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';

class RatingVote extends StatefulWidget {
  const RatingVote({super.key});

  @override
  State<RatingVote> createState() => _RatingVoteState();
}

class _RatingVoteState extends State<RatingVote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Review',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: MaterialButton(
            height: 50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.purple,
            onPressed: () {
              CustomRatingBottomSheet.showFeedbackBottomSheet(context: context);
            },
            child: const Text('Review'),
          ),
        ),
      ),
    );
  }
}

class CustomRatingBottomSheet {
  CustomRatingBottomSheet._();

  static Future<void> showFeedbackBottomSheet({
    required BuildContext context,
  }) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double rating = 0.0;

    return showModalBottomSheet<void>(
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: width,
            height: height * 0.55,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'ให้คะแนนความพึงพอใจ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 4,
                    textAlign: TextAlign.center,
                  ),
                ),
                RatingBar.builder(
                  unratedColor: Colors.grey.shade400,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (newRating) {
                    rating = newRating;
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap the star',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 25,
                ),
                const RoundTextfield(
                  hintText: "Your Comment",
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // ปิด bottom sheet
                      Navigator.pop(context);

                      // นำทางไปยังหน้า ProfilePage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomeView()),
                        (route) => route.isFirst,
                      );
                    },
                    child: Text('ตกลง'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
