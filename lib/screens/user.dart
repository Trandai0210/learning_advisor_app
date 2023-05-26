import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/permission/permisson_repository.dart';
import 'package:edubot/permission/perrmisson_model.dart';
import 'package:edubot/user/user_bloc.dart';
import 'package:edubot/user/user_event.dart';
import 'package:edubot/user/user_model.dart';
import 'package:edubot/user/user_repository.dart';
import 'package:edubot/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cố vấn học tập",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token')),
        builder: (context,snapshot) {
          if(snapshot.hasData){
            return RepositoryProvider(
              create: (context) => UserRepository(snapshot.data ?? ""),
              child: const UserList(),
            );
          }
          return const CircularProgressIndicator();
        }
      ),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> with RestorationMixin{
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableInt _rowIndex = RestorableInt(0);

  @override
  String? get restorationId => 'paginated_user_table';
  
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(
        RepositoryProvider.of<UserRepository>(context),
      )..add(GetUsersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Danh sách người dùng",
            style: TextStyle(fontSize: 25, color: Colors.white),
          )
        ),
        drawer: const AdminDrawer(),
        body: BlocBuilder<UserBloc,UserState>(
          builder: (context,state) {
            if(state is LoadingUser){
              return const Center(child: CircularProgressIndicator());
            } else if(state is LoadedUser){
              var dts = DTS(state.users, this.context);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
            } else if(state is LoadUserFailure){
              return Center(child: Text("Lỗi: "+ state.error));
            }
            return Container();
          },
        ),
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
          'Họ tên',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Gmail',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Điện thoại',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Ảnh',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Quyền',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Ngày sinh',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Chức năng',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
  ];
}

Widget _BtnPhanQuyen(BuildContext context, User user) {
    return FutureBuilder(
      future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString()),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return FutureBuilder<List<Permission>>(
          future: PermissionRepository(snapshot.data ?? "").getPermissions(),
          builder: ((context, snapshot) {
            if(snapshot.hasData){
              List<Permission> permissions = snapshot.data ?? [];
              return Row(
                children: [
                  IconButton(
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: ((context) {
                          int? dropdownValue;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text("Phân quyền"),
                                content: Container(
                                  child: DropdownButton<int>(
                                    hint: Text(user.permissionName),
                                    isExpanded: true,
                                    items: permissions.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                                      value: e.permissionId,
                                      child: Text(permissions.firstWhere((element) => element.permissionId == e.permissionId).permissionName),
                                    )).toList(),
                                    value: dropdownValue,
                                    onChanged: (int? value){
                                      setState(() {
                                        dropdownValue = value;
                                      });
                                    },
                                  ),
                              ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                                      await UserRepository(token).setPermission(user.userId, dropdownValue!);
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserListView()));
                                      MotionToast.success(
                                        description: Text("Phân quyền thành công!")
                                      ).show(context);
                                    },
                                    child: const Text("Phân quyền"),
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
                        })
                      );
                    }, icon: Icon(Icons.perm_identity_sharp)
                  ),
                  const Text("Phân quyền")
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
        );
        }
        return CircularProgressIndicator();
      }
    );
  }

  Widget _BtnBlockOrUnBlock(BuildContext context,bool status, int id){
    if(status){
      return Row(
        children: [
          IconButton(onPressed: (){
            _blockUser(context,id);
          }, 
          icon: const Icon(Icons.lock)),
          const Text("Chặn")
        ],
      );
    } else {
      return Row(
        children: [
          IconButton(onPressed: (){
            _unBlockUser(context,id);
          }, 
          icon: const Icon(Icons.lock_open)),
          const Text("Bỏ chặn"),
        ],
      );
    }
  }

void _blockUser(BuildContext context, int id){
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Chặn"),
          content: Container(
            child: const Text("Bạn có chắc muốn chặn?"),
         ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                await UserRepository(token).blockUser(id);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserListView()));
                MotionToast.success(
                  title: Text("Thành công"),
                  description: Text("Chặn thành công!")
                ).show(context);
              },
              child: const Text("CHẶN"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("HUỶ"),
            ),
          ],
        );
      })
    );
  }

void _unBlockUser(BuildContext context, int id){
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Chặn"),
          content: Container(
            child: const Text("Bạn có chắc muốn chặn?"),
         ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                await UserRepository(token).unBlockUser(id);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserListView()));
                MotionToast.success(
                  title: Text("Thành công"),
                  description: Text("Bỏ chặn thành công!")
                ).show(context);
              },
              child: const Text("BỎ CHẶN"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("HUỶ"),
            ),
          ],
        );
      })
    );
  }

class DTS extends DataTableSource{
  List<User> users;
  BuildContext context;
  DTS(this.users, this.context);

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(users.elementAt(index).userId.toString())),
        DataCell(Text(users.elementAt(index).name)),
        DataCell(Text(users.elementAt(index).gmail)),
        DataCell(Text(users.elementAt(index).phone)),
        DataCell(
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(users.elementAt(index).image),
          )
          
        ),
        DataCell(Text(users.elementAt(index).permissionName)),
        DataCell(Text(
          DateFormat('dd-MM-yyyy').format(DateTime.parse(users.elementAt(index).dob)).toString()
          )
        ),
        DataCell(
          Row(children: [
            _BtnBlockOrUnBlock(context,users.elementAt(index).status, users.elementAt(index).userId),
            _BtnPhanQuyen(context,users.elementAt(index)),
            ],
          )
        )
      ]
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => users.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}