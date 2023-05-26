import 'package:edubot/answer/answer_model.dart';
import 'package:edubot/answer/answer_repository.dart';
import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/question/question_bloc.dart';
import 'package:edubot/question/question_event.dart';
import 'package:edubot/question/question_model.dart';
import 'package:edubot/question/question_repository.dart';
import 'package:edubot/question/question_state.dart';
import 'package:edubot/screens/add_question.dart';
import 'package:edubot/screens/edit_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionListView extends StatefulWidget {
  const QuestionListView({super.key});

  @override
  State<QuestionListView> createState() => _QuestionListViewState();
}

class _QuestionListViewState extends State<QuestionListView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cố vấn học tập",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString()),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return RepositoryProvider(
              create: (context) => QuestionRepository(snapshot.data ?? ""),
              child: const QuestionList(),
            );
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
}

class QuestionList extends StatefulWidget {
  const QuestionList({super.key});

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> with RestorationMixin {
  int? dropdownValue;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableInt _rowIndex = RestorableInt(0);

  @override
  // TODO: implement restorationId
  String? get restorationId => 'paginated_message_table';
  
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestionBloc(
        RepositoryProvider.of<QuestionRepository>(context),
      )..add(GetQuestionsEvent(page: 0, size: 5, search: "")),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Danh sách câu hỏi",
            style: TextStyle(fontSize: 25, color: Colors.white),
          )
        ),
        drawer: const AdminDrawer(),
        body: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if(state is LoadingQuestions){
              return const Center(child: const CircularProgressIndicator(),);
            } else if(state is LoadedQuestions){
              var dts = DTS(state.questions, this.context);
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
            } else if(state is FailureQuestion){
              return Center(child: Text("Lỗi: " + state.error));
            }
            return Container();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddQuestionPage()),
              );
          },
          child: Icon(Icons.add),
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
          'Câu hỏi',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Câu trả lời',
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
}


  Widget _EditQuestionBtn(BuildContext context, Question question) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditQuestionPage(question: question)),
        );
      }, 
      icon: Icon(Icons.edit)
    );
  }

  Widget _DeleteQuestionBtn(BuildContext context, int id) {
    return IconButton(
      onPressed: () {
        showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("Xoá câu hỏi"),
            content: Container(
              child: const Text("Bạn có chắc muốn xoá?"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  String? token = SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString()) as String?;
                  await QuestionRepository(token ?? "").deleteQuestion(id);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QuestionListView()));
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
      icon: Icon(Icons.delete)
    );
  }

class DTS extends DataTableSource{
  List<Question> questions;
  BuildContext context;
  DTS(this.questions, this.context);

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(questions.elementAt(index).questionId.toString())),
        DataCell(Text(questions.elementAt(index).keyword)),
        DataCell(Text(questions.elementAt(index).answerContent)),
        DataCell(Row(
          children: [
            _EditQuestionBtn(context,questions.elementAt(index)),
            _DeleteQuestionBtn(context,questions.elementAt(index).questionId)
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
  int get rowCount => questions.length;
  
  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}