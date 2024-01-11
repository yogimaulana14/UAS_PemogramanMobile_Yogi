import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bmm_app/app/component/view_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the FontAwesome package
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_theme.dart';
import '../../../../shared/common_constant.dart';
import '../../../data/profile/profile_model.dart';
import '../../../routes/app_router.gr.dart';

@RoutePage()
class ViewPoDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final int index; //1
  final ProfileModel profileModel;
  final List<Map<String, dynamic>> jsonData;
  const ViewPoDetailScreen({
    Key? key,
    required this.profileModel,
    required this.data,
    required this.index, //2
    required this.jsonData,
  }) : super(key: key);

  @override
  State<ViewPoDetailScreen> createState() => _ViewPoDetailScreenState();
}

class _ViewPoDetailScreenState extends State<ViewPoDetailScreen> {
  bool isItemListActive = true;
  bool isCeklisClicked = false;
  bool isRejectClicked = false;
  List<dynamic> itemList = []; // Mengubah tipe data menjadi List<dynamic>
  List<dynamic> attachmentList = [];
  int index= 1;
  Map<String, dynamic>? data;
  bool isFilterWaitingForApproval = false;
  bool isSubmissionSuccessful = false;
  final myController = TextEditingController();


  Future<void> _launchUrl(String fileExt, String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          const SnackBar(content: Text("Could not launch URL")));
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchApiData(int draftNumber) async {
    final apiUrl = 'http://api.berkahmm.com:3100/api/capexpp/approvalDetail';
    final requestData = {
      "version_code": "56",
      "version_name": "3.10.43",
      "platform": "ANDROID",
      "DRAFTENTRY": draftNumber,
      "USERLOGIN": "yogimaulana",
      "TYPEAPPROVAL": "PO"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('API response data [$apiUrl]: $responseData');
        setState(() {
          itemList = List<dynamic>.from(responseData['data']['ITEMDETAILS']); // Mengonversi tipe data
          attachmentList = List<dynamic>.from(responseData['data']['ATTACHMENT']); // Mengonversi tipe data
        });
      } else {
        print('API request failed with status ${response.statusCode}');
      }
    } catch (error) {
      print('API request error: $error');
    }
  }

  Future<void> submitApiData() async {
    final apiUrl = 'http://api.berkahmm.com:3100/api/capexpp/approveDocument';
    final requestData = {
      "REMARKS": "Test Notif",
      "version_name": "3.10.43",
      "version_code": "56",
      "platform": "ANDROID",
      "APPROVAL": [
        {
          "DRAFTENTRY": data!['DRAFTENTRY'],
          "REMARKS": myController.text,
          "APPROVALLEVEL": int.tryParse(widget.profileModel.approvalLevelPo ?? '-1'),
          "USERID": widget.profileModel.username,
          "DOCSTAT": isCeklisClicked ? 'A':isRejectClicked ?'R':null,
          "FINISHAPPROVALLEVEL": data!['FINISHAPPROVALLEVEL'],
          "DOCUMENTTYPE": data!['DOCUMENTTYPE']
        }
      ]
    };
    try {
      print('Submit');
      print(requestData);
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('API response data [$apiUrl]: $responseData');
        setState(() {
          isFilterWaitingForApproval=false;
          isSubmissionSuccessful = true;
          isCeklisClicked = isCeklisClicked ? true : false  ;
          isRejectClicked = isRejectClicked ? true : false ;

        });
      } else {
        print('API request failed with status ${response.statusCode}');
      }
    } catch (error) {
      print('API request error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    index=widget.index;
    data=widget.data;
    fetchApiData(data!['DRAFTENTRY']);
  }

  void resetButtons() {
    setState(() {
      isCeklisClicked = false;
      isRejectClicked = false;
    });
  }


  Future<Object> showMoreInfoDialog({
    required BuildContext context,
    required int index,
    required String type,
    int? indexDetail,
    required List<Map<String, dynamic>>
        jsonData, // Melewatkan data JSON ke dalam fungsi
  }) async {
    switch (type) {
      case CommonConstant.typePo:
        final data =
            jsonData[index - 1]; // Ambil data berdasarkan indeks yang diberikan
        final PoNumber = data['DRAFTNUMBER']; // Ambil nomor PR dari data
        final TypeDc = data['BASEDOCUMENTTYPE'];
        final NumberDc = data['BASEDOCUMENTNUMBER'];
        final vendorCode = data['VENDORCODE'];

        return showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              'More information\n $PoNumber',
            ),
            content: Text('Do you want to display data based on?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop(false);
                            showDialog(
                              context: context,
                              builder: (baseDocumentDialogContext) =>
                                  AlertDialog(
                                title: Text('Base Document PO $PoNumber'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: Text(
                                            'Base Document',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            TypeDc,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: Text(
                                            'Base Document Number',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            NumberDc,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  Center(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(baseDocumentDialogContext)
                                            .pop(false);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color: AppTheme.primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontFamily: Font.Montserrat,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: Text(
                            'Base Document',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: Font.Montserrat,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            AutoRouter.of(context).push(
                                HistoryViewPoRoute(vendorCode: vendorCode));
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ViewPoDetailScreen(), // Remove the historyDataResponseData parameter
                            //   ),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme
                                .primaryColor, // Change to your desired color
                          ),
                          child: Text(
                            'Vendor',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: Font.Montserrat,
                              // Change to your desired font family
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontFamily: Font.Montserrat,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract headerLoop and recordLoop from widget.data
    List<String> headerLoop = List<String>.from(data!['HEADERLOOP']);
    List<dynamic> recordLoop = List<dynamic>.from(data!['RECORDLOOP']);

    isFilterWaitingForApproval =
        data != null && data!['FILTER'] == 'Waiting For Your Approval';


    return CustomScaffold(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: CustomAppBar(
            context: context,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                CommonConstant.viewmenuDetailPo,
                style: getTextStyle(context: context, type: "appBarScreen"),
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(children: [
                // Content of the screen goes here
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Logika tombol First di sini
                              setState(() {
                                index = 1;
                                data = widget.jsonData[index - 1];

                              });
                              fetchApiData(widget.jsonData[index - 1]['DRAFTENTRY']);
                              resetButtons();
                            },

                            child: Icon(Icons.skip_previous),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: index > 1 ? () {
                              setState(() {
                                index -= 1;
                                data = widget.jsonData[index - 1];
                              });
                              fetchApiData(widget.jsonData[index - 1]['DRAFTENTRY']);
                              resetButtons();
                            } : null,
                            child: Icon(Icons.arrow_back),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: index < widget.jsonData.length ? () {
                              
                              if (widget.jsonData[index]['FILTER'] == 'Waiting For Your Approval') {
                                setState(() {
                                  print('coba');
                                  isFilterWaitingForApproval = true;
                                  isSubmissionSuccessful = false;
                                });
                              } else {
                                setState(() {
                                  print('coba1');
                                  isFilterWaitingForApproval = false;
                                  isSubmissionSuccessful = true;
                                });
                              }
                              
                              setState(() {
                                index += 1;
                                data = widget.jsonData[index - 1];
                                isCeklisClicked = false;
                                isRejectClicked = false;
                                myController.text = '';
                              });

                              fetchApiData(widget.jsonData[index - 1]['DRAFTENTRY']);
                              resetButtons();
                            } : null,
                            child: Icon(Icons.arrow_forward),
                          ),

                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              // Logika tombol Last di sini
                              setState(() {
                                index = widget.jsonData.length;
                                data = widget.jsonData[index - 1];
                              });
                              fetchApiData(widget.jsonData[index - 1]['DRAFTENTRY']);
                              resetButtons();
                            },
                            child: Icon(Icons.skip_next),
                          ),
                        ],
                      ),
                      Text('Data ${index} of ${widget.jsonData.length}'),
                    ],
                  ),
                ),

                if (data != null) ...[
                  Card(
                    margin: EdgeInsets.all(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                    color: Colors.white70,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(5),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                headerLoop.length,
                                (i) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100,
                                        child: Text(
                                          '${headerLoop[i]}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 11),
                                      Text(
                                        ':',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${recordLoop[i]}',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 0), // Add some space
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[300],
                                  ),
                                  onPressed: () {
                                    showMoreInfoDialog(
                                      context: context,
                                      index: index,
                                      type: CommonConstant.typePo,
                                      indexDetail: null,
                                      jsonData: widget.jsonData
                                          .cast<Map<String, dynamic>>(),
                                    );
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.infoCircle,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    "More Info",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isItemListActive = true;
                          });
                        },
                        child: Text(
                          'Item List',
                          style: TextStyle(
                            fontWeight: isItemListActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                isItemListActive ? Colors.green : Colors.black,
                            fontSize: 14.0,
                            decoration: isItemListActive
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isItemListActive = false;
                          });
                        },
                        child: Text(
                          'Attachment',
                          style: TextStyle(
                            color:
                                isItemListActive ? Colors.black : Colors.green,
                            fontSize: 14.0,
                            decoration: isItemListActive
                                ? TextDecoration.none
                                : TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isItemListActive) ...[
                    Expanded(
                      child: itemList.isEmpty
                          ? Center(
                        child: Text('No Data'),
                      )
                          : ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
                          final headerLoop = item['HEADERLOOP'];
                          final recordLoop = item['RECORDLOOP'];

                          return Card(
                            margin: EdgeInsets.all(8.0), // Atur margin sesuai kebutuhan
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                headerLoop.length,
                                    (i) {
                                  return Padding(
                                    padding: EdgeInsets.all(8.0), // Atur padding sesuai kebutuhan
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: Text(
                                            '${headerLoop[i]}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 11),
                                        Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${recordLoop[i]}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )

                  ] else ...[
                    // Bagian attachment list
                    Expanded(
                      child: ListView.builder(
                        itemCount: attachmentList.length,
                        itemBuilder: (context, index) {
                          final attachment = attachmentList[index];
                          final attachmentLink = attachment['LINK'];
                          final fileName = attachment['FileName'];
                          final fileExt = attachment['FileExt'];

                          return ListTile(
                            title: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16), // Tambahkan padding di sisi kiri dan kanan
                              child: InkWell(
                                onTap: () async {
                                  await _launchUrl(fileExt,attachmentLink

                                  );
                                },
                                child: Text(
                                  'Attachment Name: $fileName',
                                  style: TextStyle(
                                    color: Colors.blue, // Ubah warna teks agar terlihat sebagai tautan
                                    decoration: TextDecoration.underline, // Tambahkan garis bawah
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: isFilterWaitingForApproval ? 190 : 16),
                ],
              ]),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: (isFilterWaitingForApproval && !isSubmissionSuccessful)
                    ? Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: myController,
                            onChanged: (value) {
                              // Implementasikan logika yang ingin Anda lakukan saat teks berubah
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your note here',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isFilterWaitingForApproval ? () {
                                setState(() {
                                  isCeklisClicked = !isCeklisClicked;
                                  isRejectClicked = false;
                                });
                              } : null,
                              icon: Icon(Icons.check,
                                  color: isCeklisClicked ? Colors.white : Colors.green),
                              label: Text(
                                'Approve',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: isCeklisClicked ? Colors.white : Colors.green),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: isCeklisClicked ? Colors.green : Colors.white,
                                disabledBackgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                      width: 1,
                                      color: isCeklisClicked ? Colors.green : Colors.green),
                                ),
                                minimumSize: Size(80, 40),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isFilterWaitingForApproval ? () {
                                setState(() {
                                  isRejectClicked = !isRejectClicked;
                                  isCeklisClicked = false;
                                });
                              }: null,
                              icon: Icon(Icons.close,
                                  color: isRejectClicked ? Colors.white : Colors.red),
                              label: Text(
                                'Reject',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: isRejectClicked ? Colors.white : Colors.red),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: isRejectClicked ? Colors.red : Colors.white,
                                disabledBackgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                      width: 1,
                                      color: isRejectClicked ? Colors.red : (isFilterWaitingForApproval ? Colors.red : Colors.red)),
                                ),
                                minimumSize: Size(80, 40),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: resetButtons,
                              icon: Icon(Icons.restore, color: Colors.white),
                              label: Text(
                                'Reset',
                                style: TextStyle(fontSize: 14.0, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(width: 1, color: Colors.grey),
                                ),
                                minimumSize: Size(80, 40),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: isFilterWaitingForApproval && !isSubmissionSuccessful
                                ? () {
                              if (isCeklisClicked || isRejectClicked) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text('Are you sure you want to submit?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await submitApiData();
                                          Navigator.pop(context);
                                          String action = isCeklisClicked ? 'approve' : 'reject';
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Success'),
                                              content: Text('Data has been $action successfully.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text('Please select Approve or Reject before submitting.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async{
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } : null,
                            child: Text(
                              'Submit',
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(width: 1, color: Colors.blue),
                              ),
                              minimumSize: Size(double.infinity, 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
