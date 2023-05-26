import 'package:edubot/faculty/faculty_event.dart';
import 'package:edubot/faculty/faculty_repository.dart';
import 'package:edubot/faculty/faculty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FacultyBloc extends Bloc<FacultyEvent, FacultyState>{
  final FacultyRepository _facultyRepository;
  FacultyBloc(this._facultyRepository) : super(LoadingFaculty()){
    on<AddFacultyEvent>((event, emit) async {
      try{
        emit(AddingFaculty());
        await _facultyRepository.addFaculty(event.name);
        emit(AddedFaculty());
      } catch (e){
        emit(FailureFaculty(e.toString()));
      }
    });
    on<GetFacultiesEvent>((event, emit) async {
      try {
        emit(LoadingFaculty());
        var data = await _facultyRepository.getFaculties();
        emit(LoadedFaculty(data));
      } catch (e) {
        emit(FailureFaculty(e.toString()));
      }
    });
    on<DeleteFacultyEvent>((event, emit) async {
      try {
        emit(DeletingFaculty());
        await _facultyRepository.deleteFaculty(event.id);
        emit(DeletedFaculty());
      } catch (e){
        emit(FailureFaculty(e.toString()));
      }
    });
    on<UpdateFacultyEvent>((event, emit) async {
      try {
        emit(UpdatingFaculty());
        await _facultyRepository.updateFaculty(event.id, event.name);
        emit(UpdatedFaculty()); 
      } catch (e) {
        emit(FailureFaculty(e.toString()));
      }
    });
  }
}