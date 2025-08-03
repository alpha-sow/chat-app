// Conditional export: use stub for web, real implementation for other platforms
export 'local_database_service_stub.dart'
    if (dart.library.io) 'local_database_service_real.dart';
