import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/quantity_stepper.dart';
import 'package:flutter/material.dart';

class AddComponentInfoCard extends StatefulWidget {
  const AddComponentInfoCard({super.key, required this.component});

  final Component component;

  @override
  State<AddComponentInfoCard> createState() => _AddComponentInfoCardState();
}

class _AddComponentInfoCardState extends State<AddComponentInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 0,
      color: AppColor.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.component.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            _buildInfoBlock(),
            const SizedBox(height: 5),
            _buildInteractBlock(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            SupabaseDatabaseController.categoryMapCached[widget
                    .component
                    .categoryID]['name'] ??
                "Khác",
            style: TextStyle(
              color: AppColor.onsurfaceContainerLow,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 5),
        
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.shelves),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  SupabaseDatabaseController.locationMapCached[widget
                          .component
                          .locationID]['name'] ??
                      "Không rõ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuantityStepper(onChanged: (newValue) {}),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.delete_forever_outlined),
          color: AppColor.errorColor,
          iconSize: 32,
        ),
      ],
    );
  }
}
