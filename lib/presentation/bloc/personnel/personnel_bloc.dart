import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/utils/utils.dart';
import '../../../data/models/personnel_model.dart';
import '../../../domain/entities/personnel.dart';
import '../../../domain/usecases/personnel_usecases.dart';

// Events
abstract class PersonnelEvent extends Equatable {
  const PersonnelEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllPersonnelEvent extends PersonnelEvent {}

class LoadPersonnelByGroupEvent extends PersonnelEvent {
  final String group;

  const LoadPersonnelByGroupEvent({required this.group});

  @override
  List<Object?> get props => [group];
}

class UpdatePersonnelEvent extends PersonnelEvent {
  final Personnel personnel;

  const UpdatePersonnelEvent({required this.personnel});

  @override
  List<Object?> get props => [personnel];
}

class AddPersonnelEvent extends PersonnelEvent {
  final String name;
  final String role;
  final String group;

  const AddPersonnelEvent({
    required this.name,
    required this.role,
    required this.group,
  });

  @override
  List<Object?> get props => [name, role, group];
}

class RemovePersonnelEvent extends PersonnelEvent {
  final String id;

  const RemovePersonnelEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class MovePersonnelEvent extends PersonnelEvent {
  final String personnelId;
  final String newGroup;
  final String newRole;

  const MovePersonnelEvent({
    required this.personnelId,
    required this.newGroup,
    required this.newRole,
  });

  @override
  List<Object?> get props => [personnelId, newGroup, newRole];
}

// States
abstract class PersonnelState extends Equatable {
  const PersonnelState();

  @override
  List<Object?> get props => [];
}

class PersonnelInitial extends PersonnelState {}

class PersonnelLoading extends PersonnelState {}

class PersonnelLoaded extends PersonnelState {
  final List<Personnel> personnel;

  const PersonnelLoaded({required this.personnel});

  @override
  List<Object?> get props => [personnel];
}

class PersonnelError extends PersonnelState {
  final String message;

  const PersonnelError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PersonnelUpdated extends PersonnelState {}

class PersonnelAdded extends PersonnelState {
  final Personnel personnel;

  const PersonnelAdded({required this.personnel});

  @override
  List<Object?> get props => [personnel];
}

class PersonnelRemoved extends PersonnelState {
  final String id;

  const PersonnelRemoved({required this.id});

  @override
  List<Object?> get props => [id];
}

class PersonnelMoved extends PersonnelState {
  final String personnelId;
  final String newGroup;
  final String newRole;

  const PersonnelMoved({
    required this.personnelId,
    required this.newGroup,
    required this.newRole,
  });

  @override
  List<Object?> get props => [personnelId, newGroup, newRole];
}

// BLoC
class PersonnelBloc extends Bloc<PersonnelEvent, PersonnelState> {
  final PersonnelUseCases personnelUseCases;

  PersonnelBloc({required this.personnelUseCases}) : super(PersonnelInitial()) {
    on<LoadAllPersonnelEvent>(_onLoadAllPersonnel);
    on<LoadPersonnelByGroupEvent>(_onLoadPersonnelByGroup);
    on<UpdatePersonnelEvent>(_onUpdatePersonnel);
    on<AddPersonnelEvent>(_onAddPersonnel);
    on<RemovePersonnelEvent>(_onRemovePersonnel);
    on<MovePersonnelEvent>(_onMovePersonnel);
  }

  Future<void> _onLoadAllPersonnel(
    LoadAllPersonnelEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      final personnel = await personnelUseCases.getAllPersonnel();
      emit(PersonnelLoaded(personnel: personnel));
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }

  Future<void> _onLoadPersonnelByGroup(
    LoadPersonnelByGroupEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      final personnel = await personnelUseCases.getPersonnelByGroup(event.group);
      emit(PersonnelLoaded(personnel: personnel));
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePersonnel(
    UpdatePersonnelEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      await personnelUseCases.updatePersonnel(event.personnel);
      emit(PersonnelUpdated());
      // Reload personnel after update
      add(LoadAllPersonnelEvent());
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }

  Future<void> _onAddPersonnel(
    AddPersonnelEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      final personnel = PersonnelModel(
        id: Utils.generateUniqueId(),
        name: event.name,
        role: event.role,
        group: event.group,
        status: PersonnelStatus.present,
      );
      await personnelUseCases.addPersonnel(personnel);
      emit(PersonnelAdded(personnel: personnel));
      // Reload personnel after adding
      add(LoadAllPersonnelEvent());
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }

  Future<void> _onRemovePersonnel(
    RemovePersonnelEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      await personnelUseCases.removePersonnel(event.id);
      emit(PersonnelRemoved(id: event.id));
      // Reload personnel after removal
      add(LoadAllPersonnelEvent());
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }

  Future<void> _onMovePersonnel(
    MovePersonnelEvent event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());
    try {
      await personnelUseCases.movePersonnel(
        event.personnelId,
        event.newGroup,
        event.newRole,
      );
      emit(PersonnelMoved(
        personnelId: event.personnelId,
        newGroup: event.newGroup,
        newRole: event.newRole,
      ));
      // Reload personnel after move
      add(LoadAllPersonnelEvent());
    } catch (e) {
      emit(PersonnelError(message: e.toString()));
    }
  }
}
