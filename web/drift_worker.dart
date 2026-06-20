// Compiled to web/drift_worker.dart.js (see tool/build_web_worker.sh).
// Runs the Drift web worker so the database executes off the main isolate,
// using OPFS where available and falling back through IndexedDB.
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
