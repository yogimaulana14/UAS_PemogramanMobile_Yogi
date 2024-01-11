import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../shared/common_constant.dart';
import '../../../component/view_builder.dart';

@RoutePage()
class HistoryViewPoScreen extends StatefulWidget {
  const HistoryViewPoScreen({Key? key, required this.vendorCode}) : super(key: key);
  final String vendorCode;

  @override
  _HistoryViewPoScreenState createState() => _HistoryViewPoScreenState();
}

class _HistoryViewPoScreenState extends State<HistoryViewPoScreen> {
  late Future<Map<String, dynamic>> apiData;

  @override
  void initState() {
    super.initState();
    // Set landscape orientation when the screen is opened
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Fetch data from API
    apiData = fetchDataFromAPI(widget.vendorCode);
  }

  @override
  void dispose() {
    // Revert back to portrait orientation when the screen is closed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchDataFromAPI(String vendorCode) async {
    final apiUrl = 'http://api.berkahmm.com:3000/api/capexpp/historybyparam';

    final requestBody = {
      "versionName": "3.10.43",
      "versionCode": "56",
      "platform": "ANDROID",
      "KEYWORDS": vendorCode,
      "SEARCHBY": "VENDOR"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        // Handle API error
        print('Failed to fetch data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        appBar: CustomAppBar(
          context: context,
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              CommonConstant.menuHistoryData,
              style: getTextStyle(context: context, type: "appBarScreen"),
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available.'));
            } else {
              final dynamic responseData = snapshot.data!;
              final dynamic record = responseData['data']['RECORD'];
              if (record == null || record is! Map<String, dynamic>) {
                return Center(child: Text('Invalid data format.'));
              }

              final String header = responseData['data']['HEADER'] ?? 'No Header Available'; // Handle null header
              final List<dynamic> items = record['items'];

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            header,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.grey,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          defaultColumnWidth: FixedColumnWidth(100.0), // Adjust as needed
                          children: [
                            TableRow(
                              children: [
                                for (var extra in record['extras'])
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        extra['name'],
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            for (var item in items)
                              TableRow(
                                children: [
                                  for (var row in item['rows'])
                                    TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(row['value'].toString()),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
