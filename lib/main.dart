import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<XmlElement> _newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('https://kilimonews.co.ke/agribusiness/feed/'));
      if (response.statusCode == 200) {
        final xmlString = response.body;
        final document = XmlDocument.parse(xmlString);
        final items = document.findAllElements('item') as List<XmlElement>;
        setState(() {
          _newsList = items;
        });
      } else {
        // Handle error for non-200 status codes
      }
    } catch (error) {
      // Handle network or parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: ListView.builder(
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          final newsItem = _newsList[index];
          final title = newsItem.findElements('title').first.text;
          final description = newsItem.findElements('description').first.text;
          final imageUrl = _extractImageUrl(description);

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(title),
              subtitle: imageUrl != null
                  ? CachedNetworkImage(imageUrl: imageUrl)
                  : SizedBox.shrink(),
              onTap: () {
                // Handle tap event for a news item
              },
            ),
          );
        },
      ),
    );
  }

  String? _extractImageUrl(String description) {
    final regExp = RegExp(r'<img[^>]+src="([^"]+)"');
    final match = regExp.firstMatch(description);
    return match?.group(1);
  }
}
