import 'dart:async';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

class ConnectivityHandler {
  ConnectivityHandler._();
  static ConnectivityHandler? _instance;
  StreamSubscription<bool>? _connectionSubscription;

  static ConnectivityHandler get instance {
    _instance ??= ConnectivityHandler._();
    return _instance!;
  }

  void initialize(BuildContext context) {
    _connectionSubscription = FirebaseRealtimeService().connectionState.listen((
      isConnected,
    ) async {
      if (context.mounted) {
        _handleConnectionChange(context, isConnected);
      }
    });
  }

  void _handleConnectionChange(BuildContext context, bool isConnected) {
    if (!context.mounted) return;

    if (!isConnected) {
      _showOfflineSnackBar(context);
    } else {
      _showOnlineSnackBar(context);

      SyncService.instance.syncAll().catchError((Object error) {
        debugPrint('Error syncing after reconnection: $error');
      });
    }
  }

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

  void dispose() {
    _connectionSubscription?.cancel();
    _instance = null;
  }
}

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({required this.child, super.key});

  final Widget child;

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
    _connectionSubscription = FirebaseRealtimeService().connectionState.listen((
      isConnected,
    ) {
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
