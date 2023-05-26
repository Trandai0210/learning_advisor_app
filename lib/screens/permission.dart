import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/permission/permission_bloc.dart';
import 'package:edubot/permission/permission_event.dart';
import 'package:edubot/permission/permission_state.dart';
import 'package:edubot/permission/permisson_repository.dart';
import 'package:edubot/permission/perrmisson_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionListView extends StatefulWidget {
  const PermissionListView({super.key});

  @override
  State<PermissionListView> createState() => _PermissionListViewState();
}

class _PermissionListViewState extends State<PermissionListView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cố vấn học tập',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token')),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return RepositoryProvider(
              create: (context) => PermissionRepository(snapshot.data ?? ""),
              child: const PermissionList(),
            );
          }
          return const CircularProgressIndicator();
        }
      ),
    );
  }
}

class PermissionList extends StatefulWidget {
  const PermissionList({super.key});

  @override
  State<PermissionList> createState() => _PermissionListState();
}

class _PermissionListState extends State<PermissionList> with RestorationMixin {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableInt _rowIndex = RestorableInt(0);

  @override
  // TODO: implement restorationId
  String? get restorationId => 'paginated_permission_table';
  
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionBloc(
        RepositoryProvider.of<PermissionRepository>(context),
      )..add(GetPermissionsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Danh sách quyền", 
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer: const AdminDrawer(),
        body: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            if(state is LoadingPermission){
              return const Center(child: CircularProgressIndicator());
            } else if(state is LoadedPermission){
              var dts = DTS(state.permissions, this.context);
              return SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: PaginatedDataTable(
                    rowsPerPage: _rowsPerPage,
                    onRowsPerPageChanged: (value) {
                      setState(() {
                        _rowsPerPage = value!;
                      });
                    },
                    initialFirstRowIndex: _rowIndex.value,
                    onPageChanged: (rowIndex) {
                      _rowIndex.value = rowIndex;
                    },
                    columns: _getColumns(),
                    source: dts,
                  ),
                ),
              );
            } else if(state is FailurePermission){
              return Center(child: Text("Lỗi: "+ state.error));
            }
            return Container();
          }
        ),
        floatingActionButton: _addButton(),
      ),
      );
  }

  List<DataColumn> _getColumns() => [
    const DataColumn(
      label: Expanded(
        child: Text(
          'id',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Tên quyền',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Chức Năng',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
  ];

  FloatingActionButton _addButton(){
    return FloatingActionButton(
      onPressed: (){
        showDialog(
        context: context,
        builder: ((context) {
          TextEditingController permissionNameEdittingController = TextEditingController();
          return AlertDialog(
            title: const Text("Thêm quyền"),
            content: Container(
              child: TextField(
                controller: permissionNameEdittingController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tên quyền',
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (permissionNameEdittingController.text.isNotEmpty) {
                    try {
                      String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                      bool status = await PermissionRepository(token).addPermission(permissionNameEdittingController.text);
                      if (status == true) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PermissionListView()));
                        MotionToast.success(
                                title: Text("Thành công"),
                                description: Text("Thêm thành công!"))
                            .show(context);
                      }
                    } catch (e) {
                      MotionToast.success(
                              title: Text("Lỗi"),
                              description: Text("Thêm lỗi!"))
                          .show(context);
                    }
                  } else {
                    MotionToast.error(
                            title: Text("Lỗi"),
                            description: Text("Không được để trống tên quyền!"))
                        .show(context);
                  }
                },
                child: const Text("THÊM"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("HUỶ"),
              ),
            ],
          );
        }
      )
    );
      },
      child: const Icon(Icons.add),
    );
  }
}

  Widget _EditPermissionBtn(BuildContext context ,Permission permission){
    return IconButton(
      onPressed: (){
        showDialog(
          context: context, 
          builder: (context) {
            TextEditingController permissionIdEdittingController = TextEditingController();
            permissionIdEdittingController.text = permission.permissionId.toString();
            TextEditingController permissionNameEdittingController = TextEditingController();
            permissionNameEdittingController.text = permission.permissionName;
            return AlertDialog(
              title: const Text("Sửa quyền"),
              content: Container(
                child: Column(
                  children: [
                  TextField(
                    controller: permissionIdEdittingController,
                    obscureText: false,
                    enabled: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Id',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: permissionNameEdittingController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tên khoa',
                    ),
                  )
                ]),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                    bool status = await PermissionRepository(token).updatePermission(int.parse(permissionIdEdittingController.text), permissionNameEdittingController.text);
                    if (status == true) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PermissionListView()));
                      MotionToast.success(
                        title: Text("Thành công"),
                        description: Text("Sửa thành công!")
                      ).show(context);
                    }
                  },
                  child: const Text("CẬP NHẬT"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("HUỶ"),
                ),
              ],
            );
          }
        );
      }, 
      icon: const Icon(Icons.edit),
    );
  }
  
  Widget _DeletePermissionBtn(BuildContext context, int id){
    return IconButton(
      onPressed: (){
        showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("Xoá quyền"),
            content: Container(
              child: const Text("Bạn có chắc muốn xoá?"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                  await PermissionRepository(token).deletePermission(id);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PermissionListView()));
                  MotionToast.success(
                    title: Text("Thành công"),
                    description: Text("Xoá thành công!")
                  ).show(context);
                },
                child: const Text("XOÁ"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("HUỶ"),
              ),
            ],
          );
        }));
      }, 
      icon: const Icon(Icons.delete)
    );
  }

class DTS extends DataTableSource{
  List<Permission> permissions;
  BuildContext context;
  DTS(this.permissions, this.context);
  
  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(permissions.elementAt(index).permissionId.toString())),
        DataCell(Text(permissions.elementAt(index).permissionName)),
        DataCell(
          Row(children: [
            _EditPermissionBtn(context, permissions.elementAt(index)),
            _DeletePermissionBtn(context, permissions.elementAt(index).permissionId),
          ])
        )
      ]
    );
  }
  
  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;
  
  @override
  // TODO: implement rowCount
  int get rowCount => permissions.length;
  
  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;


}