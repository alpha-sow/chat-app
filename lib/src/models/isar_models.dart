// Skip Isar for web builds to avoid JavaScript integer limitations
export 'isar_models_stub.dart' if (dart.library.io) 'isar_models_real.dart';
