import 'dart:async';

import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:electronic_component_storage_app/string_extension.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_management/user_add_new_screen.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_management/user_edit_info_screen.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_management/user_info_card.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  ValueNotifier<List<MyUser>> _displayListNotifier = ValueNotifier([]);

  void _changeDisplayList() {
    if (_searchController.text.isNotEmpty) {
      _displayListNotifier.value = SupabaseAccountController.allUserList
          .where(
            (user) => user.fullName.toUnaccented().toLowerCase().contains(
              _searchController.text.toLowerCase().toUnaccented(),
            ),
          )
          .toList();
    } else {
      _displayListNotifier.value = SupabaseAccountController.allUserList;
    }
  }

  @override
  void initState() {
    _changeDisplayList();
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Danh sách người dùng",
        icon: Icon(Icons.admin_panel_settings),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => UserAddNewScreen()));
          if (result ?? false) {
            _changeDisplayList();
          }
        },
        backgroundColor: AppColor.primaryContainer,
        foregroundColor: Colors.white,
        child: Icon(Icons.person_add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await SupabaseAccountController.getAllUserInSystem();
          _changeDisplayList();
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm người dùng...",
                  border: OutlineInputBorder(
                    //Dùng outline cho to hơn
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.onGreyInputColor,
                  ),
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (value) {
                  if (_searchDebounce?.isActive ?? false) {
                    _searchDebounce!.cancel();
                  }

                  // Đặt timer mới, nếu sau 300ms mà không gõ thêm chữ nào thì mới chạy search
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () {
                      _changeDisplayList();
                    },
                  );
                },
                onFieldSubmitted: (value) {
                  if (_searchDebounce?.isActive ?? false) {
                    _searchDebounce!.cancel();
                  }
                  _changeDisplayList();
                },
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _displayListNotifier,
                  builder: (context, value, widget) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return UserInfoCard(
                          user: value[index],
                          onTap: () async {
                            final bool? result = await Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserEdtiInfoScreen(user: value[index]),
                                  ),
                                );
                            if (result ?? false) {
                              _changeDisplayList();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
