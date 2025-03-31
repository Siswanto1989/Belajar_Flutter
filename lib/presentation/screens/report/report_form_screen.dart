import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/personnel_model.dart';
import '../../../data/models/report_model.dart';
import '../../../domain/entities/personnel.dart';
import '../../../domain/entities/report.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/personnel/personnel_bloc.dart';
import '../../bloc/report/report_bloc.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Report form state
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Shift 1';
  String? _selectedForemanName;
  Personnel? _foreman;
  Personnel? _inspector1;
  Personnel? _inspector2;
  Personnel? _inspector3;
  PersonnelStatus _foremanStatus = PersonnelStatus.present;
  PersonnelStatus _inspector1Status = PersonnelStatus.present;
  PersonnelStatus _inspector2Status = PersonnelStatus.present;
  PersonnelStatus _inspector3Status = PersonnelStatus.present;
  List<Personnel> _overtimePersonnel = [];
  bool _hasOvertimePersonnel = false;
  String? _selectedOvertimePersonnel;

  // Equipment state
  SafetyTalkStatus _safetyTalkStatus = SafetyTalkStatus.conducted;
  EquipmentStatus _measuringToolsStatus = EquipmentStatus.ok;
  EquipmentStatus _flashlightStatus = EquipmentStatus.ok;
  EquipmentStatus _mobilePhoneStatus = EquipmentStatus.ok;
  EquipmentStatus _cameraStatus = EquipmentStatus.ok;

  // Usage Decision section
  bool _hasUDSection = false;
  final Map<String, MaterialEntryState> _udMaterials = {};
  final _udIssueController = TextEditingController();
  final _udFollowUpController = TextEditingController();
  final _udRemarkController = TextEditingController();

  // Shipment HR section
  bool _hasShipmentSection = false;
  final Map<String, MaterialEntryState> _shipmentMaterials = {};

  // Pre-Delivery section
  bool _hasPreDeliverySection = false;
  final Map<String, MaterialEntryState> _preDeliveryMaterials = {};

  // Reinspection section
  bool _hasReinspectionSection = false;
  final List<ReinspectionState> _reinspections = [];

  int _currentPage = 0;
  bool _isLoading = false;
  late String _currentUserId;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeForm();
    
    // Initialize material maps
    for (var type in AppConstants.materialTypesUD) {
      _udMaterials[type] = MaterialEntryState(
        bundlesController: TextEditingController(),
        tonnageController: TextEditingController(),
      );
    }
    
    for (var type in AppConstants.materialTypesShipment) {
      _shipmentMaterials[type] = MaterialEntryState(
        bundlesController: TextEditingController(),
        tonnageController: TextEditingController(),
      );
    }
    
    for (var type in AppConstants.materialTypesPreDelivery) {
      _preDeliveryMaterials[type] = MaterialEntryState(
        bundlesController: TextEditingController(),
        tonnageController: TextEditingController(),
      );
    }
  }

  void _getCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
      _currentUserName = authState.user.name;
    }
  }

  void _initializeForm() {
    context.read<PersonnelBloc>().add(LoadAllPersonnelEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _udIssueController.dispose();
    _udFollowUpController.dispose();
    _udRemarkController.dispose();
    
    // Dispose all material controllers
    for (var entry in _udMaterials.values) {
      entry.bundlesController.dispose();
      entry.tonnageController.dispose();
    }
    
    for (var entry in _shipmentMaterials.values) {
      entry.bundlesController.dispose();
      entry.tonnageController.dispose();
    }
    
    for (var entry in _preDeliveryMaterials.values) {
      entry.bundlesController.dispose();
      entry.tonnageController.dispose();
    }
    
    // Dispose all reinspection controllers
    for (var reinspection in _reinspections) {
      reinspection.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Create Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitConfirmation,
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildHeaderPage(),
            _buildEquipmentPage(),
            _buildUsageDecisionPage(),
            _buildShipmentPage(),
            _buildPreDeliveryPage(),
            _buildReinspectionPage(),
            _buildReviewPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildHeaderPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Report Information'),
          const SizedBox(height: 16.0),
          
          // Date field
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Utils.formatDate(_selectedDate)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Shift selection
          AppDropdown<String>(
            label: 'Shift',
            value: _selectedShift,
            items: AppConstants.shifts,
            onChanged: (value) {
              setState(() {
                _selectedShift = value!;
              });
            },
            itemLabel: (value) => value,
          ),
          
          const SizedBox(height: 24.0),
          _buildSectionTitle('Personnel'),
          const SizedBox(height: 16.0),
          
          // Foreman selection
          BlocBuilder<PersonnelBloc, PersonnelState>(
            builder: (context, state) {
              if (state is PersonnelLoading) {
                return const LoadingWidget();
              } else if (state is PersonnelLoaded) {
                final foremanOptions = _getForemanOptions(state.personnel);
                
                return Column(
                  children: [
                    AppDropdown<String>(
                      label: 'Foreman',
                      hint: 'Select Foreman',
                      value: _selectedForemanName,
                      items: foremanOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedForemanName = value;
                          _updateInspectors(value);
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a foreman';
                        }
                        return null;
                      },
                      itemLabel: (value) => value,
                    ),
                    
                    if (_selectedForemanName != null) ...[
                      AppDropdown<PersonnelStatus>(
                        label: 'Status',
                        value: _foremanStatus,
                        items: [
                          PersonnelStatus.present,
                          PersonnelStatus.sick,
                          PersonnelStatus.permission,
                          PersonnelStatus.leave,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _foremanStatus = value!;
                          });
                        },
                        itemLabel: (value) => Personnel.statusToString(value),
                      ),
                    ],
                    
                    if (_inspector1 != null) ...[
                      const SizedBox(height: 16.0),
                      _buildInspectorField(
                        'Inspector 1',
                        _inspector1!.name,
                        _inspector1Status,
                        (value) {
                          setState(() {
                            _inspector1Status = value!;
                          });
                        },
                      ),
                    ],
                    
                    if (_inspector2 != null) ...[
                      const SizedBox(height: 16.0),
                      _buildInspectorField(
                        'Inspector 2',
                        _inspector2!.name,
                        _inspector2Status,
                        (value) {
                          setState(() {
                            _inspector2Status = value!;
                          });
                        },
                      ),
                    ],
                    
                    if (_inspector3 != null) ...[
                      const SizedBox(height: 16.0),
                      _buildInspectorField(
                        'Inspector 3',
                        _inspector3!.name,
                        _inspector3Status,
                        (value) {
                          setState(() {
                            _inspector3Status = value!;
                          });
                        },
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 24.0),
          _buildSectionTitle('Overtime Personnel'),
          
          // Overtime personnel section
          Row(
            children: [
              Checkbox(
                value: _hasOvertimePersonnel,
                onChanged: (value) {
                  setState(() {
                    _hasOvertimePersonnel = value!;
                    if (!_hasOvertimePersonnel) {
                      _overtimePersonnel.clear();
                    }
                  });
                },
              ),
              const Text('Add overtime personnel'),
            ],
          ),
          
          if (_hasOvertimePersonnel) ...[
            BlocBuilder<PersonnelBloc, PersonnelState>(
              builder: (context, state) {
                if (state is PersonnelLoaded) {
                  final allPersonnelNames = AppConstants.getAllPersonnelNames();
                  
                  return Column(
                    children: [
                      AppDropdown<String>(
                        hint: 'Select Personnel',
                        value: _selectedOvertimePersonnel,
                        items: allPersonnelNames,
                        onChanged: (value) {
                          setState(() {
                            _selectedOvertimePersonnel = value;
                          });
                        },
                        itemLabel: (value) => value,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Add Personnel',
                              onPressed: _selectedOvertimePersonnel == null
                                  ? null
                                  : _addOvertimePersonnel,
                              type: AppButtonType.secondary,
                              icon: Icons.add,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      _buildOvertimePersonnelList(),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEquipmentPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Safety Talk'),
          const SizedBox(height: 16.0),
          
          AppDropdown<SafetyTalkStatus>(
            label: 'Safety Talk Status',
            value: _safetyTalkStatus,
            items: const [SafetyTalkStatus.conducted, SafetyTalkStatus.notConducted],
            onChanged: (value) {
              setState(() {
                _safetyTalkStatus = value!;
              });
            },
            itemLabel: (value) => ReportModel.safetyTalkStatusToString(value),
          ),
          
          const SizedBox(height: 24.0),
          _buildSectionTitle('Equipment Status'),
          const SizedBox(height: 16.0),
          
          AppDropdown<EquipmentStatus>(
            label: 'Measuring Tools',
            value: _measuringToolsStatus,
            items: const [EquipmentStatus.ok, EquipmentStatus.notOk],
            onChanged: (value) {
              setState(() {
                _measuringToolsStatus = value!;
              });
            },
            itemLabel: (value) => value == EquipmentStatus.ok ? 'Terkalibrasi' : 'Tidak OK',
          ),
          
          AppDropdown<EquipmentStatus>(
            label: 'Flashlight',
            value: _flashlightStatus,
            items: const [EquipmentStatus.ok, EquipmentStatus.notOk],
            onChanged: (value) {
              setState(() {
                _flashlightStatus = value!;
              });
            },
            itemLabel: (value) => ReportModel.equipmentStatusToString(value),
          ),
          
          AppDropdown<EquipmentStatus>(
            label: 'Mobile Phone',
            value: _mobilePhoneStatus,
            items: const [EquipmentStatus.ok, EquipmentStatus.notOk],
            onChanged: (value) {
              setState(() {
                _mobilePhoneStatus = value!;
              });
            },
            itemLabel: (value) => ReportModel.equipmentStatusToString(value),
          ),
          
          AppDropdown<EquipmentStatus>(
            label: 'Camera',
            value: _cameraStatus,
            items: const [EquipmentStatus.ok, EquipmentStatus.notOk],
            onChanged: (value) {
              setState(() {
                _cameraStatus = value!;
              });
            },
            itemLabel: (value) => ReportModel.equipmentStatusToString(value),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageDecisionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Usage Decision (UD)'),
          
          Row(
            children: [
              Checkbox(
                value: _hasUDSection,
                onChanged: (value) {
                  setState(() {
                    _hasUDSection = value!;
                  });
                },
              ),
              const Text('Include Usage Decision data'),
            ],
          ),
          
          if (_hasUDSection) ...[
            const SizedBox(height: 16.0),
            const Text(
              'Enter material data for UD:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            
            ...AppConstants.materialTypesUD.map((type) => _buildMaterialEntry(
              type, 
              _udMaterials[type]!.bundlesController,
              _udMaterials[type]!.tonnageController,
            )).toList(),
            
            const SizedBox(height: 24.0),
            _buildSectionTitle('Issues and Follow-up'),
            const SizedBox(height: 16.0),
            
            AppTextField.multiline(
              label: 'Issues (if any)',
              controller: _udIssueController,
              hint: 'Describe any issues encountered',
            ),
            
            AppTextField.multiline(
              label: 'Follow-up Actions',
              controller: _udFollowUpController,
              hint: 'Describe follow-up actions taken',
            ),
            
            AppTextField.multiline(
              label: 'Remarks',
              controller: _udRemarkController,
              hint: 'Additional remarks or notes',
            ),
          ],
          
          if (!_hasUDSection) ...[
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'No Usage Decision data for this report',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShipmentPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Shipment HR'),
          
          Row(
            children: [
              Checkbox(
                value: _hasShipmentSection,
                onChanged: (value) {
                  setState(() {
                    _hasShipmentSection = value!;
                  });
                },
              ),
              const Text('Include Shipment HR data'),
            ],
          ),
          
          if (_hasShipmentSection) ...[
            const SizedBox(height: 16.0),
            const Text(
              'Enter material data for Shipment HR:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            
            ...AppConstants.materialTypesShipment.map((type) => _buildMaterialEntry(
              type, 
              _shipmentMaterials[type]!.bundlesController,
              _shipmentMaterials[type]!.tonnageController,
            )).toList(),
          ],
          
          if (!_hasShipmentSection) ...[
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'No Shipment HR data for this report',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreDeliveryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pre-Delivery Inspection'),
          
          Row(
            children: [
              Checkbox(
                value: _hasPreDeliverySection,
                onChanged: (value) {
                  setState(() {
                    _hasPreDeliverySection = value!;
                  });
                },
              ),
              const Text('Include Pre-Delivery Inspection data'),
            ],
          ),
          
          if (_hasPreDeliverySection) ...[
            const SizedBox(height: 16.0),
            const Text(
              'Enter material data for Pre-Delivery:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            
            ...AppConstants.materialTypesPreDelivery.map((type) => _buildMaterialEntry(
              type, 
              _preDeliveryMaterials[type]!.bundlesController,
              _preDeliveryMaterials[type]!.tonnageController,
            )).toList(),
          ],
          
          if (!_hasPreDeliverySection) ...[
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'No Pre-Delivery Inspection data for this report',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReinspectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Reinspection'),
          
          Row(
            children: [
              Checkbox(
                value: _hasReinspectionSection,
                onChanged: (value) {
                  setState(() {
                    _hasReinspectionSection = value!;
                    if (!_hasReinspectionSection) {
                      _reinspections.clear();
                    }
                  });
                },
              ),
              const Text('Include Reinspection data'),
            ],
          ),
          
          if (_hasReinspectionSection) ...[
            const SizedBox(height: 16.0),
            
            // List of reinspections
            if (_reinspections.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reinspections.length,
                itemBuilder: (context, index) {
                  final reinspection = _reinspections[index];
                  return _buildReinspectionEntry(index, reinspection);
                },
              ),
            ],
            
            const SizedBox(height: 16.0),
            AppButton(
              text: 'Add Reinspection',
              onPressed: _addReinspection,
              icon: Icons.add,
              type: AppButtonType.secondary,
            ),
          ],
          
          if (!_hasReinspectionSection) ...[
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'No Reinspection data for this report',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is ReportSaved) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report saved successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        } else if (state is ReportError) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Review Report'),
            const SizedBox(height: 16.0),
            
            _buildReviewSection(
              'Report Information',
              [
                'Date: ${Utils.formatDate(_selectedDate)}',
                'Shift: $_selectedShift',
              ],
            ),
            
            _buildReviewSection(
              'Personnel',
              [
                'Foreman: ${_foreman?.name ?? 'Not selected'} ${_foreman != null && _foremanStatus != PersonnelStatus.present ? "(${Personnel.statusToString(_foremanStatus)})" : ""}',
                'Inspector 1: ${_inspector1?.name ?? 'Not selected'} ${_inspector1 != null && _inspector1Status != PersonnelStatus.present ? "(${Personnel.statusToString(_inspector1Status)})" : ""}',
                'Inspector 2: ${_inspector2?.name ?? 'Not selected'} ${_inspector2 != null && _inspector2Status != PersonnelStatus.present ? "(${Personnel.statusToString(_inspector2Status)})" : ""}',
                'Inspector 3: ${_inspector3?.name ?? 'Not selected'} ${_inspector3 != null && _inspector3Status != PersonnelStatus.present ? "(${Personnel.statusToString(_inspector3Status)})" : ""}',
                if (_overtimePersonnel.isNotEmpty)
                  'Overtime Personnel: ${_overtimePersonnel.map((p) => p.name).join(', ')}',
              ],
            ),
            
            _buildReviewSection(
              'Equipment',
              [
                'Safety Talk: ${ReportModel.safetyTalkStatusToString(_safetyTalkStatus)}',
                'Measuring Tools: ${_measuringToolsStatus == EquipmentStatus.ok ? 'Terkalibrasi' : 'Tidak OK'}',
                'Flashlight: ${ReportModel.equipmentStatusToString(_flashlightStatus)}',
                'Mobile Phone: ${ReportModel.equipmentStatusToString(_mobilePhoneStatus)}',
                'Camera: ${ReportModel.equipmentStatusToString(_cameraStatus)}',
              ],
            ),
            
            if (_hasUDSection) ...[
              _buildReviewSection(
                'Usage Decision (UD)',
                _getUDMaterialReviewItems(),
              ),
            ],
            
            if (_hasShipmentSection) ...[
              _buildReviewSection(
                'Shipment HR',
                _getShipmentMaterialReviewItems(),
              ),
            ],
            
            if (_hasPreDeliverySection) ...[
              _buildReviewSection(
                'Pre-Delivery Inspection',
                _getPreDeliveryMaterialReviewItems(),
              ),
            ],
            
            if (_hasReinspectionSection && _reinspections.isNotEmpty) ...[
              _buildReviewSection(
                'Reinspection',
                _getReinspectionReviewItems(),
              ),
            ],
            
            const SizedBox(height: 24.0),
            AppButton(
              text: 'Submit Report',
              onPressed: _isLoading ? null : _submitReport,
              isLoading: _isLoading,
              isFullWidth: true,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInspectorField(
    String label,
    String name,
    PersonnelStatus status,
    void Function(PersonnelStatus?) onStatusChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(name),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: AppDropdown<PersonnelStatus>(
                label: 'Status',
                value: status,
                items: [
                  PersonnelStatus.present,
                  PersonnelStatus.sick,
                  PersonnelStatus.permission,
                  PersonnelStatus.leave,
                ],
                onChanged: onStatusChanged,
                itemLabel: (value) => Personnel.statusToString(value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialEntry(
    String type,
    TextEditingController bundlesController,
    TextEditingController tonnageController,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: AppTextField.integer(
                    label: 'Bundles',
                    controller: bundlesController,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: AppTextField.number(
                    label: 'Tonnage',
                    controller: tonnageController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReinspectionEntry(int index, ReinspectionState reinspection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reinspection ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeReinspection(index),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            AppTextField(
              label: 'Reinspection Name',
              controller: reinspection.nameController,
              validator: ValidationUtils.validateRequired,
            ),
            Row(
              children: [
                Expanded(
                  child: AppTextField.integer(
                    label: 'Total Bundles',
                    controller: reinspection.totalBundlesController,
                    validator: ValidationUtils.validateRequiredNumeric,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: AppTextField.integer(
                    label: 'Reinspected Bundles',
                    controller: reinspection.reinspectedBundlesController,
                    validator: ValidationUtils.validateRequiredNumeric,
                  ),
                ),
              ],
            ),
            AppTextField.integer(
              label: 'Pending Bundles',
              controller: reinspection.pendingBundlesController,
              validator: ValidationUtils.validateRequiredNumeric,
            ),
            AppTextField.multiline(
              label: 'Issues (if any)',
              controller: reinspection.issueController,
            ),
            AppTextField.multiline(
              label: 'Follow-up Actions',
              controller: reinspection.followUpController,
            ),
            AppTextField.multiline(
              label: 'Remarks',
              controller: reinspection.remarkController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimePersonnelList() {
    if (_overtimePersonnel.isEmpty) {
      return const Center(
        child: Text(
          'No overtime personnel added',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _overtimePersonnel.length,
      itemBuilder: (context, index) {
        final personnel = _overtimePersonnel[index];
        return ListTile(
          title: Text(personnel.name),
          subtitle: Text(personnel.role),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeOvertimePersonnel(index),
          ),
        );
      },
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(item),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            AppButton(
              text: 'Back',
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              type: AppButtonType.outline,
              icon: Icons.arrow_back,
            )
          else
            const SizedBox.shrink(),
          Text(
            'Step ${_currentPage + 1} of 7',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_currentPage < 6)
            AppButton(
              text: 'Next',
              onPressed: _validateCurrentPage,
              icon: Icons.arrow_forward,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<String> _getForemanOptions(List<Personnel> allPersonnel) {
    final foremanNames = <String>[];
    
    for (var personnel in allPersonnel) {
      if (personnel.role == 'Foreman') {
        foremanNames.add(personnel.name);
      }
    }
    
    return foremanNames;
  }

  void _updateInspectors(String? foremanName) {
    if (foremanName == null) {
      _foreman = null;
      _inspector1 = null;
      _inspector2 = null;
      _inspector3 = null;
      return;
    }
    
    final state = context.read<PersonnelBloc>().state;
    if (state is! PersonnelLoaded) return;
    
    // Find the foreman
    final foremen = state.personnel
        .where((p) => p.role == 'Foreman' && p.name == foremanName)
        .toList();
    
    if (foremen.isEmpty) return;
    
    final foreman = foremen.first;
    _foreman = foreman;
    
    // Find the group for this foreman
    final group = foreman.group;
    
    // Find inspectors for this group
    final inspectors = state.personnel
        .where((p) => p.group == group && p.role.contains('Inspektor'))
        .toList();
    
    inspectors.sort((a, b) => a.role.compareTo(b.role));
    
    // Assign inspectors
    _inspector1 = inspectors.isNotEmpty ? inspectors[0] : null;
    _inspector2 = inspectors.length > 1 ? inspectors[1] : null;
    _inspector3 = inspectors.length > 2 ? inspectors[2] : null;
    
    // Reset statuses
    _foremanStatus = PersonnelStatus.present;
    _inspector1Status = PersonnelStatus.present;
    _inspector2Status = PersonnelStatus.present;
    _inspector3Status = PersonnelStatus.present;
  }

  void _addOvertimePersonnel() {
    if (_selectedOvertimePersonnel == null) return;
    
    final state = context.read<PersonnelBloc>().state;
    if (state is! PersonnelLoaded) return;
    
    // Check if already added
    final alreadyAdded = _overtimePersonnel.any((p) => p.name == _selectedOvertimePersonnel);
    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This person is already added to overtime'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Find the personnel
    final personnel = state.personnel
        .where((p) => p.name == _selectedOvertimePersonnel)
        .toList();
    
    if (personnel.isEmpty) return;
    
    setState(() {
      _overtimePersonnel.add(personnel.first);
      _selectedOvertimePersonnel = null;
    });
  }

  void _removeOvertimePersonnel(int index) {
    setState(() {
      _overtimePersonnel.removeAt(index);
    });
  }

  void _addReinspection() {
    setState(() {
      _reinspections.add(ReinspectionState());
    });
  }

  void _removeReinspection(int index) {
    setState(() {
      final reinspection = _reinspections.removeAt(index);
      reinspection.dispose();
    });
  }

  void _validateCurrentPage() {
    bool isValid = true;
    
    switch (_currentPage) {
      case 0:
        // Validate header page
        if (_foreman == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a foreman'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          isValid = false;
        }
        break;
        
      case 2:
        // Validate UD page if enabled
        if (_hasUDSection) {
          bool hasAtLeastOne = false;
          for (var entry in _udMaterials.entries) {
            final bundlesText = entry.value.bundlesController.text.trim();
            if (bundlesText.isNotEmpty && bundlesText != '0') {
              hasAtLeastOne = true;
              break;
            }
          }
          
          if (!hasAtLeastOne) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter at least one material for UD or disable the section'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            isValid = false;
          }
        }
        break;
        
      case 3:
        // Validate Shipment page if enabled
        if (_hasShipmentSection) {
          bool hasAtLeastOne = false;
          for (var entry in _shipmentMaterials.entries) {
            final bundlesText = entry.value.bundlesController.text.trim();
            if (bundlesText.isNotEmpty && bundlesText != '0') {
              hasAtLeastOne = true;
              break;
            }
          }
          
          if (!hasAtLeastOne) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter at least one material for Shipment or disable the section'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            isValid = false;
          }
        }
        break;
        
      case 4:
        // Validate Pre-Delivery page if enabled
        if (_hasPreDeliverySection) {
          bool hasAtLeastOne = false;
          for (var entry in _preDeliveryMaterials.entries) {
            final bundlesText = entry.value.bundlesController.text.trim();
            if (bundlesText.isNotEmpty && bundlesText != '0') {
              hasAtLeastOne = true;
              break;
            }
          }
          
          if (!hasAtLeastOne) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter at least one material for Pre-Delivery or disable the section'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            isValid = false;
          }
        }
        break;
        
      case 5:
        // Validate Reinspection page if enabled
        if (_hasReinspectionSection && _reinspections.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one reinspection or disable the section'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          isValid = false;
        } else if (_hasReinspectionSection) {
          for (var reinspection in _reinspections) {
            if (reinspection.nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a name for all reinspections'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              isValid = false;
              break;
            }
            
            if (reinspection.totalBundlesController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter total bundles for all reinspections'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              isValid = false;
              break;
            }
            
            if (reinspection.reinspectedBundlesController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter reinspected bundles for all reinspections'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              isValid = false;
              break;
            }
            
            if (reinspection.pendingBundlesController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter pending bundles for all reinspections'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              isValid = false;
              break;
            }
          }
        }
        break;
    }
    
    if (isValid) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitReport() {
    // Create the report
    if (_foreman == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foreman is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Apply the status to personnel using copyWith
    _foreman = _foreman!.copyWith(status: _foremanStatus);
    if (_inspector1 != null) _inspector1 = _inspector1!.copyWith(status: _inspector1Status);
    if (_inspector2 != null) _inspector2 = _inspector2!.copyWith(status: _inspector2Status);
    if (_inspector3 != null) _inspector3 = _inspector3!.copyWith(status: _inspector3Status);
    
    // Create materials sections
    MaterialSection? udSection;
    if (_hasUDSection) {
      final materials = <MaterialReport>[];
      for (var entry in _udMaterials.entries) {
        final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
        final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
        
        if (bundles > 0) {
          materials.add(MaterialReport(
            type: entry.key,
            bundles: bundles,
            tonnage: tonnage,
          ));
        }
      }
      if (materials.isNotEmpty) {
        udSection = MaterialSection(materials: materials);
      }
    }
    
    MaterialSection? shipmentSection;
    if (_hasShipmentSection) {
      final materials = <MaterialReport>[];
      for (var entry in _shipmentMaterials.entries) {
        final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
        final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
        
        if (bundles > 0) {
          materials.add(MaterialReport(
            type: entry.key,
            bundles: bundles,
            tonnage: tonnage,
          ));
        }
      }
      if (materials.isNotEmpty) {
        shipmentSection = MaterialSection(materials: materials);
      }
    }
    
    MaterialSection? preDeliverySection;
    if (_hasPreDeliverySection) {
      final materials = <MaterialReport>[];
      for (var entry in _preDeliveryMaterials.entries) {
        final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
        final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
        
        if (bundles > 0) {
          materials.add(MaterialReport(
            type: entry.key,
            bundles: bundles,
            tonnage: tonnage,
          ));
        }
      }
      if (materials.isNotEmpty) {
        preDeliverySection = MaterialSection(materials: materials);
      }
    }
    
    List<Reinspection>? reinspections;
    if (_hasReinspectionSection && _reinspections.isNotEmpty) {
      reinspections = [];
      for (var state in _reinspections) {
        reinspections.add(Reinspection(
          name: state.nameController.text,
          totalBundles: int.tryParse(state.totalBundlesController.text) ?? 0,
          reinspectedBundles: int.tryParse(state.reinspectedBundlesController.text) ?? 0,
          pendingBundles: int.tryParse(state.pendingBundlesController.text) ?? 0,
          issue: state.issueController.text.isEmpty ? null : state.issueController.text,
          followUp: state.followUpController.text.isEmpty ? null : state.followUpController.text,
          remark: state.remarkController.text.isEmpty ? null : state.remarkController.text,
        ));
      }
    }
    
    final report = ReportModel(
      id: Utils.generateUniqueId(),
      date: _selectedDate,
      shift: _selectedShift,
      foreman: PersonnelModel.fromPersonnel(_foreman!),
      inspector1: PersonnelModel.fromPersonnel(_inspector1!),
      inspector2: PersonnelModel.fromPersonnel(_inspector2!),
      inspector3: PersonnelModel.fromPersonnel(_inspector3!),
      overtimePersonnel: _overtimePersonnel.isEmpty ? null : 
        _overtimePersonnel.map((p) => PersonnelModel.fromPersonnel(p)).toList(),
      safetyTalk: _safetyTalkStatus,
      measuringTools: _measuringToolsStatus,
      flashlight: _flashlightStatus,
      mobilePhone: _mobilePhoneStatus,
      camera: _cameraStatus,
      usageDecision: udSection,
      shipmentHR: shipmentSection,
      preDelivery: preDeliverySection,
      reinspections: reinspections,
      udIssue: _udIssueController.text.isEmpty ? null : _udIssueController.text,
      udFollowUp: _udFollowUpController.text.isEmpty ? null : _udFollowUpController.text,
      udRemark: _udRemarkController.text.isEmpty ? null : _udRemarkController.text,
      createdBy: _currentUserName,
      createdAt: DateTime.now(),
    );
    
    // Save the report
    context.read<ReportBloc>().add(SaveReportEvent(report: report));
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Report?'),
        content: const Text('Are you sure you want to exit? Any unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Navigate back
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  List<String> _getUDMaterialReviewItems() {
    final items = <String>[];
    int totalBundles = 0;
    double totalTonnage = 0.0;
    
    for (var entry in _udMaterials.entries) {
      final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
      final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
      
      if (bundles > 0) {
        items.add('${entry.key}: $bundles bundles, ${Utils.formatNumber(tonnage)} tons');
        totalBundles += bundles;
        totalTonnage += tonnage;
      }
    }
    
    if (items.isNotEmpty) {
      items.add('');
      items.add('Total: $totalBundles bundles, ${Utils.formatNumber(totalTonnage)} tons');
    }
    
    if (_udIssueController.text.isNotEmpty) {
      items.add('');
      items.add('Issues: ${_udIssueController.text}');
    }
    
    if (_udFollowUpController.text.isNotEmpty) {
      items.add('Follow-up: ${_udFollowUpController.text}');
    }
    
    if (_udRemarkController.text.isNotEmpty) {
      items.add('Remarks: ${_udRemarkController.text}');
    }
    
    return items;
  }

  List<String> _getShipmentMaterialReviewItems() {
    final items = <String>[];
    int totalBundles = 0;
    double totalTonnage = 0.0;
    
    for (var entry in _shipmentMaterials.entries) {
      final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
      final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
      
      if (bundles > 0) {
        items.add('${entry.key}: $bundles bundles, ${Utils.formatNumber(tonnage)} tons');
        totalBundles += bundles;
        totalTonnage += tonnage;
      }
    }
    
    if (items.isNotEmpty) {
      items.add('');
      items.add('Total: $totalBundles bundles, ${Utils.formatNumber(totalTonnage)} tons');
    }
    
    return items;
  }

  List<String> _getPreDeliveryMaterialReviewItems() {
    final items = <String>[];
    int totalBundles = 0;
    double totalTonnage = 0.0;
    
    for (var entry in _preDeliveryMaterials.entries) {
      final bundles = int.tryParse(entry.value.bundlesController.text) ?? 0;
      final tonnage = double.tryParse(entry.value.tonnageController.text) ?? 0.0;
      
      if (bundles > 0) {
        items.add('${entry.key}: $bundles bundles, ${Utils.formatNumber(tonnage)} tons');
        totalBundles += bundles;
        totalTonnage += tonnage;
      }
    }
    
    if (items.isNotEmpty) {
      items.add('');
      items.add('Total: $totalBundles bundles, ${Utils.formatNumber(totalTonnage)} tons');
    }
    
    return items;
  }

  List<String> _getReinspectionReviewItems() {
    final items = <String>[];
    int totalBundles = 0;
    int reinspectedBundles = 0;
    int pendingBundles = 0;
    
    for (var i = 0; i < _reinspections.length; i++) {
      final state = _reinspections[i];
      final total = int.tryParse(state.totalBundlesController.text) ?? 0;
      final reinspected = int.tryParse(state.reinspectedBundlesController.text) ?? 0;
      final pending = int.tryParse(state.pendingBundlesController.text) ?? 0;
      
      items.add('${state.nameController.text}:');
      items.add('  Total: $total bundles');
      items.add('  Reinspected: $reinspected bundles');
      items.add('  Pending: $pending bundles');
      
      if (state.issueController.text.isNotEmpty) {
        items.add('  Issues: ${state.issueController.text}');
      }
      
      if (state.followUpController.text.isNotEmpty) {
        items.add('  Follow-up: ${state.followUpController.text}');
      }
      
      if (state.remarkController.text.isNotEmpty) {
        items.add('  Remarks: ${state.remarkController.text}');
      }
      
      items.add('');
      
      totalBundles += total;
      reinspectedBundles += reinspected;
      pendingBundles += pending;
    }
    
    items.add('Total Bundles: $totalBundles');
    items.add('Total Reinspected: $reinspectedBundles');
    items.add('Total Pending: $pendingBundles');
    
    return items;
  }
}

class MaterialEntryState {
  final TextEditingController bundlesController;
  final TextEditingController tonnageController;
  
  MaterialEntryState({
    required this.bundlesController,
    required this.tonnageController,
  });
}

class ReinspectionState {
  final nameController = TextEditingController();
  final totalBundlesController = TextEditingController();
  final reinspectedBundlesController = TextEditingController();
  final pendingBundlesController = TextEditingController();
  final issueController = TextEditingController();
  final followUpController = TextEditingController();
  final remarkController = TextEditingController();
  
  void dispose() {
    nameController.dispose();
    totalBundlesController.dispose();
    reinspectedBundlesController.dispose();
    pendingBundlesController.dispose();
    issueController.dispose();
    followUpController.dispose();
    remarkController.dispose();
  }
}
