  import 'package:auto_route/auto_route.dart';
  import 'package:bmm_app/app/component/view_builder.dart';
import 'package:bmm_app/app/routes/app_router.gr.dart';
  import 'package:flutter/material.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:searchbar_animation/searchbar_animation.dart';
  import 'package:dropdown_button2/dropdown_button2.dart';
  import 'package:intl/intl.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import '../../../config/app_constants.dart';
  import '../../../config/app_theme.dart';
  import '../../../shared/common_constant.dart';
import '../../data/profile/profile_model.dart';
import 'detail/data_model.dart';


  enum TimePeriod { OneWeek, OneMonth, }


  @RoutePage()
  class ViewPoScreen extends StatefulWidget {
    final ProfileModel profileModel;
    const ViewPoScreen({
      Key? key,
    required this.profileModel,
    }) : super(key: key);

    @override
    _ViewPoScreenState createState() => _ViewPoScreenState();
  }

  class _ViewPoScreenState extends State<ViewPoScreen> {
    DateTime? _selectedFromDate;
    DateTime? _selectedToDate;
    bool _isSearchBoxOpen = false;
    TextEditingController searchTextController = TextEditingController();
    TimePeriod? _selectedTimePeriod;
    String? _selectedStatus;
    TextEditingController _fromDateController = TextEditingController();
    TextEditingController _toDateController = TextEditingController();
    String? _errorText;

    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    List<DataModel> _dataList = [];
    List<DataModel> _originalDataList = [];
    bool _isDataLoaded = false;
    bool _isFilterApplied = false;
    List<dynamic> jsonData = [];
    bool isLoading = false;
    String errorMessage = '';
    List<dynamic> _originalJsonData = [];
    get selectedData => null;

    Future<Object> showMoreInfoDialog({
      required BuildContext context,
      required int index,
      required String type,
      int? indexDetail,
      required List<Map<String, dynamic>> jsonData, // Melewatkan data JSON ke dalam fungsi
    }) async {
      switch (type) {
        case CommonConstant.typePo:
          final data = jsonData[index - 1]; // Ambil data berdasarkan indeks yang diberikan
          final PoNumber = data['DRAFTNUMBER']; // Ambil nomor PR dari data
          final TypeDc = data['BASEDOCUMENTTYPE'];
          final NumberDc = data['BASEDOCUMENTNUMBER'];
          final vendorCode = data['VENDORCODE'];

          return showDialog(
            context: context,
            builder: (dialogContext) =>
                AlertDialog(
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
                                    builder: (baseDocumentDialogContext) => AlertDialog(
                                      title: Text('Base Document PO $PoNumber'),
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                              Navigator.of(baseDocumentDialogContext).pop(false);
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
                                  AutoRouter.of(context).push(HistoryViewPoRoute(vendorCode: vendorCode));
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ViewPoDetailScreen(), // Remove the historyDataResponseData parameter
                                  //   ),
                                  // );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor, // Change to your desired color
                                ),
                                child: Text(
                                  'Vendor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Font.Montserrat, // Change to your desired font family
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),

                              OutlinedButton(
                                onPressed: () async{
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

    void initState() {
      super.initState();
      _fromDateController.text = 'Select a date';
      _toDateController.text = 'Select a date';
      _initializeData();
    }

    Future<void> _initializeData() async {
      try {
        await ambilData(_selectedStatus!); // Menggunakan _selectedStatus sebagai parameter
        _originalJsonData = List.from(jsonData); // Simpan data asli sebelum diubah
        setState(() {
          _isDataLoaded = true;
        });
      } catch (error) {
        print('Error initializing data: $error');
      }
    }



    void _handleUse() async {
      if (_selectedStatus == null || _selectedFromDate == null || _selectedToDate == null) {
        // Tampilkan pesan peringatan jika status atau tanggal tidak terpilih
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Warning'),
            content: Text('Please select status and date.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        try {
          print('Fetching data from API...');

          String approvalStatus;
          if (_selectedStatus == 'Pending') {
            approvalStatus = 'Pending';
          } else if (_selectedStatus == 'Rejected') {
            approvalStatus = 'Rejected';
          } else if (_selectedStatus == 'Completed'){
            approvalStatus = 'Completed'; // Anda perlu menentukan logika lain jika status lain dipilih
          } else if (_selectedStatus == 'Waiting For Your Approval'){
            approvalStatus = 'Waiting For Your Approval';
          } else {
            approvalStatus = 'All';
          }


          await ambilData(approvalStatus); // Panggil ambilData dengan status yang dipilih

          print('Data fetched successfully');

          setState(() {
            _isFilterApplied = true;
          });
        } catch (error) {
          print('Error fetching data from API: $error');

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to load data from API.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }


    void _handleResetEndDrawer() {
      setState(() {
        _selectedFromDate = null;
        _selectedToDate = null;
        _selectedTimePeriod = null;
        _selectedStatus = null;
        _fromDateController.text = 'Select a date';
        _toDateController.text = 'Select a date';
        _errorText = null;
        _dataList = _originalDataList;
        _isFilterApplied = false;
        jsonData = List.from(_originalJsonData);
      });
    }

    Future<void> ambilData(String approvalStatus) async {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        final Map<String, dynamic> requestData = {
          "version_code": "56",
          "version_name": "3.10.43",
          "platform": "ANDROID",
          "DATEFROM": "${_selectedFromDate!.year}${_selectedFromDate!.month.toString().padLeft(2, '0')}${_selectedFromDate!.day.toString().padLeft(2, '0')}",
          "DATETO": "${_selectedToDate!.year}${_selectedToDate!.month.toString().padLeft(2, '0')}${_selectedToDate!.day.toString().padLeft(2, '0')}",
          "DOCSTATDB": approvalStatus,
          "USERLOGIN": widget.profileModel.username,
          "TYPEAPPROVAL": "PO",
        };
        print('Request Data: $requestData');

        final response = await http.post(
          Uri.parse('http://api.berkahmm.com:3100/api/capexpp/approvalHeader'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );
        print(response.body.toString());

        if (response.statusCode == 200) {
          setState(() {
            jsonData = json.decode(response.body)['data'];
            if (approvalStatus != 'All') {
              jsonData = jsonData.where((item) => item['FILTER'] == approvalStatus).toList();
            }
          });
        } else {
          print('Permintaan gagal dengan status: ${response.statusCode}');
          errorMessage =
          'Permintaan gagal dengan status: ${response.statusCode}';
        }
      } catch (e) {
        print('Error: $e');
        errorMessage = 'Error: $e';
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }


    Future<void> _selectFromDate() async {
      if (_selectedTimePeriod == null) {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedFromDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedFromDate = picked;
            _fromDateController.text = _dateFormat.format(_selectedFromDate!);
            _errorText = null;
          });
        }
      }
    }

    Future<void> _selectToDate() async {
      if (_selectedTimePeriod == null) {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedToDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          if (_selectedFromDate != null &&
              picked.isBefore(_selectedFromDate!)) {
            setState(() {
              _errorText = 'Please enter a valid date';
            });
          } else {
            setState(() {
              _selectedToDate = picked;
              _toDateController.text = _dateFormat.format(_selectedToDate!);
              _errorText = null;
            });
          }
        }
      }
    }

    void _handleTimePeriodChange(TimePeriod selectedPeriod) {
      setState(() {
        _selectedTimePeriod = selectedPeriod;
        _selectedFromDate = null;
        _selectedToDate = null;
        _fromDateController.text = 'Select a date';
        _toDateController.text = 'Select a date';
        _errorText = null;


        if (selectedPeriod == TimePeriod.OneWeek) {
          final now = DateTime.now();
          _selectedFromDate = now.subtract(Duration(days: 7));
          _selectedToDate = now;
          _fromDateController.text = _dateFormat.format(_selectedFromDate!);
          _toDateController.text = _dateFormat.format(_selectedToDate!);
        } else if (selectedPeriod == TimePeriod.OneMonth) {
          final now = DateTime.now();
          _selectedFromDate = DateTime(now.year, now.month - 1, now.day);
          _selectedToDate = now;
          _fromDateController.text = _dateFormat.format(_selectedFromDate!);
          _toDateController.text = _dateFormat.format(_selectedToDate!);
        }
      });
    }

    Future<bool> _onBackPressed(BuildContext context) async {
      return await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to back.'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                          return Future.value(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: Text(
                          'No',
                          // style: TextStyle(
                          //     color: Colors.white,
                          //     fontFamily: Font.Montserrat,
                          //     fontSize: 18.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                          Navigator.of(context).pop(false);
                          return Future.value(true);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side:
                          BorderSide(color: AppTheme.primaryColor, width: 1),
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontFamily: Font.Montserrat,
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
                /*GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child:
                      roundedButton("No", AppTheme.primaryColor, Colors.white),
                ),
                GestureDetector(
                  onTap: () => {_sendLogout(token, widget.profileModel.username)},
                  child: roundedButton(
                      " Yes ", AppTheme.primaryColor, Colors.white),
                ),*/
              ],
            ),
      ) ??
          false;
    }

    PreferredSizeWidget appBar(BuildContext context) {
      return AppBar(
        leadingWidth: 30,
        title: rowBuilderNew(
          0,
          0,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppAssetImage.logoOnly.assetName,
                          fit: BoxFit.contain,
                          height: 40.0,
                        ),
                        Visibility(
                          visible: !_isSearchBoxOpen,
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Text(
                              CommonConstant.menuManagementViewPo,
                              style: getTextStyle(
                                context: context,
                                type: "appBarScreen",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      flex: 1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        alignment: _isSearchBoxOpen
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: SearchBarAnimation(
                          textEditingController: searchTextController,
                          isOriginalAnimation: true,
                          isSearchBoxOnRightSide: !_isSearchBoxOpen,
                          enableKeyboardFocus: true,
                          onFieldSubmitted: (value) {
                            // Perform some action when the search field is submitted
                          },
                          onPressButton: (isOpen) {
                            setState(() {
                              _isSearchBoxOpen = isOpen;
                            });
                          },
                          trailingWidget: _isSearchBoxOpen
                              ? const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.black,
                          )
                              : const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.black,
                          ),
                          secondaryButtonWidget: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                          buttonWidget: const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Define the EndDrawer widget here
    Widget buildEndDrawer() {
      return Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //bagian 1 header
            Container(
              padding: const EdgeInsets.all(7),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bagian 2
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 10.0,
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              value: _selectedStatus,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                              },
                              hint: Text('Select Status'),
                              items: <String>[
                                'Waiting For Your Approval',
                                'Pending',
                                'Rejected',
                                'Completed',
                                'All',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                // Add more decoration...
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Periode',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () =>
                                    _handleTimePeriodChange(TimePeriod.OneWeek),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                  _selectedTimePeriod == TimePeriod.OneWeek
                                      ? Colors.green
                                      : Colors.transparent,
                                  padding: EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                ),
                                child: Text(
                                  'Week',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color:
                                    _selectedTimePeriod == TimePeriod.OneWeek
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () =>
                                    _handleTimePeriodChange(
                                        TimePeriod.OneMonth),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                  _selectedTimePeriod == TimePeriod.OneMonth
                                      ? Colors.green
                                      : Colors.transparent,
                                  padding: EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                ),
                                child: Text(
                                  'Month',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color:
                                    _selectedTimePeriod == TimePeriod.OneMonth
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Date',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200]?.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                child: TextField(
                                  readOnly: true,
                                  controller: _fromDateController,
                                  decoration: InputDecoration(
                                    labelText: 'From',
                                    prefixIcon: Icon(
                                        Icons.calendar_month_sharp),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 1.0),
                                    isDense: true,
                                    labelStyle: TextStyle(fontSize: 12.0),
                                    hintStyle: TextStyle(fontSize: 12.0),
                                  ),
                                  style: TextStyle(fontSize: 11.0),
                                  onTap: _selectFromDate,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200]?.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                child: TextField(
                                  readOnly: true,
                                  controller: _toDateController,
                                  decoration: InputDecoration(
                                    labelText: 'To',
                                    prefixIcon: Icon(
                                        Icons.calendar_month_sharp),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 1.0),
                                    isDense: true,
                                    labelStyle: TextStyle(fontSize: 12.0),
                                    hintStyle: TextStyle(fontSize: 12.0),
                                    errorText: _errorText,
                                  ),
                                  style: TextStyle(fontSize: 11.0),
                                  onTap: _selectToDate,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.0),

            // Button Row for "Reset" and "Use" buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              height: 60,
              decoration: BoxDecoration(),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _handleResetEndDrawer(); // untuk me reset semua button yang di pilih pada endrawer
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleUse,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                        ),
                        child: Text(
                          'Use',
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      bool isFiltersEmpty =
          _selectedStatus == null && _selectedTimePeriod == null &&
              _selectedFromDate == null;
      bool isDataEmpty = _dataList.isEmpty;
      bool isNoDataToShow = isFiltersEmpty && isDataEmpty;

      return CustomScaffold(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: WillPopScope(
            onWillPop: () {
              return _onBackPressed(context);
            },
            child: Scaffold(
              appBar: appBar(context),
              endDrawer: buildEndDrawer(), // Add the end drawer here
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (jsonData.isEmpty)
                    Expanded(
                      child: Center(child: Text('Data Is Not Empty')),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Total Data: ${jsonData.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (errorMessage.isNotEmpty)
                    Center(child: Text(errorMessage))
                  else
                    jsonData.isEmpty
                        ? SizedBox.shrink()
                        : Expanded(
                      child: ListView.separated(
                        itemCount: jsonData.length + 1,
                        separatorBuilder: (context, index) {
                          if (index == 0) {
                            return SizedBox.shrink();
                          }
                          return Divider();
                        },
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return SizedBox.shrink();
                          }
                          final data = jsonData[index - 1];
                          final headerLoop = data['HEADERLOOP'];
                          final recordLoop = data['RECORDLOOP'];
                          final approvalStatus = data['FILTER'];


                          // Menentukan ikon berdasarkan Approval Status
                          IconData statusIcon;
                          Color statusColor;
                          double iconSize = 30.0;
                          double iconPadding = 8.0;

                          if (approvalStatus == 'Rejected') {
                            statusIcon = Icons.cancel; // Icon silang (rejected)
                            statusColor = Colors.red; // Warna merah
                          } else if (approvalStatus == 'Pending') {
                            statusIcon = Icons.access_time; // Icon centang (approved)
                            statusColor = Colors.blue; // Warna biru
                          } else if (approvalStatus == 'Completed'){
                            statusIcon = Icons.check_circle; // Icon centang (approved)
                            statusColor = Colors.green; // Warna hijau
                          } else {
                            statusIcon = Icons.hourglass_top; // Icon jam pasir (waiting)
                            statusColor = Colors.black;
                          }

                          return Card(
                            margin: EdgeInsets.all(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Add rounded corners
                            ),
                            elevation: 1,
                            color: Colors.white70,
                          child: Padding(
                          padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: iconSize + iconPadding * 1,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(iconPadding),
                                      child: Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: iconSize,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.all(5),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      headerLoop.length,
                                          (i) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                            SizedBox(width: 4), // Adjust the spacing as needed
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
                                SizedBox(height: 8), // Adding spacing between content and button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[300],
                                      ),
                                      onPressed: () {
                                        showMoreInfoDialog(
                                          context: context,
                                          index: index,
                                          type: CommonConstant.typePo,
                                          indexDetail: null,
                                          jsonData: jsonData.cast<Map<String, dynamic>>(),
                                        );
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.circleInfo,
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
                                    SizedBox(width: 15), // Adding spacing between buttons
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[300],
                                      ),
                                      onPressed: () {
                                        final data = jsonData[index - 1];
                                        print('Data at index $index: $data');
                                        List<Map<String, dynamic>> convertedJsonData = jsonData.map((dynamic item) {
                                          return Map<String, dynamic>.from(item);
                                        }).toList();
                                        AutoRouter.of(context).push(ViewPoDetailRoute(data: data, index: index, jsonData: convertedJsonData, profileModel: widget.profileModel,));
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.circleInfo,
                                        size: 15,
                                        color: Colors.black,
                                      ),
                                      label: Text(
                                        "Show Detail",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          );

                        },
                      ),
                    ),
                ],
              ),


            ),
          ),
        ),
      );
    }
  }

