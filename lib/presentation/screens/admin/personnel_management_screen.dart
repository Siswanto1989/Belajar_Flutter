import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/personnel_model.dart';
import '../../../domain/entities/personnel.dart';
import '../../bloc/personnel/personnel_bloc.dart';

class PersonnelManagementScreen extends StatefulWidget {
  const PersonnelManagementScreen({Key? key}) : super(key: key);

  @override
  State<PersonnelManagementScreen> createState() => _PersonnelManagementScreenState();
}

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedGroup = 'Grup 1';
  String _selectedRole = 'Foreman';
  Personnel? _selectedPersonnel;
  String _newGroup = 'Grup 1';
  String _newRole = 'Foreman';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<PersonnelBloc>().add(LoadAllPersonnelEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grup 1'),
            Tab(text: 'Grup 2'),
            Tab(text: 'Grup 3'),
            Tab(text: 'Grup 4'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGroupTab('Grup 1'),
                _buildGroupTab('Grup 2'),
                _buildGroupTab('Grup 3'),
                _buildGroupTab('Grup 4'),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildGroupTab(String group) {
    return BlocBuilder<PersonnelBloc, PersonnelState>(
      builder: (context, state) {
        if (state is PersonnelLoading) {
          return const LoadingWidget();
        } else if (state is PersonnelError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => context.read<PersonnelBloc>().add(LoadAllPersonnelEvent()),
          );
        } else if (state is PersonnelLoaded) {
          final groupPersonnel = state.personnel
              .where((p) => p.group == group)
              .toList()
            ..sort((a, b) => a.role.compareTo(b.role));

          if (groupPersonnel.isEmpty) {
            return const Center(
              child: Text('No personnel in this group'),
            );
          }

          return ListView.builder(
            itemCount: groupPersonnel.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final personnel = groupPersonnel[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2.0,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(personnel.name.substring(0, 1)),
                  ),
                  title: Text(personnel.name),
                  subtitle: Text(personnel.role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showReassignDialog(personnel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(personnel),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: AppButton(
        text: 'Add New Personnel',
        onPressed: _showAddPersonnelDialog,
        icon: Icons.add,
        isFullWidth: true,
      ),
    );
  }

  void _showAddPersonnelDialog() {
    _nameController.clear();
    _selectedGroup = 'Grup 1';
    _selectedRole = 'Foreman';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Personnel'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              AppDropdown<String>(
                label: 'Group',
                value: _selectedGroup,
                items: ['Grup 1', 'Grup 2', 'Grup 3', 'Grup 4'],
                onChanged: (value) {
                  setState(() {
                    _selectedGroup = value!;
                  });
                },
                itemLabel: (value) => value,
              ),
              AppDropdown<String>(
                label: 'Role',
                value: _selectedRole,
                items: ['Foreman', 'Inspektor 1', 'Inspektor 2', 'Inspektor 3'],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                itemLabel: (value) => value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<PersonnelBloc>().add(
                      AddPersonnelEvent(
                        name: _nameController.text.trim(),
                        role: _selectedRole,
                        group: _selectedGroup,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(Personnel personnel) {
    _selectedPersonnel = personnel;
    _newGroup = personnel.group;
    _newRole = personnel.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reassign Personnel'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reassigning: ${personnel.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  label: 'Group',
                  value: _newGroup,
                  items: ['Grup 1', 'Grup 2', 'Grup 3', 'Grup 4'],
                  onChanged: (value) {
                    setState(() {
                      _newGroup = value!;
                    });
                  },
                  itemLabel: (value) => value,
                ),
                AppDropdown<String>(
                  label: 'Role',
                  value: _newRole,
                  items: ['Foreman', 'Inspektor 1', 'Inspektor 2', 'Inspektor 3'],
                  onChanged: (value) {
                    setState(() {
                      _newRole = value!;
                    });
                  },
                  itemLabel: (value) => value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonnelBloc>().add(
                        MovePersonnelEvent(
                          personnelId: personnel.id,
                          newGroup: _newGroup,
                          newRole: _newRole,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Personnel personnel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${personnel.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PersonnelBloc>().add(
                    RemovePersonnelEvent(id: personnel.id),
                  );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
