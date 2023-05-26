import 'package:edubot/answer/answer_model.dart';
import 'package:edubot/answer/answer_repository.dart';
import 'package:edubot/question/question_repository.dart';
import 'package:edubot/screens/question.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  int? dropdownValue;
  String? question;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token')),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return FutureBuilder<List<Answer>>(
          future: AnswerRepository(snapshot.data ?? "").getAnswers(),
          builder: ((context, snapshot) {
            if(snapshot.hasData){
              List<Answer> answers = snapshot.data ?? [];
              // TextEditingController questionIdController = TextEditingController();
              TextEditingController questionKeywordController = TextEditingController();
              questionKeywordController.text = question ?? "";
              return Scaffold(
                appBar: AppBar(title: const Text("Thêm câu hỏi")),
                body: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(children: [
                    const SizedBox(height: 10),
                    DropdownButton<int>(
                      hint: const Text("Câu trả lời"),
                      isExpanded: true,
                      items: answers.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                        value: e.answerId,
                        child: Text(answers.firstWhere((element) => element.answerId == e.answerId).content),
                      )).toList(),
                      value: dropdownValue,
                      onChanged: (int? value){
                        setState(() {
                          dropdownValue = value;
                          question = question;
                        });
                    }),
    
                    const SizedBox(height: 10),
                    TextField(
                      controller: questionKeywordController,
                      obscureText: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Câu hỏi',
                      ),
                      onChanged: (value) {
                        setState(() {
                          question = question!.isEmpty ? value : question.toString() + value;
                          //question = value;
                        });
                      },
                    ),
                    
                    
                    const SizedBox(height: 10.0),
                    InkWell(
                      onTap: () async {
                        try {
                          if(dropdownValue == null){
                            MotionToast.error(
                              description: Text("Bạn chưa chọn câu trả lời!")
                            ).show(context);
                          } else if(questionKeywordController.text.isEmpty){
                            MotionToast.error(
                              description: Text("Câu hỏi không được để trống!")
                            ).show(context);
                          }else{
                            String token = await SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString());
                            bool status = await QuestionRepository(token).addQuestion(questionKeywordController.text, dropdownValue!);
                            if(status == true){
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const QuestionListView()),
                              );
                            } else {
                              MotionToast.error(
                                description: Text("Lỗi! Vui lòng thử lại sau")
                              ).show(context);
                            }
                          }
                        } catch (e) {
                          MotionToast.error(
                            description: Text(e.toString())
                          ).show(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(child: Text("Thêm câu hỏi",style: TextStyle(color: Colors.white),)),
                      ),
                    )
                  ]),
                ),
              );
            } else{
              return Center(child: CircularProgressIndicator());
            }
          })
        );
        }
        return CircularProgressIndicator();
      }
    );
  }
}