import 'dart:core';

import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/faculty/faculty_bloc.dart';
import 'package:edubot/faculty/faculty_event.dart';
import 'package:edubot/faculty/faculty_model.dart';
import 'package:edubot/faculty/faculty_repository.dart';
import 'package:edubot/faculty/faculty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacultyListView extends StatefulWidget {
  const FacultyListView({super.key});

  @override
  State<FacultyListView> createState() => _FacultyListViewState();
}

class _FacultyListViewState extends State<FacultyListView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cố vấn học tập',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString()),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return RepositoryProvider(
                create: (context) => FacultyRepository(snapshot.data ?? ""),
                child: const FacultyList(),
              );
            }
            return const CircularProgressIndicator();
          }
        ));
  }
}

class FacultyList extends StatefulWidget {
  const FacultyList({super.key});

  @override
  State<FacultyList> createState() => _FacultyListState();
}

class _FacultyListState extends State<FacultyList> with RestorationMixin {
  final nameController = TextEditingController();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableInt _rowIndex = RestorableInt(0);

  @override
  // TODO: implement restorationId
  String? get restorationId => 'paginated_faculty_table';
  
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FacultyBloc(
        RepositoryProvider.of<FacultyRepository>(context),
      )..add(GetFacultiesEvent(page: 0, size: 5, search: "")),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Danh sách khoa",
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          elevation: 0.0,
        ),
        drawer: const AdminDrawer(),
        body: BlocBuilder<FacultyBloc, FacultyState>(
          builder: ((context, state) {
            if(state is LoadingFaculty){
              return const CircularProgressIndicator();
            }
            if(state is LoadedFaculty){
              var dts = DTS(state.faculties, this.context);
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
                    columns: _tableColumns(),
                    source: dts,
                  ),
                ),
              );
            }
            if(state is FailureFaculty){
              return Text("Lỗi: " + state.error);
            }
            return Container();
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _AddFacultyBtn(this.context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<DataColumn> _tableColumns() => [
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
              'Tên khoa',
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

  List<DataRow> _tableRows(BuildContext context, List<Faculty> faculties) => List<DataRow>.generate(
      faculties.length,
      (index) => DataRow(cells: <DataCell>[
            DataCell(Text(faculties.elementAt(index).facultyId.toString())),
            DataCell(Text(faculties.elementAt(index).name)),
            DataCell(Row(
              children: <Widget>[
                _EditFacultyBtn(context, faculties.elementAt(index)),
                _DeleteFacultyBtn(context ,faculties.elementAt(index).facultyId),
              ],
            ))
          ]));


}

class DTS extends DataTableSource{
  List<Faculty> faculties;
  BuildContext context;
  DTS(this.faculties, this.context);

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(faculties.elementAt(index).name)),
        DataCell(Row(
          children: <Widget>[
            _EditFacultyBtn(context,faculties.elementAt(index)),
            _DeleteFacultyBtn(context ,faculties.elementAt(index).facultyId),
          ],
        ))
      ]
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => faculties.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

  Widget _EditFacultyBtn(BuildContext context, Faculty faculty) => IconButton(
    onPressed: (() {
      showDialog(
        context: context,
        builder: ((context) {
          TextEditingController facultyIdEditingController = TextEditingController();
          facultyIdEditingController.text = faculty.facultyId.toString();
          TextEditingController facultyNameEditingController = TextEditingController();
          facultyNameEditingController.text = faculty.name;
          return AlertDialog(
            title: const Text("Sửa khoa"),
            content: Container(
              child: Column(
                children: [
                TextField(
                  controller: facultyIdEditingController,
                  obscureText: false,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Id',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: facultyNameEditingController,
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
                  bool status = await FacultyRepository(token).updateFaculty(int.parse(facultyIdEditingController.text), facultyNameEditingController.text);
                  if (status == true) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FacultyListView()));
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
        }));
        }),
        icon: const Icon(Icons.edit),
    );

  void _AddFacultyBtn(BuildContext context) {
    showDialog(
        context: context,
        builder: ((context) {
          TextEditingController facultyNameEditingController = TextEditingController();
          return AlertDialog(
            title: const Text("Thêm khoa"),
            content: Container(
              child: TextField(
                controller: facultyNameEditingController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tên khoa',
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (facultyNameEditingController.text.isNotEmpty) {
                    try {
                      String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                      bool status = await FacultyRepository(token).addFaculty(facultyNameEditingController.text);
                      if (status == true) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FacultyListView()));
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
                            description: Text("Không được để trống tên khoa!"))
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
  }

  Widget _DeleteFacultyBtn(BuildContext context, int id) => IconButton(
    onPressed: (() {
      showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Xoá khoa"),
          content: Container(
            child: const Text("Bạn có chắc muốn xoá?"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                await FacultyRepository(token).deleteFaculty(id);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FacultyListView()));
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
      })
    );
    }),
    icon: const Icon(Icons.delete),
  );