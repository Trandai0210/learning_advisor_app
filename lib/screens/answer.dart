import 'package:edubot/answer/add_answer_cubit.dart';
import 'package:edubot/answer/answer_bloc.dart';
import 'package:edubot/answer/answer_event.dart';
import 'package:edubot/answer/answer_model.dart';
import 'package:edubot/answer/answer_repository.dart';
import 'package:edubot/answer/answer_state.dart';
import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/faculty/faculty_state.dart';
import 'package:edubot/screens/add_answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerPage extends StatelessWidget{
  const AnswerPage({super.key});

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
              create: (context) => AnswerRepository(snapshot.data ?? ""),
              child: const Page(),
            );
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
}
class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with RestorationMixin {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableInt _rowIndex = RestorableInt(0);

  @override
  // TODO: implement restorationId
  String? get restorationId => 'pageinated_answer_table';
  
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnswerBloc(
        RepositoryProvider.of<AnswerRepository>(context),
      )..add(loadAnswerEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách câu trả lời'),
        ),
        drawer: const AdminDrawer(),
        body: BlocBuilder<AnswerBloc, AnswerState>(
          builder: (context, state){
            if(state is AnswerLoadingState){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(state is AnswerLoadedState){
              List<Answer> answers =  state.answers;
              var dts = DTS(answers, this.context);
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
                    columns: _getColums(),
                    source: dts,
                  ),
                ),
              );
            }
            if(state is AnswerErrorState){
              return Center(
                child: Text("Lỗi rồi"+ state.props.toString()),
              );
            }
            if(state is DeletingFaculty){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container();
          }
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token')).toString();
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: ((context) => AddAnswerCubit(AnswerRepository(token))),
                child: AddAnswerPage(),
              )
            ),
          );
          }
        ),
      ),
    );
  }

  List<DataColumn> _getColums() => [
    const DataColumn(
      label: Expanded(
        child: Text(
          'id', 
          style: TextStyle(
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Câu trả lời', 
          style: TextStyle(
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Chức năng', 
          style: TextStyle(
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    ),
  ];
}

Widget _btnEdit(BuildContext context, Answer answer){
  return IconButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: ((context) {
          TextEditingController answerContentEditingController = TextEditingController();
          answerContentEditingController.text = answer.content;
          TextEditingController answerIdEditingController = TextEditingController();
          answerIdEditingController.text = answer.answerId.toString();
          return AlertDialog(
            title: const Text("Edit Answer"),
            content: Column(children: [
              TextField(
                controller: answerIdEditingController,
                obscureText: false,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Id',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: answerContentEditingController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Câu trả lời',
                ),
              )
            ]),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                  bool status = await AnswerRepository(token).updateAnswer(answerIdEditingController.text, answerContentEditingController.text);
                  if (status == true) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AnswerPage()));
                    MotionToast.success(
                            title: Text("Thành công"),
                            description: Text("Cập nhật thành công!"))
                        .show(context);
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
      ));
    },
    icon: const Icon(Icons.edit)
  );
}

Widget _btnDelete(BuildContext context, int answerId){
  return IconButton(
    onPressed: (){
      showDialog(
        context: context, 
        builder: ((context) {
          return AlertDialog(
            title: const Text("Xoá câu trả lời"),
            content: Container(
              child: const Text("Bạn có chắc muốn xoá?"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async{
                  Navigator.of(context).pop();
                  String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                  bool status = await await AnswerRepository(token).deleteAnswer(answerId);
                  if(status == true){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnswerPage()));
                    MotionToast.success(
                      title: Text("Thành công"),
                      description: Text("Xoá thành công!")
                    ).show(context);
                  }
                },
                child: const Text("XOÁ"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text("HUỶ"),
              ),
            ],
          );
        })
      );
    }, 
    icon: const Icon(Icons.delete)
  );
}

class DTS extends DataTableSource{
  List<Answer> answers;
  BuildContext context;
  DTS(this.answers,this.context);

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(answers.elementAt(index).content)),
        DataCell(
          Row(children: [
            _btnEdit(context, answers.elementAt(index)),
            const SizedBox(width: 10),
            _btnDelete(context, answers.elementAt(index).answerId),
          ],)
        ),
      ]
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => answers.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}