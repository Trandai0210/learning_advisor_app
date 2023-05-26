
import 'package:edubot/answer/add_answer_cubit.dart';
import 'package:edubot/answer/answer_repository.dart';
import 'package:edubot/answer/answer_state.dart';
import 'package:edubot/screens/answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAnswerPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddAnswerCubit, AddAnswerState>(listener: (context, state){
        if(state is AddAnswerError){
          MotionToast.error(
            description: Text(state.error)
          ).show(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thêm câu trả lời"),
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: BlocBuilder<AddAnswerCubit,AddAnswerState>(
            builder: ((context, state) {
              if(state is AddingAnswer){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if(state is AddedAnswer){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnswerPage()));
              }
              if(state is AddAnswerError){
                return Center(child: Text("Lỗi: "+state.error));
              }
              return _body(context);
            })
          ),
        ),
      ),
    );
  }
  Widget _body(context){
    return Column(
      children: [
        TextField(
          autofocus: true,
          controller: _controller,
          decoration: const InputDecoration(hintText: "Nhập câu trả lời..."),
        ),
        const SizedBox(height: 10.0),
        InkWell(
          onTap: () async {
            try {
              final answer = _controller.text;
              if(_controller.text.isEmpty){
                MotionToast.error(
                  description: Text("Câu trả lời không được để trống! ")
                ).show(context);
              }else{
                String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                bool status = await AnswerRepository(token).addAnswer(answer);
                if(status == true){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnswerPage())); 
                }
              }
            } catch (e) {
              MotionToast.error(
                description: Text(e.toString())
              ).show(context);
            }
          },
          child: _addBtn(context),
        )
      ],
    );
  }

  Widget _addBtn(context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: BlocBuilder<AddAnswerCubit, AddAnswerState>(
          builder: (context, state) {
            if (state is AnswerAddingState) return const CircularProgressIndicator();
            return const Text(
              "Thêm câu trả lời",
              style: TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

