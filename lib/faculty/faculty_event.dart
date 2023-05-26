
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class FacultyEvent extends Equatable{}

class AddFacultyEvent extends FacultyEvent{
  String name;
  AddFacultyEvent({required this.name});
  
  @override
  // TODO: implement props
  List<Object?> get props => [name];
}

class GetFacultiesEvent extends FacultyEvent{
  int page;
  int size;
  String? search;
  
  GetFacultiesEvent({required this.page, required this.size, this.search});
  
  @override
  // TODO: implement props
  List<Object?> get props => [page,size,search];
}

class DeleteFacultyEvent extends FacultyEvent{
  int id;
  DeleteFacultyEvent({required this.id});
  
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class UpdateFacultyEvent extends FacultyEvent{
  int id;
  String name;
  UpdateFacultyEvent({required this.id, required this.name});
  
  @override
  // TODO: implement props
  List<Object?> get props => [id,name];
}