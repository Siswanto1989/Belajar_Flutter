import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/utils/utils.dart';
import '../../../data/models/report_model.dart';
import '../../../domain/entities/report.dart';
import '../../../domain/usecases/report_usecases.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllReportsEvent extends ReportEvent {}

class LoadReportByIdEvent extends ReportEvent {
  final String id;

  const LoadReportByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class SaveReportEvent extends ReportEvent {
  final Report report;

  const SaveReportEvent({required this.report});

  @override
  List<Object?> get props => [report];
}

class DeleteReportEvent extends ReportEvent {
  final String id;

  const DeleteReportEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ShareReportAsImageEvent extends ReportEvent {
  final BuildContext context;
  final String reportId;
  final GlobalKey reportKey;

  const ShareReportAsImageEvent({
    required this.context,
    required this.reportId,
    required this.reportKey,
  });

  @override
  List<Object?> get props => [context, reportId, reportKey];
}

class SaveReportAsImageEvent extends ReportEvent {
  final GlobalKey reportKey;
  final String reportId;

  const SaveReportAsImageEvent({
    required this.reportKey,
    required this.reportId,
  });

  @override
  List<Object?> get props => [reportKey, reportId];
}

// States
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<Report> reports;

  const ReportsLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

class ReportLoaded extends ReportState {
  final Report report;

  const ReportLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

class ReportSaved extends ReportState {
  final Report report;

  const ReportSaved({required this.report});

  @override
  List<Object?> get props => [report];
}

class ReportDeleted extends ReportState {
  final String id;

  const ReportDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

class ReportShared extends ReportState {
  final String? path;

  const ReportShared({required this.path});

  @override
  List<Object?> get props => [path];
}

class ReportImageSaved extends ReportState {
  final String? path;

  const ReportImageSaved({required this.path});

  @override
  List<Object?> get props => [path];
}

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportUseCases reportUseCases;

  ReportBloc({required this.reportUseCases}) : super(ReportInitial()) {
    on<LoadAllReportsEvent>(_onLoadAllReports);
    on<LoadReportByIdEvent>(_onLoadReportById);
    on<SaveReportEvent>(_onSaveReport);
    on<DeleteReportEvent>(_onDeleteReport);
    on<ShareReportAsImageEvent>(_onShareReportAsImage);
    on<SaveReportAsImageEvent>(_onSaveReportAsImage);
  }

  Future<void> _onLoadAllReports(
    LoadAllReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final reports = await reportUseCases.getAllReports();
      emit(ReportsLoaded(reports: reports));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadReportById(
    LoadReportByIdEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final report = await reportUseCases.getReportById(event.id);
      if (report != null) {
        emit(ReportLoaded(report: report));
      } else {
        emit(const ReportError(message: 'Report not found'));
      }
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onSaveReport(
    SaveReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      await reportUseCases.saveReport(event.report);
      emit(ReportSaved(report: event.report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onDeleteReport(
    DeleteReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      await reportUseCases.deleteReport(event.id);
      emit(ReportDeleted(id: event.id));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onShareReportAsImage(
    ShareReportAsImageEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final path = await reportUseCases.shareReportAsImage(
        event.context,
        event.reportId,
        event.reportKey,
      );
      emit(ReportShared(path: path));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onSaveReportAsImage(
    SaveReportAsImageEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final path = await reportUseCases.saveReportAsImage(
        event.reportKey,
        event.reportId,
      );
      emit(ReportImageSaved(path: path));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }
}
