import 'dart:async';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

/// Handles connectivity changes and shows appropriate UI feedback
class ConnectivityHandler {
  static ConnectivityHandler? _instance;
  StreamSubscription<bool>? _connectionSubscription;
  
  ConnectivityHandler._();
  
  static ConnectivityHandler get instance {
    _instance ??= ConnectivityHandler._();
    return _instance!;
  }

  /// Initialize connectivity monitoring
  void initialize(BuildContext context) {
    // Listen to Firebase Realtime Database connection state
    _connectionSubscription = FirebaseRealtimeService()
        .connectionState
        .listen((isConnected) async {
      if (context.mounted) {
        _handleConnectionChange(context, isConnected);
      }
    });
  }

  /// Handle connection state changes
  void _handleConnectionChange(BuildContext context, bool isConnected) {
    // Check if context is still mounted before using it
    if (!context.mounted) return;
    
    if (!isConnected) {
      _showOfflineSnackBar(context);
    } else {
      _showOnlineSnackBar(context);
      // Trigger sync when coming back online
      SyncService.instance.syncAll().catchError((error) {
        debugPrint('Error syncing after reconnection: $error');
      });
    }
  }

  /// Show offline indicator
  void _showOfflineSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Text('You are offline. Messages will sync when reconnected.'),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show online indicator
  void _showOnlineSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.white),
            SizedBox(width: 8),
            Text('Back online. Syncing messages...'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Clean up resources
  void dispose() {
    _connectionSubscription?.cancel();
    _instance = null;
  }
}

/// Widget that shows persistent connection status
class ConnectionStatusWidget extends StatefulWidget {
  final Widget child;

  const ConnectionStatusWidget({super.key, required this.child});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  bool _isOnline = true;
  StreamSubscription<bool>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _listenToConnectionChanges();
  }

  void _listenToConnectionChanges() {
    _connectionSubscription = FirebaseRealtimeService()
        .connectionState
        .listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.orange[600],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Offline - Messages will sync when reconnected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}