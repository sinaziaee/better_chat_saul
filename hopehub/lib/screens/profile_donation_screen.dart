import 'package:flutter/material.dart';

import 'ProfileVolunteeringsScreen.dart';
import 'donate_items_screen.dart';

class ProfileDonationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deposits"),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.blue),
                    title: Text("Deposits"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Volunteering"),
                Card(
                  child: ListTile(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profilevolunteeringsscreen()),
                      );
                    },
                    leading: Icon(Icons.attach_money, color: Colors.blue),
                    title: Text("Volunteering"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Donations"),
                Card(
                  child: ListTile(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => DonateItemScreen()),
                      // );
                    },
                    leading: Icon(Icons.card_giftcard_outlined, color: Colors.blue),
                    title: Text("Previous Dontations"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DonateItemScreen()),
                      );
                    },
                    leading: Icon(Icons.wallet_giftcard_outlined, color: Colors.blue),
                    title: Text("New Donations"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
