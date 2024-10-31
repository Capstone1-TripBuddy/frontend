import 'package:flutter/material.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

import 'main_bnb_page.dart';

//여행을 출발할 주소 검색  민박 가는 시간 계산 후 표시 위함
class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}
class _AddressFormPageState extends State<AddressFormPage> {
  /// Form State
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  /// Controller
  final TextEditingController _postcodeController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _addressDetailController =
  TextEditingController();

  Widget _gap() {
    return const SizedBox(
      height: 10,
    );
  }

  void _searchAddress(BuildContext context) async {
    KopoModel? model = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      final postcode = model.zonecode ?? '';
      _postcodeController.value = TextEditingValue(
        text: postcode,
      );
      formData['postcode'] = postcode;

      final address = model.address ?? '';
      _addressController.value = TextEditingValue(
        text: address,
      );
      formData['address'] = address;

      final buildingName = model.buildingName ?? '';
      _addressDetailController.value = TextEditingValue(
        text: buildingName,
      );
      formData['address_detail'] = buildingName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50], // 독립적인 AppBar 색상 설정
        elevation: 0, //
      ),
      body: Padding( // 중단
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: '기본주소',
                    ),
                    readOnly: true,
                  ),
                  _gap(),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: _addressDetailController,
                    decoration: const InputDecoration(
                      hintText: '상세주소 입력',
                    ),
                  ),
                  _gap(),
                  ElevatedButton(
                    onPressed: () => _searchAddress(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[500],
                    ),
                    child:  Text('주소검색',style: TextStyle(color: Colors.grey[100],fontSize: 16,fontWeight: FontWeight.w700),),
                  ),
                  _gap(),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[500],
                ),
                child: Text('다음으로',style: TextStyle(color: Colors.grey[100],fontSize: 16,fontWeight: FontWeight.w700),),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
