import 'package:flutter/material.dart';

@override
Widget CustomCharityCard({required String title, required String subtitle, required String imageUrl, required List allCauses, required String location, required String address}) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: [
        SizedBox(height: 4,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            // SizedBox(width: 16),
            Column(
              children: allCauses
                  .map(
                    (cause) => Container(
                  child: Text(
                    cause,
                    style: TextStyle(color: Colors.white),
                  ),
                  margin: EdgeInsets.only(bottom: 8),
                  padding:
                  EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
                  .toList(),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.location_city, color: Colors.blue),
            ),
            // SizedBox(width: 16),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1),
        Text(
          address,
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
      ],
    ),
  );
}
