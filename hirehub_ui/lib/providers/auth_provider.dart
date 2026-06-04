import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  String? _lastOtp; // To handle Test Mode OTP return

  AuthProvider() {
    _apiService.onUnauthorized = () {
      _isAuthenticated = false;
      _userData = null;
      notifyListeners();
    };
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;
  String? get lastOtp => _lastOtp;

  /// Initialize auth on app startup - load token if exists
  Future<void> initializeAuth() async {
    try {
      await _apiService.loadToken();
      final token = _apiService.getToken();
      
      if (token != null) {
        // try to refresh user data from server
        try {
          final meResponse = await _apiService.getMe();
          if (meResponse.statusCode == 200) {
            _userData = meResponse.data;
            _isAuthenticated = true;
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            // Token is invalid/expired
            await _apiService.logout();
            _userData = null;
            _isAuthenticated = false;
          } else {
            // Other server error (e.g. timeout), fallback to stored data
            final stored = await _apiService.loadUserData();
            if (stored != null) {
              _userData = stored;
              _isAuthenticated = true;
            } else {
              _isAuthenticated = false;
            }
          }
        } catch (e) {
          // Fallback for non-Dio errors
          final stored = await _apiService.loadUserData();
          if (stored != null) {
            _userData = stored;
            _isAuthenticated = true;
          } else {
            _isAuthenticated = false;
          }
        }
        notifyListeners();
      } else {
        _isAuthenticated = false;
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _userData = data;
        if (data.containsKey('token')) {
          await _apiService.saveToken(data['token']);
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user - clear token and user data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.logout();
      _isAuthenticated = false;
      _userData = null;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send OTP via API
  Future<bool> sendOTP(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.sendOTP(email);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('otp')) {
          _lastOtp = data['otp'].toString();
        } else {
          _lastOtp = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Failed to send OTP';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP via API
  Future<bool> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyOTP(email, otp);
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Failed to verify OTP';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Register recruiter via API
  Future<bool> registerRecruiter(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(data);
      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Registration failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Register applicant via API
  Future<bool> registerApplicant(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.registerApplicant(data);
      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Registration failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Fetch applicant profile
  Future<Map<String, dynamic>?> fetchApplicantProfile() async {
    try {
      final response = await _apiService.getApplicantProfile();
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return null;
  }

  /// Update applicant profile (optionally with resume file)
  Future<bool> updateApplicantProfile(
    Map<String, dynamic> data, [
    PlatformFile? resumeFile,
    PlatformFile? imageFile,
  ]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.updateApplicantProfile(
        data,
        resumeFile,
        imageFile,
      );
      if (response.statusCode == 200) {
        // Force refresh of the user state to sync the dashboard
        await initializeAuth();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Update failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Fetch recruiter profiles (returns list of companies)
  Future<List<Map<String, dynamic>>?> fetchRecruiterProfile() async {
    try {
      final response = await _apiService.getRecruiterProfile();
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
           return List<Map<String, dynamic>>.from(data);
        }
        return [Map<String, dynamic>.from(data as Map)];
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return null;
  }

  /// Update recruiter profile (or create new company)
  Future<bool> updateRecruiterProfile(
    Map<String, dynamic> data, [
    PlatformFile? logoFile,
  ]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.updateRecruiterProfile(
        data,
        logoFile,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Update failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Delete a company profile
  Future<bool> deleteCompany(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.deleteCompany(id);
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Delete failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null) {
        // Prevent showing raw HTML (like <!DOCTYPE) in the UI
        if (data is String && (data.toLowerCase().contains('<!doctype') || data.toLowerCase().contains('<html'))) {
          return 'Server Error: The request failed on the host. Check server logs or migrations.';
        }

        if (data is Map) {
          if (data.containsKey('error')) return data['error'].toString();
          if (data.containsKey('detail')) return data['detail'].toString();

          // Collect validation errors
          final List<String> errorMessages = [];
          data.forEach((key, value) {
            String msg = '';
            if (value is List) {
              msg = value.join(", ");
            } else {
              msg = value.toString();
            }
            final keyName = key.substring(0, 1).toUpperCase() + key.substring(1);
            errorMessages.add('$keyName: $msg');
          });

          if (errorMessages.isNotEmpty) {
            return errorMessages.join('\n');
          }
        }
        return 'Request failed: $data';
      }
      
      final String? message = error.message;
      if (message != null && message.contains('XMLHttpRequest error')) {
        return 'Network Error: Cannot connect to server (CORS or server down).';
      }
      
      return message ?? 'Unknown connection error';
    }
    return error.toString();
  }
}
