class AppConstants {
  // App info
  static const String appName = 'QCFP Report';
  static const String appVersion = '1.0.0';
  
  // Default admin credentials
  static const String defaultAdminNik = '11702';
  static const String defaultAdminPin = '250184';
  
  // Validation constants
  static const int minPinLength = 4;
  static const int maxPinLength = 6; // Allows for PIN 250184 (6 digits)
  
  // Storage keys
  static const String currentUserKey = 'current_user';
  static const String isFirstLaunchKey = 'is_first_launch';
  
  // Error messages
  static const String generalErrorMessage = 'Something went wrong. Please try again.';
  static const String invalidPinErrorMessage = 'Invalid PIN. Please try again.';
  static const String storageErrorMessage = 'Error accessing local storage.';
  
  // Form validation messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidNumberMessage = 'Please enter a valid number';
  
  // Shift types
  static const List<String> shifts = ['Shift 1', 'Shift 2', 'Shift 3'];
  
  // Status options
  static const List<String> personnelStatusOptions = ['Hadir', 'Sakit', 'Izin', 'Cuti'];
  
  // Safety talk options
  static const List<String> safetyTalkOptions = ['Dilaksanakan', 'Tidak dilaksanakan'];
  
  // Equipment status options
  static const List<String> equipmentStatusOptions = ['OK', 'Tidak OK'];
  static const List<String> calibrationStatusOptions = ['Terkalibrasi', 'Tidak OK'];
  
  // Material types for reports
  static const List<String> materialTypesUD = [
    'HCF', 'HSF', 'HLF', 'HCF-S', 'HSF-S', 'HLF-S', 'HCF-TL', 'HSF-TL', 'HLF-TL'
  ];
  
  static const List<String> materialTypesShipment = [
    'HCF', 'HSF', 'HLF', 'HCF-S', 'HSF-S', 'HLF-S', 'HCF-TL', 'HSF-TL', 'HLF-TL'
  ];
  
  static const List<String> materialTypesPreDelivery = [
    'Coil PJKA', 'Coil Domestik', 'Plate Domestik', 'Slitting Domestik',
    'Coil Export', 'Plate Export', 'Slitting Export',
    'Coil Tolling', 'Plate Tolling', 'Slitting Tolling'
  ];

  // Personnel Groups
  static final Map<String, Map<String, String>> personnelGroups = {
    'Grup 1': {
      'Foreman': 'M. Albi Azhar',
      'Inspektor 1': 'Muhlas',
      'Inspektor 2': 'Sofyan',
      'Inspektor 3': 'Mercyanto',
    },
    'Grup 2': {
      'Foreman': 'Hartomi',
      'Inspektor 1': 'Ary Apreandy Me',
      'Inspektor 2': 'Sumartin',
      'Inspektor 3': 'Yunan K.',
    },
    'Grup 3': {
      'Foreman': 'Obay Baehaki',
      'Inspektor 1': 'Ary Sugiharto',
      'Inspektor 2': 'Irwan Agus S.',
      'Inspektor 3': 'Saefullah',
    },
    'Grup 4': {
      'Foreman': 'Asep Nuryadi',
      'Inspektor 1': 'Muslimin Abda\'u',
      'Inspektor 2': 'Umaedi',
      'Inspektor 3': 'Hasbullah',
    },
  };
  
  // Get all personnel names for dropdown
  static List<String> getAllPersonnelNames() {
    final Set<String> names = {};
    
    personnelGroups.forEach((group, personnel) {
      personnel.forEach((role, name) {
        names.add(name);
      });
    });
    
    return names.toList()..sort();
  }
  
  // Get group based on foreman name
  static String? getGroupByForeman(String foremanName) {
    for (var entry in personnelGroups.entries) {
      if (entry.value['Foreman'] == foremanName) {
        return entry.key;
      }
    }
    return null;
  }

  // Get inspectors based on foreman name
  static Map<String, String> getInspectorsByForeman(String foremanName) {
    for (var entry in personnelGroups.entries) {
      if (entry.value['Foreman'] == foremanName) {
        return {
          'Inspektor 1': entry.value['Inspektor 1'] ?? '',
          'Inspektor 2': entry.value['Inspektor 2'] ?? '',
          'Inspektor 3': entry.value['Inspektor 3'] ?? '',
        };
      }
    }
    return {
      'Inspektor 1': '',
      'Inspektor 2': '',
      'Inspektor 3': '',
    };
  }
}
