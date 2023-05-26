
import 'package:edubot/faculty/faculty_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class FacultyState extends Equatable{}

class LoadingFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}

class LoadedFaculty extends FacultyState{
  List<Faculty> faculties;
  LoadedFaculty(this.faculties);
  @override
  List<Object?> get props => [faculties];
}

class FailureFaculty extends FacultyState{
  String error;
  FailureFaculty(this.error);
  
  @override
  List<Object?> get props => [error];
}

class AddingFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}

class AddedFaculty extends FacultyState{
  @override
  List<Object?> get props => [];

}

class UpdatingFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}

class UpdatedFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}

class DeletingFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}

class DeletedFaculty extends FacultyState{
  @override
  List<Object?> get props => [];
}