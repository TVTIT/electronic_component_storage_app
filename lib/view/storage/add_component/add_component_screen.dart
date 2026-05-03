import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_info_card.dart';
import 'package:flutter/material.dart';

class AddComponentScreen extends StatelessWidget {
  const AddComponentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final component = Component(
      id: "id",
      partNumber: "partNumber",
      name: "Tụ điện 1000uF",
      quantity: 100,
      locationID: "d99db317-26e8-404f-87e1-bcc2ec245b15",
      specs: {},
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/commons/b/b9/Capacitors_%287189597135%29.jpg",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      categoryID: "capacitor",
    );
    return Scaffold(
      appBar: MyAppBar(title: "Nhập kho linh kiện"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  AddComponentInfoCard(component: component),
                  AddComponentInfoCard(component: component),
                  AddComponentInfoCard(component: component),
                  AddComponentInfoCard(component: component),
                  AddComponentInfoCard(component: component),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(text: "Tổng cộng: "),
                        TextSpan(
                          text: "5",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " linh kiện"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          label: const Text("Thêm linh kiện"),
                          icon: const Icon(Icons.add_circle_outline),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.secondaryContainer,
                            foregroundColor: AppColor.onSecondaryFixedVariant,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          label: const Text(
                            "Xác nhận nhập kho",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
