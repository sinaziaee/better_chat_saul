import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCharityCardUP extends StatelessWidget {
  final String imageUrl;
  final String name;
  final List allCauses;

  const CustomCharityCardUP({super.key, required this.imageUrl, required this.name, required this.allCauses});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 80,
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
            // SizedBox(height: 0),
            Text(
              name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: allCauses
                  .map(
                    (cause) => Container(
                  child: Text(
                    cause,
                    style: TextStyle(color: Colors.white),
                  ),
                  margin: EdgeInsets.only(bottom: 8, right: 4),
                  padding:
                  EdgeInsets.symmetric(horizontal: 4, vertical: 2 ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
