
import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/message/message_bloc.dart';
import 'package:edubot/message/message_event.dart';
import 'package:edubot/message/message_model.dart';
import 'package:edubot/message/message_repository.dart';
import 'package:edubot/message/message_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MessageListView extends StatefulWidget {
  const MessageListView({super.key});

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
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
              create: (context) => MessageRepository(snapshot.data ?? ""),
              child: const MessageList(),
            );
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with RestorationMixin {
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
      create: (context) => MessageBloc(
        RepositoryProvider.of<MessageRepository>(context),
      )..add(GetMessagesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title:  const Text(
            "Danh sách tin nhắn",
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer:  const AdminDrawer(),
        body: BlocBuilder<MessageBloc,MessageState>(
          builder: (context, state) {
            if(state is LoadingMessages){
              return const Center(child: CircularProgressIndicator());
            } else if (state is LoadedMessages){
              var dts = DTS(state.messages, this.context);
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
            } else if(state is LoadMessagesFailure){
              return Text("Lỗi: " + state.error);
            }
            return Container();
          }
        ),
      ),
    );
  }

  List<DataColumn> _tableColumns() => [
    const DataColumn(
      label: Expanded(
        child: Text(
          'TT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Tin nhắn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Thời gian tạo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Người gửi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Email',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Gửi đến',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const DataColumn(
      label: Expanded(
        child: Text(
          'Chức năng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ];
}

Widget _btnDelete(BuildContext context, int messageId){
    return Row(
      children: [
        IconButton(
          onPressed: (){
            showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: const Text("Xoá tin nhắn"),
                content: Container(
                  child: const Text("Bạn có chắc muốn xoá?"),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                      bool status = await MessageRepository(token).deleteMessage(messageId);
                      if(status){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MessageListView()));
                        MotionToast.success(
                          title: Text("Thành công"),
                          description: Text("Xoá thành công!")
                        ).show(context);
                      }else{
                        MotionToast.error(
                          title: Text("Lỗi"),
                          description: Text("Vui lòng thử lại sau!")
                        ).show(context);
                      }
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
        ),
        const Text("Xoá"),
      ],
    );
  }

class DTS extends DataTableSource{
  List<Message> messages;
  BuildContext context;
  DTS(this.messages, this.context);

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Container(width: 400, child: Text(messages.elementAt(index).content,overflow: TextOverflow.fade))),
        DataCell(Text(timeAgo(DateTime.parse(messages.elementAt(index).createdAt)))),
        DataCell(Text(messages.elementAt(index).userName)),
        DataCell(Text(messages.elementAt(index).gmail)),
        DataCell(Text(messages.elementAt(index).facultyName)),
        DataCell(
          _btnDelete(context, messages.elementAt(index).messageId)
        ),
      ]
    );
  }
  
  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;
  
  @override
  // TODO: implement rowCount
  int get rowCount => messages.length;
  
  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

String timeAgo(DateTime d) {
 Duration diff = DateTime.now().difference(d);
 if (diff.inDays > 365)
  return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "một năm" : "năm"} trước";
 if (diff.inDays > 30)
  return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "tháng" : "tháng"} trước";
 if (diff.inDays > 7)
  return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "tuần" : "tuần"} trước";
 if (diff.inDays > 0)
  return "${diff.inDays} ${diff.inDays == 1 ? "một ngày" : "ngày"} trước";
 if (diff.inHours > 0)
  return "${diff.inHours} ${diff.inHours == 1 ? "giờ" : "giờ"} trước";
 if (diff.inMinutes > 0)
  return "${diff.inMinutes} ${diff.inMinutes == 1 ? "phút" : "phút"} trước";
 return "vừa xong";
}